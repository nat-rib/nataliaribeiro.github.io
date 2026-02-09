---
title: "How I Use AI Agents to Review My Own PRs Before Anyone Else Does"
date: 2026-02-09
description: "A practical guide to setting up AI-powered code review with Claude API and Git hooks to catch bugs before your teammates do."
tags: ["ai-agents", "code-review", "claude-api", "git-hooks", "automation"]
categories: ["AI Development"]
draft: false
---

Last month, I pushed a PR that looked perfectly fine to me. Clean code, tests passing, documentation updated. My colleague found a race condition in the error handling path within 10 minutes of review. It was embarrassing—not because I missed it, but because it was exactly the kind of bug an AI could have caught if I'd asked it to look.

That experience pushed me to build something I now use on every PR: an AI agent that reviews my code before I even request human review. Here's how I set it up, what actually works, and where it still falls short.

## The Problem with Self-Review

We all do self-review before pushing code. We read through the diff, maybe run it locally, and convince ourselves it's ready. But here's the thing: our brains are terrible at catching our own mistakes. We see what we intended to write, not what we actually wrote.

Traditional linters and static analysis help, but they miss the semantic bugs—the ones where the code is syntactically correct but logically wrong. That's where AI shines. It can reason about intent, spot edge cases you didn't consider, and ask "wait, what happens if X is null here?"

## My Setup: Claude + Git Pre-Push Hook

After trying several approaches, I settled on a pre-push Git hook that calls the Claude API. Why pre-push instead of pre-commit? Because I want fast commits during development, but I want thorough review before code leaves my machine.

Here's the basic architecture:

1. Git pre-push hook triggers a Python script
2. Script extracts the diff of commits being pushed
3. Diff + context goes to Claude API with a code review prompt
4. Claude returns findings, script displays them
5. I decide to push anyway or fix the issues

### The Pre-Push Hook

First, create `.git/hooks/pre-push`:

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

Make it executable: `chmod +x .git/hooks/pre-push`

### The Python Review Script

Here's the core of `~/.git-hooks/ai-review.py`:

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

## Real Example: A Bug Claude Caught

Two weeks ago, I was refactoring a payment processing function. Here's a simplified version of what I wrote:

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

Claude's response:

> **HIGH: Race condition in balance handling**
> 
> Between checking balance (line 7) and deducting it (line 11), another request could modify the balance. In high-concurrency scenarios, this could allow overdrafts.
> 
> Additionally, if `payment_gateway.charge()` fails AFTER `deduct_balance()` succeeds, and the `add_balance()` refund also fails, the user loses money with no record.
> 
> Recommend: Use a database transaction with row-level locking, or implement idempotent operations with a separate ledger.

This is exactly the kind of bug that passes unit tests but explodes in production. I knew about race conditions conceptually, but in the flow of writing code, I just... missed it. The AI didn't.

## What Works Well

After three months of using this setup, here's where AI review consistently adds value:

**Concurrency issues**: Claude is excellent at spotting race conditions, deadlock potential, and missing locks. It thinks about "what if two requests hit this at the same time?" more reliably than I do.

**Error handling gaps**: It catches missing error cases, especially in async code where exceptions can get swallowed.

**Null/undefined checks**: The classic "but what if this is null?" that we forget when we're focused on the happy path.

**Security basics**: SQL injection, XSS, hardcoded secrets—it catches the OWASP Top 10 stuff consistently.

## What Doesn't Work (Yet)

AI code review isn't magic. Here's where it falls short:

**Business logic validation**: Claude doesn't know that "users over 65 get a 10% discount" is a business rule in your system. It can't verify you implemented the right logic, only that your logic is internally consistent.

**Performance at scale**: It might flag an O(n²) loop, but it doesn't know your n is always < 10 or that this runs once a day. Context matters.

**False positives**: Sometimes it flags things that are intentional. I'd estimate about 20% of its concerns are "actually, that's fine because..." situations.

**Large diffs**: Token limits mean you can't review a 2000-line refactor effectively. I chunk large PRs manually for this.

## The Cost Reality

Let's talk money. Using Claude's Sonnet model, a typical PR review (500-line diff) costs about $0.02-0.05. At 10 PRs per day, that's roughly $10-15/month. For the bugs it catches? Worth it.

If you're on a team, you could run this as a shared service and split costs. Or use it only for critical paths—payment processing, auth, data handling.

## Making It Better Over Time

I've iterated on the prompt significantly. A few tips:

1. **Be specific about what to ignore**: I added "skip style nitpicks, formatting issues, and naming suggestions" to reduce noise.

2. **Add repo context**: For complex codebases, I include a brief description of the architecture in the prompt.

3. **Track accuracy**: I keep a simple log of issues found vs false positives. When false positive rate climbs, I tune the prompt.

4. **Layer with human review**: This doesn't replace teammates. It makes their review faster because the obvious stuff is already caught.

## Conclusion

Using AI to review my PRs before human review has become one of my highest-ROI automation projects. Setup took an afternoon, costs are negligible, and it catches real bugs—the kind that would otherwise make it to code review or, worse, production.

The key insight: AI is better at reviewing code than writing it from scratch. It can't architect your system, but it can absolutely tell you when you forgot to handle a null pointer in your error path.

If you're not doing this yet, start with a simple pre-push hook on your most critical repo. See what it catches over a week. I bet you'll be surprised.

---

*Have a different approach to AI code review? Found tools that work better? I'd love to hear about it—reach out on [LinkedIn](https://linkedin.com) or [Twitter/X](https://twitter.com).*
