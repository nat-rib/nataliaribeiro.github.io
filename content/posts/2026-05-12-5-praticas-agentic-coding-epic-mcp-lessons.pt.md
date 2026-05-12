---
title: "Contexto é Recurso Escasso: 5 Práticas de Agentic Coding"
date: 2026-05-12
description: "Cinco práticas que separam quem brinca de agentes de IA de quem entrega em produção."
tags: ["agentic-coding", "EPIC", "MCP", "context-engineering", "lessons-md"]
categories: ["AI Development", "Agentic Engineering"]
slug: "5-praticas-agentic-coding-epic-mcp-lessons"
keywords:
  - agentic coding práticas
  - framework EPIC
  - MCP tokens otimização
  - lessons.md pattern
  - silent fake success
  - context engineering
draft: false
---

Tem uma diferença entre *ter* um agente de IA rodando e *saber usar* um agente de IA. A primeira é fácil. A segunda exige disciplina.

Nos últimos meses, andei lendo bastante sobre agentic coding em artigos pela internet. O padrão que emerge entre devs que entregam não é sobre prompts mais inteligentes — é sobre **controle de contexto**, **escopo enxuto** e **memória de falhas**.

São cinco práticas. Os conceitos são universais.

## O Problema Central

LLMs não são "inteligentes infinitos". Eles têm uma restrição dura: **janela de contexto**. Cada arquivo irrelevante, cada schema de ferramenta inativa, cada instrução vaga — tudo consome tokens que poderiam ser usados para código e raciocínio.

> Contexto é recurso escasso. Trate assim.

---

## 1. `.claudeignore` e `CLAUDE.md` — Antes da Primeira Mensagem

### `.claudeignore`

Funciona como `.gitignore`, mas para o contexto do agente. Configure o que ele **não deve enxergar** antes de começar:

```
node_modules/
*.lock
vendor/
dist/
build/
*.min.js
*.png
*.jpg
.env*
coverage/
```

Sessões iniciam mais rápido. O contexto sobra para o que importa.

### `CLAUDE.md` com regras, não observações

Um `CLAUDE.md` ruim é uma lista de observações. Um eficaz é um conjunto de **regras que mudam comportamento**.

**Ruim:**
```markdown
- O projeto usa Python.
- Preferimos código limpo.
```

**Bom:**
```markdown
- Type hints obrigatórios em funções públicas
- Nunca usar `except:` vazio — sempre logar
- F-strings para formatação, nunca `%` ou `.format()`
```

O primeiro o modelo lê e esquece. O segundo ele **aplica**.

No Cursor, seria `.cursorrules`. No Claude Code, `CLAUDE.md`. O nome muda. A função é a mesma: definir o DNA do projeto antes da primeira mensagem.

---

## 2. O Ciclo EPIC — Você É Co-Autor do Plano

O framework é simples:

```
Explore → Plan → Implement → Commit
```

O detalhe que muda tudo: **no estágio Plan, você não aprova um plano do agente. Você é co-autor dele.**

No Claude Code, `Ctrl+G` abre o plano no editor antes de aprovar. O mecanismo varia conforme o tool. A disciplina é a mesma.

Minha regra: qualquer tarefa com mais de 3 arquivos exige **Plan obrigatório antes de Implement**. É onde você evita o agente refatorando meio codebase porque "parecia relacionado".

---

## 3. MCP Sem Inchaço

Cada servidor MCP ativo injeta o schema completo em cada turno, mesmo quando você não usa nenhuma ferramenta.

5 servidores ativos = mais de **18.000 tokens por mensagem** só em schemas.

A solução: **sessões com escopo de tarefa**.

```bash
# Sessão de backend
claude --mcp postgres,fastapi,pytest

# Sessão de infra
claude --mcp aws,terraform,github
```

Não pague taxa de contexto por ferramentas que não vai usar. Você não carrega a caixa de ferramentas completa para trocar uma lâmpada.

---

## 4. `lessons.md` — Memória Contra o Bug que Volta

Você já viu isso?

1. O agente reporta sucesso
2. Testes passam
3. Deploy
4. Produção quebra

O agente colocou um mock em código de produção. Ou silenciou uma exceção. Os testes passaram porque o agente testou o mock, não a realidade. Isso tem nome: **Silent Fake Success**.

A solução: `lessons.md` na raiz do projeto.

```markdown
# lessons.md

## 2026-05-10: Mock em produção
- **Problema**: `MockPaymentGateway()` em `services/payment.py`
- **Regra**: Nunca aprovar PR com `Mock*` fora de `tests/`
- **Verificação**: `grep -r "Mock\|Fake" src/` no pre-commit

## 2026-04-22: Exceção silenciada
- **Problema**: `except Exception: pass` em `worker.py`
- **Regra**: `except:` vazio é proibido
```

Não é documentação genérica. É **registro de falhas que não podem se repetir**. Quando peço ao agente para trabalhar em `services/payment.py`, começo com: "Leia `lessons.md` antes."

Em três meses, isso virou um sistema imunológico contra falhas recorrentes.

---

## O Padrão

| Prática | Resolve |
|---------|---------|
| `.claudeignore` | Contexto poluído |
| `CLAUDE.md` | Instruções vagas |
| **Ciclo EPIC** | Supervisão ausente |
| **MCP com escopo** | Tokens desperdiçados |
| **`lessons.md`** | Bugs que voltam |

Cada uma resolve um vazamento de contexto. Juntas, formam um sistema onde o agente trabalha com informação de alta qualidade e memória de falhas.

## Por Onde Começar

1. **Agora (5 min)**: Crie `.claudeignore`. Liste os 10 maiores diretórios que o agente nunca precisa ler.
2. **Hoje (15 min)**: Edite seu `CLAUDE.md`. Transforme 3 observações em regras concretas.
3. **Esta semana**: No próximo plano com +3 arquivos, edite antes de aprovar.
4. **Esta semana**: Desative metade dos seus MCP servers. Meça a diferença.
5. **Hoje**: Crie `lessons.md` com a última falha que você corrigiu manualmente.

O investimento é minutos. O retorno é um agente que deixa de ser assistente improvisado e vira ferramenta confiável.

---

*Esse artigo faz parte da série "Agentic Engineering na Prática". Semana anterior: [Context Engineering com Claude Code](/pt/posts/context-engineering-claude-code/).*

*Me siga no [GitHub](https://github.com/nat-rib) ou acompanhe o [blog](https://nat-rib.github.io/nataliaribeiro.github.io/) para mais sobre agentic engineering.*
