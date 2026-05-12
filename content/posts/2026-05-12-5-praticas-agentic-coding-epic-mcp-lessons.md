---
title: "Context Is a Scarce Resource: 5 Agentic Coding Practices"
date: 2026-05-12
description: "Five practices that separate those who play with AI agents from those who ship to production."
tags: ["agentic-coding", "EPIC", "MCP", "context-engineering", "lessons-md"]
categories: ["AI Development", "Agentic Engineering"]
slug: "5-praticas-agentic-coding-epic-mcp-lessons"
keywords:
  - agentic coding practices
  - EPIC framework
  - MCP token optimization
  - lessons.md pattern
  - silent fake success
  - context engineering
draft: false
---

There's a difference between *having* an AI agent running and *knowing how to use* one. The first is easy. The second takes discipline.

Over the past few months, I've been reading a lot about agentic coding across articles on the internet. The pattern that emerges among devs who actually ship isn't about smarter prompts — it's about **context control**, **lean scope**, and **failure memory**.

Five practices. The concepts are universal.

## The Core Problem

LLMs aren't "infinitely smart." They have a hard constraint: **context window**. And it's not just the size — it's the quality of what you put in it.

Every irrelevant file, every inactive tool schema, every vague instruction the model has to interpret — it all burns tokens that could have been used for code, reasoning, and decision-making.

> Context is a scarce resource. Treat it as such.

---

## 1. `.claudeignore` and `CLAUDE.md` — Before the First Message

### `.claudeignore`

Works like `.gitignore`, but for the agent's context. Configure what it **should not see** before you start:

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

Sessions start faster. Context goes to what actually matters.

### `CLAUDE.md` with rules, not observations

A bad `CLAUDE.md` is a list of observations. A good one is a set of **behavior-changing rules**.

**Bad:**
```markdown
- The project uses Python.
- We prefer clean code.
```

**Good:**
```markdown
- Type hints mandatory on all public functions
- Never use bare `except:` — always log the error
- F-strings for formatting, never `%` or `.format()`
```

The first the model reads and forgets. The second it **applies**.

In Cursor, it would be `.cursorrules`. In Claude Code, `CLAUDE.md`. The name changes. The function is the same: define the project's DNA before the first message.

---

## 2. The EPIC Cycle — You Are a Co-Author of the Plan

The framework is simple:

```
Explore → Plan → Implement → Commit
```

The detail that changes everything: **at the Plan stage, you don't approve an agent's plan. You are a co-author of it.**

In Claude Code, `Ctrl+G` opens the plan in the editor before you approve. The mechanism varies by tool. The discipline is the same.

My rule: any task touching more than 3 files requires **Plan before Implement**. Non-negotiable. This is where you avoid the agent refactoring half your codebase because "it seemed related."

---

## 3. MCP Without Bloat

Every active MCP server injects its full tool schema on every turn, even when you use none of its tools.

5 active servers = over **18,000 tokens per message** in schemas alone.

The solution: **task-scoped sessions**.

```bash
# Backend session
claude --mcp postgres,fastapi,pytest

# Infra session
claude --mcp aws,terraform,github
```

Don't pay context tax for tools you won't use. You don't carry the full toolbox to change a lightbulb.

---

## 4. `lessons.md` — Memory Against the Bug That Comes Back

Have you seen this?

1. The agent reports success
2. Tests pass
3. Deploy
4. Production breaks

What happened? The agent put a mock in production code. Or silenced an exception. Tests passed because the agent tested the mock, not reality. This has a name: **Silent Fake Success**.

The solution: `lessons.md` at the project root.

```markdown
# lessons.md

## 2026-05-10: Mock in production
- **Problem**: `MockPaymentGateway()` in `services/payment.py`
- **Rule**: Never approve PRs with `Mock*` outside `tests/`
- **Check**: `grep -r "Mock\|Fake" src/` in pre-commit

## 2026-04-22: Silenced exception
- **Problem**: `except Exception: pass` in `worker.py`
- **Rule**: bare `except:` is forbidden
```

This isn't generic documentation. It's a **record of failures that must not repeat**. When I ask the agent to work on `services/payment.py`, I start with: "Read `lessons.md` first."

Within three months, this became an immune system against recurring failures.

---

## The Pattern

| Practice | Solves |
|----------|--------|
| `.claudeignore` | Polluted context |
| `CLAUDE.md` | Vague instructions |
| **EPIC Cycle** | Missing oversight |
| **Scoped MCP** | Wasted tokens |
| **`lessons.md`** | Bugs that come back |

Each one fixes a different context leak. Together, they form a system where the agent works with high-quality information, controlled scope, and memory of past failures.

## Where to Start

1. **Now (5 min)**: Create `.claudeignore`. List the 10 largest directories your agent never needs to read.
2. **Today (15 min)**: Edit your `CLAUDE.md`. Turn 3 observations into concrete rules.
3. **This week**: On the next plan with 3+ files, edit it before approving.
4. **This week**: Disable half your MCP servers. Measure the difference.
5. **Today**: Create `lessons.md` with the last failure you fixed manually.

The investment is minutes. The return is an agent that stops being an improvised assistant and becomes a reliable tool.

---

*This article is part of the "Agentic Engineering in Practice" series. Previous: [Context Engineering with Claude Code](/posts/context-engineering-claude-code/).*

*Follow me on [GitHub](https://github.com/nat-rib) or check the [blog](https://nat-rib.github.io/nataliaribeiro.github.io/) for more on agentic engineering.*
