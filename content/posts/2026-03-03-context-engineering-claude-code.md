---
title: "Context Engineering: How CLAUDE.md, Hooks, and Skills Turn Claude Code into a Personalized Agent"
date: 2026-03-03
description: "Context engineering is the #1 skill for agentic coding. See how CLAUDE.md, hooks, and slash commands transform Claude Code from a generic assistant into an agent that knows you, your project, and your workflow."
tags: ["context-engineering", "claude-code", "hooks", "skills", "agentic-coding", "customization"]
categories: ["AI Development", "Agentic Engineering"]
slug: "context-engineering-claude-code"
keywords:
  - context engineering
  - CLAUDE.md
  - hooks
  - skills
  - Claude Code
  - customization
  - agentic coding
  - slash commands
draft: false
---

**Context engineering isn't about prompt engineering. It's about building the environment that makes AI work as if it already knows you.**

If you use Claude Code (or any AI CLI) every day, you've been through this: in the first session, everything works. By the tenth, you realize you're repeating the same instructions. The model is powerful — but it starts from scratch every time.

The problem was never the model's intelligence. It was the **context**.

## What is Context Engineering

In January 2026, Anthropic published the [agentic coding trends report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf) that positions **context engineering** as the most important skill for anyone working with AI agents. This is no exaggeration: 57% of companies already run AI agents in production, and the difference between "works sort of" and "actually works" is almost always context.

Context engineering is the practice of **designing the informational environment** around the model. It's not about writing better prompts — it's about ensuring the model has access to what it needs *before* you ask for anything.

In Claude Code, this translates to three mechanisms:

| Mechanism | What it does | When it acts |
|-----------|-------------|--------------|
| **CLAUDE.md** | Defines identity, rules, and conventions | Always (loaded automatically) |
| **Hooks** | Injects context and validates output automatically | On specific events (start, write, end) |
| **Slash Commands** | Reusable on-demand workflows | When you invoke them |

Together, they transform Claude Code from a generic assistant into a **personalized agent** that knows your project, your style, and your rules.

## CLAUDE.md — Your Project's DNA

The `CLAUDE.md` file at the project root is the first file Claude Code reads on startup. It's your chance to tell the model everything it needs to know *without repeating it every session*.

A bad CLAUDE.md is a list of generic rules. An effective CLAUDE.md is a **context charter** that changes the model's behavior in observable ways.

### Anatomy of a real CLAUDE.md

Here's the structure of the CLAUDE.md I use in my Obsidian vault (edited for clarity):

```markdown
# OrbitOS Vault — Claude Code CLI

Obsidian vault managed by **Natalia** with two agents:
Claude Code CLI (this one) and R2-D2 (OpenClaw).

## Identity
- **User:** Natalia
- **Language:** Brazilian Portuguese
- **R2-D2:** OpenClaw Agent (Claude Haiku) — daily crons
- **Claude CLI:** This context — direct interactions, knowledge pipeline

## OrbitOS Structure
00_Inbox/        → Quick capture, unprocessed ideas
10_Daily/        → Daily notes (YYYY-MM-DD.md)
20_Project/      → Active projects
40_Wiki/         → Atomic concepts + Claims/
99_System/       → Configuration, Archives, MOCs, Templates

## Writing Rules

### YAML Frontmatter (required)
title: "Descriptive title"
description: "One-line content explanation"
tags: [tag1, tag2]
created: YYYY-MM-DD

### Conventions
- **Wiki Links:** [[Note Name]] to connect
- **Claims as prose** — title works as assertion
- **Never delete notes** — move to Archives/
- **Check for duplicates** before creating new notes
```

### What makes a CLAUDE.md work

There are four sections that make a real difference:

**1. Identity and scope** — Who uses it, what language, what's this agent's role. Without this, Claude might respond in the wrong language, ignore naming conventions, or conflict with other agents.

**2. Project structure** — Clear folder map and what each contains. The model uses this to know *where* to put things. Without the map, it creates files in wrong locations.

**3. Writing rules** — Required schemas, naming conventions, frontmatter patterns. Rules you'd verify manually if the model didn't know them.

**4. Known tensions** — This is the differentiator. Documenting problems you've already identified ("system captures too much, executes too little") changes how the model prioritizes suggestions.

### CLAUDE.md anti-patterns

- **Being too vague:** "Write clean code" changes nothing. "Use type hints on all parameters and returns, docstrings only on public functions" does.
- **Being too long:** If it goes past 200 lines, the model dilutes context. Be surgical.
- **Not updating:** An outdated CLAUDE.md is worse than none — it generates incorrect behavior with confidence.

## Hooks — Invisible Automation

Hooks are shell scripts that run automatically on Claude Code events. They're the most powerful and least discussed context engineering mechanism.

There are three types of hooks I use in practice:

### Hook 1: Session Orient (SessionStart)

**What it does:** Injects vault context at the start of every session. Claude already knows the current project state before you type anything.

```json
// .claude/settings.local.json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/session-orient.sh",
        "timeout": 10
      }]
    }]
  }
}
```

The actual script:

```bash
#!/bin/bash
# OrbitOS — Session Orientation Hook

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Session tracking
SESSION_ID=$(echo "$(cat)" | jq -r '.session_id // empty')
mkdir -p 99_System/sessions
TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")

# Archive previous session if different
if [ -f 99_System/sessions/current.json ]; then
  PREV_ID=$(jq -r '.id // empty' 99_System/sessions/current.json)
  if [ "$PREV_ID" != "$SESSION_ID" ]; then
    mv 99_System/sessions/current.json \
       "99_System/sessions/${TIMESTAMP}.json"
  fi
fi

# Register new session
cat > 99_System/sessions/current.json << EOF
{"id": "$SESSION_ID", "started": "$TIMESTAMP", "status": "active"}
EOF

# Inject context
echo "## OrbitOS Vault — Session Start"

# Inbox status
INBOX_COUNT=$(find 00_Inbox/ -name "*.md" | wc -l | tr -d ' ')
[ "$INBOX_COUNT" -gt 0 ] && echo "INBOX: $INBOX_COUNT pending items"

# Latest daily plan
LATEST_PLAN=$(ls -t 10_Daily/20*.md 2>/dev/null | head -1)
[ -n "$LATEST_PLAN" ] && head -30 "$LATEST_PLAN"

# Previous session
[ -f 99_System/sessions/current.json ] && \
  cat 99_System/sessions/current.json
```

**The effect:** When starting a session, Claude already knows how many items are in the inbox, what the latest daily plan was, and what happened in the previous session. Without this hook, I'd spend 2-3 minutes explaining "where we left off."

### Hook 2: Write Validate (PostToolUse)

**What it does:** Every time Claude writes a `.md` file in the vault, the hook checks if the YAML frontmatter is correct. If `description`, `tags`, or required claim fields are missing, the hook returns a warning that Claude reads and fixes automatically.

```bash
#!/bin/bash
# Validate YAML schema in vault notes

FILE=$(echo "$(cat)" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

case "$FILE" in
  */00_Inbox/*|*/40_Wiki/*|*/99_System/*)
    WARNS=""
    head -1 "$FILE" | grep -q "^---$" || WARNS+="Missing YAML. "
    head -20 "$FILE" | grep -q "^description:" || WARNS+="Missing description. "
    head -20 "$FILE" | grep -q "^tags:" || WARNS+="Missing tags. "

    # Claims need type and domain
    case "$FILE" in
      */40_Wiki/Claims/*)
        head -20 "$FILE" | grep -q "^type: claim" || WARNS+="Missing type. "
        head -20 "$FILE" | grep -q "^domain:" || WARNS+="Missing domain. "
        ;;
    esac

    [ -n "$WARNS" ] && echo "{\"additionalContext\": \"Schema warnings: $WARNS\"}"
    ;;
esac
```

**The effect:** Before this hook, ~30% of notes created by Claude had incomplete frontmatter. After, virtually zero. The model receives the feedback and fixes it in the same operation.

### Hook 3: Session Capture (Stop)

**What it does:** When ending a session, saves the current state — which files were modified, start/end timestamps — and auto-commits the session state.

```bash
#!/bin/bash
# Capture state when closing session

TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")

# Update status to "ended"
jq --arg ts "$TIMESTAMP" '.status = "ended" | .ended = $ts' \
  99_System/sessions/current.json > tmp.json && mv tmp.json \
  99_System/sessions/current.json

# Capture modified files
MODIFIED=$(git diff --name-only HEAD~5 | head -20)
MODIFIED_JSON=$(echo "$MODIFIED" | jq -R -s 'split("\n") | map(select(. != ""))')
jq --argjson files "$MODIFIED_JSON" '.files_modified = $files' \
  99_System/sessions/current.json > tmp.json && mv tmp.json \
  99_System/sessions/current.json

# Auto commit
git add 99_System/sessions/
git commit -m "Session end: $TIMESTAMP" --quiet 2>/dev/null
```

**The effect:** Continuity between sessions. When session-orient runs in the next session, it reads `current.json` and Claude knows exactly where it left off.

### The three-hook cycle

```
┌─ SessionStart ──────────────────────┐
│  session-orient.sh                  │
│  → Injects: inbox, plan, session   │
│  → Claude starts with context      │
└─────────────────────────────────────┘
          ↓ (active session)
┌─ PostToolUse (Write) ──────────────┐
│  write-validate.sh                  │
│  → Validates YAML frontmatter      │
│  → Claude auto-corrects            │
└─────────────────────────────────────┘
          ↓ (session ends)
┌─ Stop ──────────────────────────────┐
│  session-capture.sh                 │
│  → Saves state, touched files      │
│  → Auto commit                     │
│  → Feeds next session-orient       │
└─────────────────────────────────────┘
```

## Slash Commands — On-Demand Workflows

Custom slash commands are `.md` files inside `.claude/commands/` that become `/filename` commands in Claude Code. They're the most elegant way to create **reusable workflows**.

### Real examples I use daily

These slash commands are part of the OrbitOS system I use to orchestrate productivity with AI CLI. If you want to understand how it works in depth, I wrote about it in [ARS Contexta + OrbitOS: How I Organized My Development with AI CLI](/posts/ars-contexta-orbitos-ai-cli/).

**`/start-my-day`** — Daily planning. The command reads the latest plan in `10_Daily/`, checks task carry-over, analyzes active projects in `20_Project/`, and generates the day's plan.

```markdown
# /start-my-day — OrbitOS Daily Planning

## Instructions

### Steps
1. Read the latest Daily Plan in 10_Daily/
2. Read the latest PDCA/Learning in Archives/
3. Check active projects in 20_Project/
4. Generate today's plan with priorities
```

**`/pipeline`** — End-to-end knowledge processing pipeline. Takes a source (URL, file, text) and runs the 6Rs pipeline: Record → Reduce → Reflect → Reweave → Verify. Transforms raw material into atomic claims connected to the knowledge graph.

**`/rethink`** — Metacognitive analysis. Challenges system assumptions, identifies contradictions, gaps, and tensions. The highest level of the pipeline — metacognition about the knowledge system itself.

**`/health`** — Quick diagnostics. Counts files, checks recent activity, assesses overall vault health. Lightweight version of `/verify`.

### How to create your own slash command

Create a `.md` file in `.claude/commands/`:

```markdown
# /my-command — Short description

## Instructions

Steps for Claude to follow:

1. Step 1 — what to do
2. Step 2 — what to do
3. Step 3 — what to do

## Required context

- **Directory:** path/to/files
- **Format:** how the output should be
```

The `$ARGUMENTS` placeholder in the content will be replaced by whatever you type after the command. Example: `/pipeline https://article.com` → `$ARGUMENTS` becomes `https://article.com`.

## Before vs After: What Changes with Context Engineering

### Without context engineering

```
Me: "Create a note about machine learning in the vault"

Claude: Creates ML.md file at project root.
        No YAML frontmatter.
        No wiki links.
        In English.
        Generic title.
```

Result: useless file that needs to be redone manually.

### With context engineering

```
Me: "Create a note about machine learning in the vault"

CLAUDE.md says:
  → Language: Brazilian Portuguese
  → Notes go in 40_Wiki/ or 00_Inbox/
  → Required frontmatter: title, description, tags, created
  → Use [[wiki links]] to connect existing concepts

session-orient.sh injected:
  → There are 3 AI claims in 40_Wiki/Claims/
  → Latest plan mentioned language model research

Claude: Creates 40_Wiki/Machine Learning.md with:
        - Complete frontmatter in Portuguese
        - [[wiki links]] to existing AI claims
        - Connection to latest daily plan notes

write-validate.sh checks:
  → ✓ YAML present
  → ✓ description present
  → ✓ tags present
```

Result: note integrated into the system, connected, validated. No manual intervention.

### The difference in numbers

| Metric | Without context eng. | With context eng. |
|--------|---------------------|-------------------|
| Setup per session | 3-5 min | 0 (automatic) |
| Notes with correct schema | ~70% | ~99% |
| Manual rework | Frequent | Rare |
| Cross-session continuity | Non-existent | Automatic |
| Reproducible workflows | 0 | 8 active commands |

## How to Get Started

If you don't have any context engineering set up, start with this:

### Today (15 minutes)
Create a `CLAUDE.md` at your project root with:
- Who you are and what language to use
- Project folder structure
- 3-5 rules you always repeat

### This week (30 minutes)
Create a `SessionStart` hook that injects basic context:
- Git status (`git status --short`)
- Latest commits (`git log --oneline -5`)
- Pending TODOs

### Next week (45 minutes)
Create a slash command for the workflow you repeat most. It could be `/deploy`, `/review`, `/test`, or any ritual with fixed steps.

### Golden rule
If you've explained the same thing to Claude more than 3 times, it should be in CLAUDE.md. If you've run the same sequence of steps more than 3 times, it should be a slash command. If you manually verify something that can be automated, it should be a hook.

## Conclusion

Context engineering is the difference between **using** AI and **working with** AI. Prompt engineering optimizes one interaction. Context engineering optimizes all future interactions.

Claude Code already has the infrastructure — CLAUDE.md, hooks, slash commands. Most people don't use it. Those who do, never go back.

The investment is small: one context file, two or three hooks, a few commands. The return is permanent: every session starts exactly where the last one ended, every output follows your rules, every workflow runs the same way every time.

It's not about making the model smarter. It's about giving the model what it needs to be useful.

---

*This article is part of the "Agentic Engineering in Practice" series. Week 1: Context Engineering. Next week: how advanced hooks and MCP servers expand what Claude Code can do.*

---

*Follow me on [GitHub](https://github.com/nat-rib) or check the [blog](https://nat-rib.github.io/nataliaribeiro.github.io/) for more on agentic engineering.*
