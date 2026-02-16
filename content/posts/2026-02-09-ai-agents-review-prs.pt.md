---
title: "Como Uso Agentes de IA para Revisar Meus Próprios PRs Antes de Qualquer Pessoa"
date: 2026-02-09
description: "Um guia prático para configurar code review com IA usando a API do Claude e Git hooks para pegar bugs antes dos seus colegas."
tags: ["ai-agents", "code-review", "claude-api", "git-hooks", "automation"]
categories: ["AI Development"]
draft: false
---

Mês passado, eu fiz push de um PR que parecia impecável. Código limpo, testes passando, documentação atualizada. Meu colega encontrou uma race condition no tratamento de erros em 10 minutos de review. Foi constrangedor — não porque eu errei, mas porque era exatamente o tipo de bug que uma IA teria pego se eu tivesse pedido pra ela olhar.

Essa experiência me motivou a construir algo que agora uso em todo PR: um agente de IA que revisa meu código antes mesmo de eu pedir review humano. Aqui está como montei, o que realmente funciona e onde ainda deixa a desejar.

## O Problema da Auto-Revisão

Todo mundo faz self-review antes de fazer push. A gente lê o diff, talvez roda localmente e se convence de que está pronto. Mas a real é: nosso cérebro é péssimo em encontrar os próprios erros. A gente enxerga o que pretendia escrever, não o que de fato escreveu.

Linters tradicionais e análise estática ajudam, mas não pegam bugs semânticos — aqueles em que o código está sintaticamente correto mas logicamente errado. É aí que a IA brilha. Ela consegue raciocinar sobre a intenção, identificar edge cases que você não considerou e perguntar "espera, o que acontece se X for null aqui?"

## Meu Setup: Claude + Git Pre-Push Hook

Depois de testar várias abordagens, decidi por um hook de pre-push no Git que chama a API do Claude. Por que pre-push e não pre-commit? Porque eu quero commits rápidos durante o desenvolvimento, mas quero uma revisão completa antes do código sair da minha máquina.

A arquitetura básica:

1. O hook de pre-push dispara um script Python
2. O script extrai o diff dos commits sendo enviados
3. O diff + contexto vai para a API do Claude com um prompt de code review
4. O Claude retorna os achados, o script exibe
5. Eu decido se faço push mesmo assim ou corrijo os problemas

### O Hook de Pre-Push

Primeiro, crie `.git/hooks/pre-push`:

```bash
#!/bin/bash

# Get the commits being pushed
remote="$1"
url="$2"

while read local_ref local_sha remote_ref remote_sha
do
    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch, review all commits
        range="$local_sha"
    else
        # Existing branch, review new commits only
        range="$remote_sha..$local_sha"
    fi
    
    # Run the AI review
    python3 ~/.git-hooks/ai-review.py "$range"
    
    if [ $? -ne 0 ]; then
        echo "AI review found issues. Push anyway? (y/n)"
        read -r response
        if [ "$response" != "y" ]; then
            exit 1
        fi
    fi
done

exit 0
```

Torne executável: `chmod +x .git/hooks/pre-push`

### O Script Python de Review

Aqui está o core do `~/.git-hooks/ai-review.py`:

```python
#!/usr/bin/env python3
import subprocess
import sys
import os
from anthropic import Anthropic

def get_diff(commit_range):
    """Get the diff for the specified commit range."""
    result = subprocess.run(
        ["git", "diff", commit_range, "--", "*.py", "*.js", "*.ts", "*.go"],
        capture_output=True,
        text=True
    )
    return result.stdout

def get_commit_messages(commit_range):
    """Get commit messages for context."""
    result = subprocess.run(
        ["git", "log", commit_range, "--oneline"],
        capture_output=True,
        text=True
    )
    return result.stdout

def review_code(diff, commits):
    """Send code to Claude for review."""
    client = Anthropic()
    
    prompt = f"""You are a senior software engineer reviewing a pull request. 
Review the following code changes and identify:

1. **Bugs**: Logic errors, race conditions, null pointer issues
2. **Security**: Injection vulnerabilities, auth issues, data exposure
3. **Edge cases**: Unhandled scenarios that could cause failures
4. **Performance**: Obvious inefficiencies or scaling concerns

Be specific. Reference line numbers when possible. Skip style nitpicks—focus on things that could break in production.

Commit messages:
{commits}

Code diff:
{diff}

If you find no significant issues, respond with "LGTM" only.
Otherwise, list each issue with severity (HIGH/MEDIUM/LOW)."""

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.content[0].text

def main():
    if len(sys.argv) < 2:
        print("Usage: ai-review.py <commit-range>")
        sys.exit(1)
    
    commit_range = sys.argv[1]
    diff = get_diff(commit_range)
    
    if not diff.strip():
        print("No relevant changes to review.")
        sys.exit(0)
    
    # Limit diff size to avoid token limits
    if len(diff) > 50000:
        print("Diff too large for AI review, reviewing first 50KB...")
        diff = diff[:50000]
    
    commits = get_commit_messages(commit_range)
    
    print("\n🤖 AI Code Review in progress...\n")
    result = review_code(diff, commits)
    
    print(result)
    print()
    
    if "LGTM" in result and len(result) < 20:
        sys.exit(0)
    else:
        # Found issues, return non-zero
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Exemplo Real: Um Bug que o Claude Pegou

Duas semanas atrás, eu estava refatorando uma função de processamento de pagamento. Aqui vai uma versão simplificada do que escrevi:

```python
async def process_payment(user_id: str, amount: Decimal) -> PaymentResult:
    user = await get_user(user_id)
    if not user:
        raise UserNotFoundError(user_id)
    
    balance = await get_balance(user_id)
    if balance < amount:
        raise InsufficientFundsError(user_id, balance, amount)
    
    # Deduct and process
    await deduct_balance(user_id, amount)
    result = await payment_gateway.charge(user.payment_method, amount)
    
    if not result.success:
        # Refund on failure
        await add_balance(user_id, amount)
        raise PaymentFailedError(result.error)
    
    return result
```

Resposta do Claude:

> **HIGH: Race condition no tratamento de saldo**
> 
> Entre a verificação do saldo (linha 7) e a dedução (linha 11), outra requisição pode modificar o saldo. Em cenários de alta concorrência, isso poderia permitir saques a descoberto.
> 
> Além disso, se `payment_gateway.charge()` falhar DEPOIS de `deduct_balance()` ter sucesso, e o refund via `add_balance()` também falhar, o usuário perde dinheiro sem nenhum registro.
> 
> Recomendação: Usar uma transação no banco de dados com lock a nível de linha, ou implementar operações idempotentes com um ledger separado.

Esse é exatamente o tipo de bug que passa nos testes unitários mas explode em produção. Eu sabia sobre race conditions conceitualmente, mas no fluxo de escrever código, simplesmente... deixei passar. A IA não deixou.

## O Que Funciona Bem

Depois de três meses usando esse setup, aqui está onde o review por IA consistentemente agrega valor:

**Problemas de concorrência**: O Claude é excelente em identificar race conditions, potencial de deadlock e locks faltando. Ele pensa em "o que acontece se duas requisições baterem aqui ao mesmo tempo?" de forma mais confiável do que eu.

**Lacunas no tratamento de erros**: Ele pega casos de erro faltando, especialmente em código assíncrono onde exceções podem ser engolidas silenciosamente.

**Checks de null/undefined**: O clássico "mas e se isso for null?" que a gente esquece quando está focado no happy path.

**Segurança básica**: SQL injection, XSS, secrets hardcoded — ele pega o OWASP Top 10 de forma consistente.

## O Que Não Funciona (Ainda)

Review de código por IA não é mágica. Aqui está onde deixa a desejar:

**Validação de lógica de negócio**: O Claude não sabe que "usuários acima de 65 anos ganham 10% de desconto" é uma regra de negócio no seu sistema. Ele não consegue verificar se você implementou a lógica certa, apenas se sua lógica é internamente consistente.

**Performance em escala**: Ele pode sinalizar um loop O(n²), mas não sabe que seu n é sempre < 10 ou que isso roda uma vez por dia. Contexto importa.

**Falsos positivos**: Às vezes ele sinaliza coisas que são intencionais. Eu estimo que cerca de 20% das preocupações dele são situações de "na verdade, tá certo porque..."

**Diffs grandes**: Limites de token significam que você não consegue revisar um refactor de 2000 linhas de forma efetiva. Eu quebro PRs grandes manualmente pra isso.

## A Realidade dos Custos

Vamos falar de dinheiro. Usando o modelo Sonnet do Claude, um review típico de PR (diff de 500 linhas) custa cerca de $0.02-0.05. Com 10 PRs por dia, dá aproximadamente $10-15/mês. Pelos bugs que ele pega? Vale muito a pena.

Se você está em um time, pode rodar isso como um serviço compartilhado e dividir os custos. Ou usar apenas para caminhos críticos — processamento de pagamento, autenticação, manipulação de dados.

## Melhorando com o Tempo

Eu iterei bastante no prompt. Algumas dicas:

1. **Seja específico sobre o que ignorar**: Adicionei "ignore nitpicks de estilo, formatação e sugestões de nomes" pra reduzir o ruído.

2. **Adicione contexto do repo**: Para codebases complexas, incluo uma breve descrição da arquitetura no prompt.

3. **Acompanhe a precisão**: Mantenho um log simples de problemas encontrados vs falsos positivos. Quando a taxa de falsos positivos sobe, ajusto o prompt.

4. **Combine com review humano**: Isso não substitui seus colegas. Torna o review deles mais rápido porque as coisas óbvias já foram pegas.

## Conclusão

Usar IA para revisar meus PRs antes do review humano se tornou um dos meus projetos de automação com maior ROI. A configuração levou uma tarde, os custos são insignificantes e ele pega bugs reais — do tipo que chegaria ao code review ou, pior, à produção.

O insight principal: IA é melhor revisando código do que escrevendo do zero. Ela não consegue arquitetar seu sistema, mas com certeza consegue te avisar quando você esqueceu de tratar um null pointer no seu error path.

Se você ainda não faz isso, comece com um hook de pre-push simples no seu repo mais crítico. Veja o que ele pega em uma semana. Aposto que você vai se surpreender.

---

*Tem uma abordagem diferente pra code review com IA? Encontrou ferramentas que funcionam melhor? Adoraria saber — me procure no [LinkedIn](https://linkedin.com) ou [Twitter/X](https://twitter.com).*
