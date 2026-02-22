---
title: "ARS Contexta + OrbitOS: How I Organized My Development with AI CLI"
date: 2026-02-21
description: "The two systems that created an 'organized memory' for my AI CLI to work with: structured context + workflow orchestration."
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

**How to transform AI CLI tools into a development environment with persistent memory and real automation.**

If you use AI to program every day, you've already noticed: the tool is brilliant… until you close the session.

## The Real Problem

Everyone who uses AI CLI tools like Claude Code or OpenCode faces the same problem: in the first session, the tool is incredible. It understands what you want, generates good code, accelerates your work. By the fifth session, you realize you're repeating the same explanations. By the tenth, you give up and accept that each session is reinventing the wheel.

The problem isn't the tool. It's that it has no memory — or rather, no *organized* memory.

Two weeks ago I decided to solve this. I found two open source systems that work together: one to store and retrieve context, another to orchestrate workflows. They're not ready-to-use tools. They're structures I adapted to my workflow. They work so well that now I can't work without them.

When you open a session with Claude Code or OpenCode, the model knows how to program. It knows Python, JavaScript, software architecture, design patterns. What it doesn't know is:

- That you prefer `async/await` over chained promises
- That this project uses a specific layered architecture
- That you've already tried that approach and it caused problems
- That you have a specific naming pattern for variables
- That you hate when code generates linter warnings

You can explain all this in each session. But it's 5-10 minutes of setup before you start working. Multiply that by 3 sessions per day, 5 days a week. You lose an hour just repeating context.

And there's the second problem: repetitive tasks. Every time I finish a feature, I do the same ritual: run tests, check lint, commit with descriptive message, open PR, notify the team. It's mechanical. It should be automatic.

## ARS Contexta — The Memory That Persists

[ARS Contexta](https://github.com/agenticnotetaking/arscontexta) (Auto-Retrieval of Semantic Context) is the system that solves the first problem. It's a file structure and conventions that keeps project context accessible to the AI CLI.

The original project was created by the agentic note-taking community as a way to transform conversations into organized "knowledge vaults." The idea comes from ancient arts — Ars Combinatoria, Ars Memoria — external thinking systems that amplify the human mind.

Here's how it works:

**Reference documents** — files that describe what the project is, how it's structured, what the architectural decisions are. Things that don't change much, but that the AI needs to know to avoid suggesting nonsense.

**Session memory** — logs of what was done in each interaction. Not just "what was done," but *why* it was done that way. Decisions, errors found, discarded solutions.

**Accumulated knowledge** — learnings that go beyond the specific project. Patterns that work, anti-patterns that always cause problems, personal style preferences.

In practice, when I start a session, the AI CLI reads these files before starting. It knows who I am, how I work, what the project is, what has already been decided. I don't need to repeat.

### How I adapted it to my workflow

I organized my project folder with some specific files:

- **SOUL.md** — who I am as a developer, my approach, code values
- **USER.md** — information about the user/product context I'm building
- **MEMORY.md** — long-term memory, important architectural decisions
- **Daily files** — `2026-02-16.md` with what was done today, decisions, errors
- **TOOLS.md** — notes about specific tools I use (databases, APIs, libs)

The magic isn't having the files. It's having a convention that the AI CLI can follow. When I ask "read yesterday's memory before starting," it knows exactly which file to look for.

## OrbitOS — The Workflow Orchestrator

[OrbitOS](https://github.com/MarsWang42/OrbitOS) is the system that solves the *execution* problem. It's a workflow and automation system that orchestrates repetitive tasks.

The original project is described as an "AI-powered personal productivity system," where knowledge management and task planning are orchestrated by your AI assistant.

The central idea: tasks I do frequently should be reproducible without me having to remember each step.

It works in three layers:

**Automated workflows** — sequences of steps that run on their own. Deploy, tests, builds, releases.

**Reusable skills** — playbooks for common tasks. "How to write a technical article," "how to review code," "how to investigate a production bug." Each skill is a set of detailed instructions that the AI CLI follows.

**Integrations** — connection with external tools. Git, Docker, third-party APIs, notifications.

### How I adapted it to my workflow

I created "skills" for tasks I do repeatedly:

- **Writing skill** — article structure, tone of voice, quality checklist
- **Review skill** — what to check in code review, project patterns
- **Deploy skill** — deploy steps, security checks, rollback

Each skill is a markdown file with detailed instructions. When I need to execute that task, I load the skill into context and the AI CLI follows the playbook.

I also automated infrastructure workflows. I have jobs that run at specific times, check if services are working, send alerts if something breaks. If the main workflow fails, I have fallbacks that ensure the task will still be done.

## The Two Working Together

Separately, each system is useful. Together, they're transformative.

Here's a real example of how they work together:

I ask the AI CLI: *"Implement a CSV data processing function that validates schemas and generates an error report"*

**ARS Contexta springs into action:**
- Searches `SOUL.md` to know my patterns (Python 3.11+, mandatory type hints, prefer pure `pandas` when possible)
- Reads `MEMORY.md` to see architectural decisions (we use layered architecture, clear separation between parsing/validation/processing)
- Checks `TOOLS.md` about the stack (Pydantic for validation, pytest for tests, ruff/mypy for quality)
- Looks at daily files to see what was recently implemented (avoid conflicts with existing parsers)

**OrbitOS springs into action:**
- Loads skill for "Implement data pipeline"
- Executes:
  1. Creates Pydantic schema for CSV column validation
  2. Implements `parse_csv` function with encoding handling
  3. Implements `validate_rows` function with error accumulation
  4. Implements `generate_error_report` function with statistics
  5. Writes unit tests with edge cases (empty CSV, wrong encoding, null fields)
  6. Writes integration tests with real files
- Runs `ruff check .` and `mypy src/` automatically
- Runs `pytest tests/ -v` to ensure nothing broke
- Does git add, commit following conventional commits: `feat(data): add CSV processing pipeline`

The result: in ~15 minutes I have a complete, tested, typed, documented feature. Without ARS, the AI would have generated generic code that doesn't follow my patterns. Without OrbitOS, I'd have to manually remember to run lint, type-check, and write tests — and would probably forget something.

## What I learned implementing this (and how you can start now)

After two weeks using ARS Contexta and OrbitOS, here's the practical guide I wish I'd had on day one:

### Day 1: Set up ARS Contexta (30 minutes)

**Step 1:** Create a `SOUL.md` file at the root of your project:
```markdown
# SOUL.md

## Who I am
- I'm [your name], dev [specialty] for [X] years
- I prefer explicit code over "clever" code
- I like type hints on everything
- I hate linter warnings

## Favorite stack
- Python 3.11+ / TypeScript
- Pydantic for validation
- Pytest for tests
- Ruff + mypy for quality

## Principles
- Tests before implementing
- Docstrings in public functions
- Atomic commits with clear messages
```

**Step 2:** Create an empty `MEMORY.md`. You'll fill it as you make important decisions.

**Step 3:** At the start of each Claude Code session, ask: *"Read SOUL.md and MEMORY.md before starting"*

Done. You now have persistent context.

### Day 2-3: Create your first OrbitOS Skill (45 minutes)

Choose a task you do at least 3x per week. Example: "Create function with tests"

Create the file `skills/create-function.md`:
```markdown
# Skill: Create Function with Tests

## When to use
When implementing a new business function

## Steps
1. Create function signature with type hints
2. Write 3 tests BEFORE implementing:
   - Happy case
   - Error case (exception)
   - Edge case (empty/null)
3. Implement minimum function to pass tests
4. Refactor if necessary
5. Run `pytest tests/ -v` and fix if it fails
6. Run `ruff check . && mypy src/` and fix if it fails
7. Commit: `feat: add [function-name]`

## Quality checklist
- [ ] Type hints on all parameters and return
- [ ] Docstring describing what it does
- [ ] At least 3 tests
- [ ] Linter passing
- [ ] Type-check passing
```

To use: *"Load skill 'create-function' and implement a function that [description]"*

### Day 4-7: Iterate and expand

- For every important decision, add to `MEMORY.md`
- When you notice you're repeating instructions, create a skill
- When a skill doesn't work well, edit it

### Week 2: Automate a complete workflow

Choose a ritual you always do. Example: "Complete a feature"

Create `skills/complete-feature.md`:
```markdown
# Skill: Complete Feature

## Steps
1. Run all tests: `pytest tests/ -v`
2. Run linter: `ruff check .`
3. Run type-check: `mypy src/`
4. Check coverage: `pytest --cov=src --cov-report=term-missing`
5. If everything passes:
   - `git add .`
   - `git commit -m "feat: [feature description]"`
   - `git push origin [branch]`
6. If something fails, stop and fix before committing
```

**Crucial tip:** Don't try to create all skills at once. One skill you use every day is worth more than ten skills you never use.

### Mistakes I made (and you can avoid)

**Mistake 1:** Creating overly complex skills. Start with 5-7 steps, not 50.

**Mistake 2:** Not testing the skill. Always test a new skill on a small task before using it for something important.

**Mistake 3:** Forgetting to update. Skills get outdated. Review once a month.

**Mistake 4:** Not having a fallback. If the AI CLI is offline, you still need to know how to do the task manually.

## Practical Benefits

After implementing these two systems, my productivity changed significantly:

**I don't lose context between sessions.** I open the terminal, the AI CLI already knows where we left off, what was decided, what's left to do.

**I don't repeat setup.** New project? I copy the file structure, adapt, done. I don't start from scratch.

**Workflows are reproducible.** If it works once, it always works. Consistency that didn't exist before.

**I can delegate routine tasks.** CRUDs, standard endpoints, boilerplate — mechanical code that used to take my time is now generated with minimal supervision. I focus on what really needs thinking.

**Mindset changed.** Before I *wrote code*. Now I *orchestrate systems that write code*. Different level of abstraction.

## How to start (summary)

If you only remember one thing from this article:

1. Today: Create `SOUL.md` with who you are and how you like to code
2. Tomorrow: Create a skill for the task you repeat most
3. This week: Use it on a real task and adjust what didn't work
4. Next week: Create one more skill

It doesn't need to be perfect. Perfect is the enemy of working.

The secret is to start small and iterate. ARS Contexta and OrbitOS aren't rigid frameworks — they're conventions you adapt to your workflow. The more you use them, the more you discover what works for you.

---

**Summary in one sentence:** Persistent memory + automated workflows = AI that actually works with you.

---

*This article is part of my series on agentic engineering. For more on how I use AI agents in development, follow me on [GitHub](https://github.com/nat-rib) or check the [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
