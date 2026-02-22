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

[ARS Contexta](https://github.com/agenticnotetaking/arscontexta) (Auto-Retrieval de Contexto Semântico) é o sistema que resolve o primeiro problema. É uma estrutura de arquivos e convenções que mantém o contexto do projeto acessível pro AI CLI.

O projeto original foi criado pela comunidade de agentic note-taking como uma forma de transformar conversas em "cofres de conhecimento" organizados. A ideia vem das artes antigas — Ars Combinatoria, Ars Memoria — sistemas externos de pensamento que amplificam a mente humana.

Funciona assim:

**DOCUMENTOS de referência** — arquivos que descrevem o que o projeto é, como é estruturado, quais são as decisões arquiteturais. Coisas que não mudam muito, mas que o AI precisa saber pra não sugerir besteira.

**MEMÓRIA de sessão** — logs do que foi feito em cada interação. Não é só "o que foi feito", mas *por que* foi feito daquela forma. Decisões, erros encontrados, soluções descartadas.

**CONHECIMENTO acumulado** — aprendizados que vão além do projeto específico. Padrões que funcionam, anti-patterns que sempre dão problema, preferências pessoais de estilo.

Na prática, quando inicio uma sessão, o AI CLI lê esses arquivos antes de começar. Ele sabe quem eu sou, como trabalho, qual é o projeto, o que já foi decidido. Não preciso repetir.

### Como adaptei pro meu fluxo

Organizei minha pasta de projeto com alguns arquivos específicos:

- **SOUL.md** — quem eu sou como desenvolvedora, minha abordagem, valores de código
- **USER.md** — informações sobre o contexto do usuário/produto que estou construindo
- **MEMORY.md** — memória de longo prazo, decisões arquiteturais importantes
- **Arquivos diários** — `2026-02-16.md` com o que foi feito hoje, decisões, erros
- **TOOLS.md** — notas sobre ferramentas específicas que uso (bancos, APIs, libs)

A mágica não é ter os arquivos. É ter uma convenção que o AI CLI consegue seguir. Quando peço "leia a memória de ontem antes de começar", ele sabe exatamente qual arquivo buscar.

## OrbitOS — O orquestrador de workflows

[OrbitOS](https://github.com/MarsWang42/OrbitOS) é o sistema que resolve o problema de *execução*. É um sistema de workflows e automação que orquestra tarefas repetitivas.

O projeto original é descrito como um "sistema de produtividade pessoal powered by AI", onde gerenciamento de conhecimento e planejamento de tarefas são orquestrados pelo seu assistente de AI.

A ideia central: tarefas que faço frequentemente devem ser reproduzíveis sem que eu precise lembrar cada passo.

Funciona em três camadas:

**WORKFLOWS automatizados** — sequências de passos que rodam sozinhas. Deploy, testes, builds, releases.

**SKILLS reutilizáveis** — playbooks pra tarefas comuns. "Como escrever um artigo técnico", "como revisar código", "como investigar um bug em produção". Cada skill é um conjunto de instruções detalhadas que o AI CLI segue.

**INTEGRAÇÕES** — conexão com ferramentas externas. Git, Docker, APIs de terceiros, notificações.

### Como adaptei pro meu fluxo

Criei "skills" pra tarefas que faço repetidamente:

- **Skill de escrita** — estrutura de artigos, tom de voz, checklist de qualidade
- **Skill de revisão** — o que verificar em code review, padrões do projeto
- **Skill de deploy** — passos de deploy, verificações de segurança, rollback

Cada skill é um arquivo markdown com instruções detalhadas. Quando preciso executar aquela tarefa, carrego a skill pro contexto e o AI CLI segue o playbook.

Também automatizei workflows de infraestrutura. Tenho jobs que rodam em horários específicos, verificam se serviços estão funcionando, enviam alertas se algo quebra. Se o workflow principal falha, tenho fallbacks que garantem que a tarefa ainda será feita.

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

## Steps
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

### Erros que cometi (e você pode evitar)

**Erro 1:** Criar skills muito complexas. Comece com 5-7 passos, não 50.

**Erro 2:** Não testar a skill. Sempre teste uma nova skill numa tarefa pequena antes de usar pra algo importante.

**Erro 3:** Esquecer de atualizar. Skills ficam desatualizadas. Reveja uma vez por mês.

**Erro 4:** Não ter fallback. Se o AI CLI estiver offline, você ainda precisa saber fazer a tarefa manualmente.

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

---

*Esse artigo faz parte da minha série sobre agentic engineering. Para mais sobre como uso AI agents no desenvolvimento, me siga no [GitHub](https://github.com/nat-rib) ou acompanhe o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
