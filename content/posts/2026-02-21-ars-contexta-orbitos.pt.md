---
title: "ARS Contexta + OrbitOS: Como Organizei Meu Desenvolvimento com AI CLI"
date: 2026-02-21
description: "Os dois sistemas que criaram uma 'memória organizada' pro meu AI CLI trabalhar: contexto estruturado + orquestração de workflows."
tags: ["ai-cli", "claude-code", "workflow", "context-management", "productivity"]
categories: ["AI Development", "Productivity"]
slug: "ars-contexta-orbitos-ai-cli"
keywords:
  - AI CLI development
  - context management
  - workflow automation
  - Claude Code
  - OpenCode
  - agentic development
draft: false
---

**Como transformar AI CLI tools em um ambiente de desenvolvimento com memória persistente e automação real.**

Se você usa AI pra programar todos os dias, já percebeu: a ferramenta é brilhante… até você fechar a sessão.

## O problema real

Todo mundo que usa AI CLI tools como Claude Code ou OpenCode passa pelo mesmo problema: na primeira sessão, a ferramenta é incrível. Ela entende o que você quer, gera código bom, acelera seu trabalho. Na quinta sessão, você percebe que está repetindo as mesmas explicações. Na décima, você desiste e aceita que cada sessão é reinventar a roda.

O problema não é a ferramenta. É que ela não tem memória — ou melhor, não tem uma memória *organizada*.

Há duas semanas resolvi resolver isso. Encontrei dois sistemas open source que funcionam juntos: um pra guardar e recuperar contexto, outro pra orquestrar workflows. Não são ferramentas prontas pra usar. São estruturas que adaptei pro meu fluxo. Funcionam tão bem que agora não consigo mais trabalhar sem eles.

Quando você abre uma sessão com Claude Code ou OpenCode, o modelo sabe programar. Ele sabe Python, JavaScript, arquitetura de software, padrões de design. O que ele não sabe é:

- Que você prefere usar `async/await` ao invés de promises encadeadas
- Que aquele projeto usa uma arquitetura específica de camadas
- Que você já tentou aquela abordagem e deu problema
- Que você tem um padrão de nomenclatura pra variáveis
- Que você odeia quando o código gera warnings de linter

Você pode explicar tudo isso em cada sessão. Mas são 5-10 minutos de setup antes de começar a trabalhar. Multiplica isso por 3 sessões por dia, 5 dias por semana. Perde-se uma hora só repetindo contexto.

E tem o segundo problema: tarefas repetitivas. Sempre que termino uma feature, faço o mesmo ritual: rodo testes, verifico lint, faço commit com mensagem descritiva, abro PR, notifico o time. É mecânico. Deveria ser automático.

## ARS Contexta — A memória que persiste

[ARS Contexta](https://github.com/agenticnotetaking/arscontexta) é um plugin do Claude Code que gera um "segundo cérebro" organizado em markdown — persistindo contexto entre sessões.

Ao invés de começar do zero toda vez, o plugin estrutura seu conhecimento em três espaços:

**self/** — sua identidade, metodologia, valores de código. Quem você é como dev.

**notes/** — o grafo de conhecimento do projeto. Decisões, arquitetura, aprendizados.

**ops/** — coordenação operacional. Queue de tarefas, estado de sessões.

O diferencial é o pipeline dos **6 Rs**: Record → Reduce → Reflect → Reweave → Verify → Rethink. Comandos como `/reduce` extraem insights, `/reflect` encontra conexões, `/verify` valida qualidade. Cada fase roda em subagent separado, mantendo contexto fresco.

Na prática: quando inicio uma sessão, meu agent já sabe quem eu sou, como trabalho, e o que decidimos antes.

### Como adaptei pro meu fluxo

No meu setup, adaptei o conceito do ARS: mantenho `SOUL.md` (minha identidade como dev), `MEMORY.md` (decisões arquiteturais), arquivos diários de sessão, e `TOOLS.md` (stack específico). Uso comandos como `/reduce` pra extrair insights e `/verify` pra validar qualidade antes de commitar.

## OrbitOS — O orquestrador de workflows

[OrbitOS](https://github.com/MarsWang42/OrbitOS) é um vault do Obsidian integrado com AI CLI pra orquestrar produtividade pessoal — conectando gerenciamento de conhecimento com planejamento diário.

A estrutura é organizada em pastas numeradas:

**00_Inbox/** — captura rápida de ideias (a AI processa depois)

**10_Daily/** — logs diários gerados pela AI com recomendações

**20_Project/** — projetos ativos no formato C.A.P. (Context, Actions, Progress)

**30_Research/** — notas de pesquisa estruturadas pela AI

**40_Wiki/** — conceitos atômicos com wikilinks

O workflow é comandado por slash commands: `/start-my-day` planeja o dia, `/kickoff` transforma ideias em projetos, `/research` faz deep dives organizados, `/archive` limpa o que foi concluído.

A mágica está nos wikilinks: projetos linkam com research, daily notes linkam com projetos, criando um grafo de conhecimento conectado.

### Como adaptei pro meu fluxo

Adaptei o conceito do OrbitOS criando skills em markdown pra tarefas repetidas: escrita de código, revisão, deploy. Cada skill tem instruções detalhadas que carrego no contexto quando preciso. Workflows rodam via comandos slash, com fallbacks quando algo falha.

## Os dois trabalhando juntos

Separados, cada sistema é útil. Juntos, são transformadores.

Aqui está um exemplo real de como funcionam em conjunto:

Peço pro AI CLI: *"Implementa uma função de processamento de dados CSV que valida schemas e gera relatório de erros"*

**ARS Contexta entra em ação:**
- Busca `SOUL.md` pra saber meus padrões (Python 3.11+, type hints obrigatórios, prefiro `pandas` puro quando possível)
- Lê `MEMORY.md` pra ver decisões arquiteturais (usamos arquitetura em camadas, separação clara entre parsing/validação/processamento)
- Verifica `TOOLS.md` sobre o stack (Pydantic pra validação, pytest pra testes, ruff/mypy pra qualidade)
- Olha arquivos diários pra ver o que foi implementado recentemente (evitar conflitos com parsers existentes)

**OrbitOS entra em ação:**
- Carrega skill de "Implementar pipeline de dados"
- Executa: 
  1. Cria schema Pydantic pra validação das colunas CSV
  2. Implementa função `parse_csv` com tratamento de encoding
  3. Implementa função `validate_rows` com acumulação de erros
  4. Implementa função `generate_error_report` com estatísticas
  5. Escreve testes unitários com casos de borda (CSV vazio, encoding errado, campos nulos)
  6. Escreve testes de integração com arquivos reais
- Roda `ruff check .` e `mypy src/` automaticamente
- Executa `pytest tests/ -v` pra garantir que nada quebrou
- Faz git add, commit com mensagem seguindo conventional commits: `feat(data): add CSV processing pipeline`

O resultado: em ~15 minutos tenho uma feature completa, testada, tipada, documentada. Sem ARS, o AI teria gerado código genérico que não segue meus padrões. Sem OrbitOS, eu teria que lembrar manualmente de rodar lint, type-check, e escrever testes — e provavelmente esqueceria alguma coisa.

## O que aprendi implementando isso (e como você pode começar agora)

Depois de duas semanas usando ARS Contexta e OrbitOS, aqui está o guia prático que gostaria de ter tido no primeiro dia:

### Dia 1: Configure ARS Contexta (30 minutos)

**Passo 1:** Crie um arquivo `SOUL.md` na raiz do seu projeto:
```markdown
# SOUL.md

## Quem sou eu
- Sou [seu nome], dev [especialidade] há [X] anos
- Prefiro código explícito a código "esperto"
- Gosto de type hints em tudo
- Odeio warnings de linter

## Stack favorito
- Python 3.11+ / TypeScript
- Pydantic pra validação
- Pytest pra testes
- Ruff + mypy pra qualidade

## Princípios
- Testes antes de implementar
- Docstrings em funções públicas
- Commits atômicos com mensagens claras
```

**Passo 2:** Crie um arquivo `MEMORY.md` vazio. Vai preenchendo conforme toma decisões importantes.

**Passo 3:** No início de cada sessão com Claude Code, peça: *"Leia SOUL.md e MEMORY.md antes de começar"*

Pronto. Você já tem contexto persistente.

### Dia 2-3: Crie sua primeira Skill no OrbitOS (45 minutos)

Escolha uma tarefa que você faz pelo menos 3x por semana. Exemplo: "Criar função com testes"

Crie o arquivo `skills/create-function.md`:
```markdown
# Skill: Create Function with Tests

## Quando usar
Ao implementar uma nova função de negócio

## Passos
1. Crie a assinatura da função com type hints
2. Escreva 3 testes ANTES de implementar:
   - Caso feliz
   - Caso de erro (exception)
   - Caso de borda (vazio/nulo)
3. Implemente a função mínima para passar nos testes
4. Refatore se necessário
5. Rode `pytest tests/ -v` e corrija se falhar
6. Rode `ruff check . && mypy src/` e corrija se falhar
7. Faça commit: `feat: add [nome-da-funcao]`

## Checklist de qualidade
- [ ] Type hints em todos os parâmetros e retorno
- [ ] Docstring descrevendo o que faz
- [ ] Pelo menos 3 testes
- [ ] Linter passando
- [ ] Type-check passando
```

Para usar: *"Carregue a skill 'create-function' e implemente uma função que [descrição]"*

### Dia 4-7: Itere e expanda

- A cada decisão importante, adicione em `MEMORY.md`
- Quando notar que repete instruções, crie uma skill
- Quando uma skill não funcionar bem, edite ela

### Semana 2: Automatize um workflow completo

Escolha um ritual que você faz sempre. Exemplo: "Finalizar uma feature"

Crie `skills/complete-feature.md`:
```markdown
# Skill: Complete Feature

## Passos
1. Rode todos os testes: `pytest tests/ -v`
2. Rode linter: `ruff check .`
3. Rode type-check: `mypy src/`
4. Verifique cobertura: `pytest --cov=src --cov-report=term-missing`
5. Se tudo passar:
   - `git add .`
   - `git commit -m "feat: [descrição da feature]"`
   - `git push origin [branch]`
6. Se algo falhar, pare e corrija antes de commitar
```

**Dica crucial:** Não tente criar todas as skills de uma vez. Uma skill que você usa todo dia vale mais que dez skills que você nunca usa.

### Erros a evitar

- Skills muito complexas (comece com 5-7 passos, não 50)
- Não testar antes de usar em produção
- Esquecer de atualizar (reveja mensalmente)
- Não ter fallback manual se a AI estiver offline

## Benefícios práticos

Depois de implementar esses dois sistemas, minha produtividade mudou significativamente:

**Não perco contexto entre sessões.** Abro o terminal, o AI CLI já sabe onde paramos, o que foi decidido, o que falta fazer.

**Não repito setup.** Novo projeto? Copio a estrutura de arquivos, adapto, pronto. Não começo do zero.

**Workflows são reproduzíveis.** Se funciona uma vez, funciona sempre. Consistência que não existia antes.

**Posso delegar tarefas rotineiras.** CRUDs, endpoints padrão, boilerplate — código mecânico que antes me tomava tempo agora é gerado com supervisão mínima. Foco no que realmente precisa de pensamento.

**Mentalidade mudou.** Antes eu *escrevia código*. Agora eu *orquestro sistemas que escrevem código*. Nível de abstração diferente.

## Como começar (resumão)

Se você só lembrou de uma coisa desse artigo:

1. Hoje: Crie `SOUL.md` com quem você é e como gosta de codar
2. Amanhã: Crie uma skill pra tarefa que você mais repete
3. Essa semana: Use em uma tarefa real e ajuste o que não funcionou
4. Próxima semana: Crie mais uma skill

Não precisa ser perfeito. Perfeito é inimigo de funcionando.

O segredo é começar pequeno e iterar. ARS Contexta e OrbitOS não são frameworks rígidos — são convenções que você adapta pro seu fluxo. Quanto mais você usa, mais descobre o que funciona pra você.

---

**Resumo em uma frase:** Memória persistente + workflows automatizados = AI que realmente trabalha com você.

---

*Esse artigo faz parte da minha série sobre agentic engineering. Para mais sobre como uso AI agents no desenvolvimento, me siga no [GitHub](https://github.com/nat-rib) ou acompanhe o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
