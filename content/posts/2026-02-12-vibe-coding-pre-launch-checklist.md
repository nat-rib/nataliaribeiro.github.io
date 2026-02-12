---
title: "What to Do Before Shipping a Vibe-Coded App to Production"
date: 2026-02-12
description: "A practical security, performance, and ops checklist for vibe-coded apps heading to production. From a developer with 9+ years of experience."
tags: ["vibe-coding", "security", "deploy", "checklist", "production", "AI"]
categories: ["Opinion", "Engineering"]
slug: "vibe-coding-pre-launch-checklist"
keywords:
  - vibe coding security
  - production deploy checklist
  - vibe coded app production
  - AI generated code security
  - pre-launch checklist developers
draft: false
---

Vibe coding is everywhere. You describe what you want, the model generates the app, and in half an hour you have something running on localhost. It's genuinely impressive. I use AI in my workflow every day—generating boilerplate, reviewing PRs, speeding up repetitive tasks.

But every week I see someone on Twitter/X proudly posting: *"Built my entire SaaS with vibe coding in a weekend! It's live!"*

And every week someone learns the hard way that **running on localhost is not the same as being production-ready**.

This article is the checklist I wish those people would read *before* deploying. This isn't theory—it's what 9+ years of backend work in financial systems taught me about what goes wrong when you skip steps.

## The Real Problem

The first deploy is maybe 10-20% of the actual work. What happens when the rest is ignored?

- **Open database**: RLS disabled on Supabase = any user can access any other user's data. I've seen this in production with real financial data.
- **API keys in the frontend**: The model generated the code, you deployed, and your OpenAI key is sitting in the JavaScript bundle. Someone finds it, burns $2,000 on your card overnight.
- **Zero rate limiting**: A bot discovers your public endpoint and fires 100,000 requests per minute. Your Vercel/AWS bill comes with a surprise.
- **No server-side validation**: The frontend validates, but anyone with curl bypasses everything and injects whatever they want.

None of these scenarios are hypothetical. They all happen *every week* with vibe-coded apps.

## Security Checklist

This is the non-negotiable block. It doesn't matter if it's a side project, an MVP, or "just a test"—if it has real users, it has real responsibility.

### Database

```sql
-- Check if RLS is enabled on ALL tables (Supabase/Postgres)
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

- **RLS enabled on all tables**—this is the #1 failure in vibe-coded apps. The model creates the table, doesn't enable RLS, and now any authenticated user can read everything.
- **Restrictive per-user policies**—enabling RLS isn't enough; policies need to filter by `auth.uid()`.
- **Service role key NEVER in the frontend**—the service key bypasses RLS. If it's client-side, it's like having no RLS at all.

```sql
-- Example restrictive policy
CREATE POLICY "Users can only see own data"
ON profiles FOR SELECT
USING (auth.uid() = user_id);
```

### Secrets & Credentials

```bash
# Search for leaked secrets in git history
git log -p | grep -iE "(api_key|secret|password|token)" | head -20

# Check if .env is in .gitignore
grep ".env" .gitignore
```

- **All API keys in environment variables**—never hardcoded, never in the repo.
- `.env` **in** `.gitignore`—seems obvious, but the model doesn't always do it.
- If a key was ever committed, **rotate immediately**. Deleting the commit isn't enough—git history is public.

### Authentication

- **Server-side verification on ALL protected routes**—auth middleware, not frontend checks.
- **Email verification** before full access.
- **Password requirements**: minimum 12 characters. Yes, 12. In 2026, 8 is insufficient.
- **Session timeout** configured—eternal sessions are an invitation for session hijacking.
- **Logout clears session**—test manually: log out, copy the old token, try to use it. If it works, you have a bug.

### API

```bash
# Basic test: try accessing another user's data
curl -H "Authorization: Bearer TOKEN_USER_A" \
  https://yourapp.com/api/users/USER_B_ID/data
# If it returns 200, you have a serious problem.
```

- **Ownership verification**—every route that returns data must check if the resource belongs to the authenticated user.
- **Input validation with schema**—use Zod, Joi, or equivalent. Don't trust anything from the client.
- **Rate limiting on public endpoints**—login, signup, password reset. Without it, brute force is trivial.
- **Generic error messages**—`"Invalid credentials"`, not `"User not found"` vs `"Wrong password"`. The difference leaks information.
- **Restricted CORS**—only your domains, not `*`.

```typescript
// Example with Zod
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  password: z.string().min(12),
});

// In the handler
const parsed = CreateUserSchema.safeParse(req.body);
if (!parsed.success) {
  return res.status(400).json({ error: "Invalid input" });
}
```

### Security Headers

If you use Vercel, Netlify, or any modern platform, configuring headers is a matter of one file:

```json
// vercel.json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self'" }
      ]
    }
  ]
}
```

Five minutes of configuration. Protects against clickjacking, MIME sniffing, and a range of common attacks. No excuse not to do it.

## Performance & Infrastructure Checklist

AI generates code that works. It doesn't generate code that scales. That's a distinction only someone who's seen a system under real load understands.

- **`npm audit` / `yarn audit`**—run before every deploy. Dependencies with known vulnerabilities are an open door.
- **Source maps disabled in production**—your source code doesn't need to be readable in the user's browser.
- **No `console.log` with sensitive data**—the model loves adding debug logs. In production, that's information leakage.
- **Bundle size**—the model doesn't optimize imports. Check you're not shipping 2MB of JavaScript to the client.
- **Lazy loading** on heavy routes and components.
- **Optimized images**—WebP/AVIF, with correct dimensions. Next.js Image or equivalent.

```bash
# Analyze the bundle
npx webpack-bundle-analyzer stats.json
# or for Next.js
ANALYZE=true next build
```

### Database Under Load

- **Indexes on frequent queries**—the model creates tables, rarely creates indexes. A query without an index on a 100k-row table is a guaranteed timeout.
- **Connection pooling**—if using Supabase/Postgres directly, set up pgBouncer or equivalent.
- **N+1 queries**—the favorite pattern of AI-generated code. Use `EXPLAIN ANALYZE` on your main queries.

```sql
-- Find slow queries (Postgres)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## Operational Checklist

This is the part that separates "personal project" from "product." If you plan to have real users—even a few—you need to be able to answer: *"What happened at 3 AM when the system went down?"*

- **Basic monitoring**—Uptime (UptimeRobot is free), error tracking (Sentry has a free tier), performance metrics.
- **Structured logging**—not `console.log("something broke")`. Use JSON with timestamp, request ID, context.
- **CI/CD**—manual deploys are a recipe for disaster. GitHub Actions with automated tests at minimum.
- **Rollback plan**—if the deploy breaks production, how long does it take to revert? If the answer is "I don't know," you're not ready.
- **Database backups**—tested. A backup that's never been restored isn't a backup, it's hope.

```yaml
# .github/workflows/deploy.yml (minimal example)
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
      # deploy only proceeds if lint + tests pass
```

## What Only Experience Teaches

I can give you checklists all day. But some things no list covers:

**Edge cases the model can't imagine.** What happens when a user pastes 50MB of text into an input field? When the server timezone differs from the user's timezone? When the Stripe webhook arrives *before* the checkout redirect completes? These scenarios only surface when you've seen systems break in creative ways.

**Scaling isn't linear.** Working with 10 users doesn't guarantee working with 1,000. The database that responded in 20ms starts taking 2 seconds. The WebSocket that was stable starts dropping connections. The cloud bill that was $5 becomes $500.

**Maintenance is the real work.** The app you vibe-coded in a weekend will need updates, bugfixes, API changes, database migrations. If you don't understand the code the model generated, every change becomes a game of roulette.

## Conclusion: Tool, Not Replacement

Vibe coding is a powerful tool. I use AI every day in my work and recommend every dev do the same. But a powerful tool in the hands of someone who doesn't know what they're doing causes more damage, not less.

If you're a dev: use vibe coding to accelerate, but apply your experience to everything the model generates. Review security, test edge cases, configure infrastructure like you always have.

If you're not a dev: respect the gap. A live app with real user data is real responsibility. Hire someone for the review, or at minimum go through this article's checklist item by item.

**The first deploy is 10-20% of the work.** The other 80% is what separates an app from a product.

---

*This article is part of my series on AI-augmented development. Want to catch the next ones? Follow me on [GitHub](https://github.com/nat-rib) or check the [blog](https://nat-rib.github.io/nataliaribeiro.github.io/).*
