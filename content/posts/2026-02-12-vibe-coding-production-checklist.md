---
title: "Your Vibe-Coded App Works Locally. Here's What'll Break in Production."
date: 2026-02-12
description: "A production-readiness checklist for AI-generated apps, from someone who's spent 9+ years cleaning up what 'works on my machine' really means."
tags: ["vibe-coding", "security", "production", "checklist", "ai-development"]
categories: ["AI Development"]
draft: true
---

A few weeks ago, a developer posted a thread that went viral. He'd built an app entirely with AI—Claude, Cursor, the usual suspects—and shipped it in a weekend. Users loved it. Then someone found his Supabase tables had no Row Level Security enabled. Every user's data was readable by every other user. The app was down within hours.

The thing is, the AI that wrote his code did exactly what he asked. It built features. It made them work. What it didn't do—what it almost never does unprompted—was think about what happens when real humans with real intentions start poking at the seams.

I've been shipping production code for over nine years. I've seen "it works on my machine" turn into 3 AM incident calls more times than I'd like to admit. And now that AI is writing more of our code, the gap between "working prototype" and "production-ready application" hasn't shrunk. If anything, it's gotten wider, because the prototype comes together so fast that people skip the boring middle part entirely.

This is that boring middle part. And it's not optional.

## The Vibe Coding Trap

Let's be clear about what vibe coding is good at: getting from zero to a working demo incredibly fast. You describe what you want, the AI builds it, you iterate with prompts, and suddenly you have something that looks and feels like a real product. That dopamine hit is real.

But here's what the AI optimized for: making it work. Not making it safe. Not making it resilient. Not making it maintainable. The first deploy is maybe 10-20% of the actual work of running software in production. Everything that follows—security hardening, monitoring, error handling for edge cases that only appear under real load—that's where engineering experience matters.

I'm not saying this to gatekeep. I genuinely think vibe coding is one of the most exciting developments in software in years. But I've seen what happens when the checklist gets skipped, and I'd rather you spend 30 minutes now than 30 hours later.

## Security: The Non-Negotiable Layer

### Database Security

This is where most vibe-coded apps are most vulnerable, because AI tools tend to build database access in the simplest way possible.

**Row Level Security (RLS):** If you're using Supabase, Neon, or any Postgres-based service, RLS must be enabled on every single table that holds user data. Not some tables. Every table. The default with many AI-generated setups is RLS disabled, which means any authenticated user can query any row.

Check it right now:

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

If any table shows `rowsecurity = false` and it contains user data, stop reading and go fix it.

**Policies matter too.** Having RLS enabled but with a permissive policy like `USING (true)` is the same as having no RLS at all. Each table needs policies that restrict access to the owning user:

```sql
CREATE POLICY "Users can only see their own data" 
ON user_profiles FOR SELECT 
USING (auth.uid() = user_id);
```

**Firebase Rules:** Same principle. If your Firestore rules say `allow read, write: if true`, you don't have security—you have a public database with extra steps.

**The service role key:** This is the master key to your database. It bypasses all RLS. If this is anywhere in your frontend code—React components, API routes that run client-side, environment variables prefixed with `NEXT_PUBLIC_`—you've handed the keys to everyone. Check your bundle. Run `grep -r "service_role" src/` and pray it comes back empty.

### Secrets and Credentials

AI-generated code has a habit of putting API keys right where they're used. Convenient for prototyping. Catastrophic for production.

**The basics:**
- Every API key, database URL, and secret token goes in environment variables
- `.env` is in your `.gitignore` (check—AI sometimes creates `.env.local` but leaves `.env` exposed)
- Run `git log -p | grep -i "key\|secret\|password\|token"` on your repo. If anything shows up, those credentials are compromised. Rotate them immediately, even if the repo is private. Private repos get leaked all the time.

**The one people miss:** Build-time vs runtime environment variables. In Next.js, anything prefixed with `NEXT_PUBLIC_` is baked into the client bundle and visible to everyone. In Vite, it's `VITE_`. Your OpenAI key, your Stripe secret key, your database connection string—none of these should ever have that prefix.

### Authentication

AI is surprisingly good at setting up auth flows. It's surprisingly bad at securing them completely.

**Server-side verification on every protected route.** Not just on the login page. Not just on the settings page. Every API route that returns or modifies user data needs to verify the session token server-side. I've seen AI-generated apps that check auth on the frontend (easy to bypass) but leave API routes wide open.

**Session management:**
- Sessions should expire. 30 days for remember-me, hours for sensitive operations.
- Logout must actually invalidate the session server-side, not just clear the client cookie.
- Password requirements: minimum 12 characters. The AI might set it to 6 or 8. That's not enough in 2026.

**Email verification:** If users sign up with email, verify it. Unverified accounts are spam magnets and abuse vectors. Most auth providers (Supabase Auth, Firebase Auth, Auth0) support this out of the box—the AI just doesn't always enable it.

### API Security

**Authorization ≠ Authentication.** Auth tells you who the user is. Authorization tells you what they're allowed to do. AI-generated code almost always handles the first and frequently ignores the second.

Classic example: your API has a route `GET /api/documents/:id`. The AI checks that the user is logged in. But does it check that this specific user owns this specific document? In many AI-generated codebases, the answer is no. Any authenticated user can access any document by guessing or iterating IDs.

```typescript
// What AI writes
const doc = await db.documents.findById(params.id);

// What you need
const doc = await db.documents.findFirst({
  where: { id: params.id, userId: session.user.id }
});
```

**Rate limiting:** Every public-facing endpoint needs rate limiting. Login attempts, API calls, form submissions. Without it, your app is an open invitation for brute force attacks and abuse. Libraries like `express-rate-limit` or Vercel's built-in rate limiting take minutes to set up.

**Input validation:** Never trust client input. Use Zod, Joi, or similar libraries to validate every piece of data that enters your API. The AI usually generates optimistic code that assumes well-formed input.

**Error messages:** AI loves helpful error messages. "User not found with email john@example.com" is great for debugging and terrible for security. Error messages in production should be generic: "Invalid credentials." Don't leak whether an email exists, what field failed, or any internal state.

**CORS:** Restrict it to your actual domains. AI defaults to `Access-Control-Allow-Origin: *`, which means any website can make requests to your API.

## Security Headers

These take 5 minutes to add and meaningfully improve your security posture:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
```

Most hosting platforms (Vercel, Netlify, Cloudflare Pages) let you set these in configuration. If you're using a framework like Next.js, add them in `next.config.js`. There's no reason to skip this.

## Performance and Infrastructure

Security will break your app spectacularly. Performance issues will break it slowly, and users will leave before you notice.

**What AI doesn't think about:**
- **Database indexes:** AI creates tables and queries but rarely adds indexes for the access patterns your app actually uses. Run `EXPLAIN ANALYZE` on your most common queries.
- **N+1 queries:** AI-generated code loves fetching related data in loops. One query to get a list, then one query per item to get details. At 10 items, it's fine. At 1,000, your database is crying.
- **Image optimization:** If your app handles images, they need resizing, compression, and lazy loading. The AI will happily serve 4MB PNGs in a feed.
- **Bundle size:** AI imports entire libraries when it needs one function. Run your build analyzer and check what's actually in your bundle.

**Monitoring and observability:** This is the part that zero vibe-coding tutorials mention. You need:
- Error tracking (Sentry is free for small projects)
- Basic uptime monitoring (UptimeRobot, free)
- Application logs that you can actually search (not just `console.log`)
- Alerts that wake you up when things break

Without monitoring, you'll learn about outages from your users. That's not a good look.

## The Operational Stuff

**CI/CD:** If you're deploying by running `git push` and hoping, you need a pipeline. At minimum: run tests, run the linter, build the project, deploy if everything passes. GitHub Actions is free for public repos and generous for private ones.

**Rollback plan:** When (not if) a deploy breaks something, can you go back to the previous version in under 5 minutes? If your answer involves "well, I'd revert the commit and push again," that's not fast enough. Use deployment platforms with instant rollback (Vercel, Fly.io, Railway all support this).

**Backups:** If your database disappears right now, how much data do you lose? Most managed databases have automated backups, but you need to verify they're enabled and test restoring from them. "I think backups are on" is not a backup strategy.

## What Only Experience Teaches

Here's the part AI can't give you, and honestly, no checklist fully covers:

**Edge cases multiply under real usage.** Your app works great when one user does one thing at a time. What happens when two users edit the same resource simultaneously? What happens when someone submits a form, gets a timeout, and submits again? What happens when a webhook fires twice? These aren't theoretical—they happen within the first week of real usage.

**Scaling isn't just about servers.** It's about database connection limits, API rate limits from third-party services, email sending quotas, storage costs. The AI built your app assuming infinite resources. Production has very finite ones.

**Maintenance is the real cost.** The app you built in a weekend will need updates for months or years. Dependencies get vulnerabilities. APIs change. Users find bugs in flows you never tested. If the codebase is a black box that only the AI understands, maintaining it becomes a nightmare.

Run `npm audit` (or `yarn audit`) right now. Fix the critical and high vulnerabilities. Set up Dependabot or Renovate to keep them updated automatically.

## The 30-Minute Sanity Check

If you do nothing else, do this before sharing your URL with anyone:

1. ✅ RLS enabled on all database tables with proper policies
2. ✅ No API keys or secrets in frontend code or git history
3. ✅ Server-side auth verification on all protected API routes
4. ✅ Authorization checks (user owns the resource they're accessing)
5. ✅ Rate limiting on login and public endpoints
6. ✅ Input validation on all API inputs
7. ✅ Generic error messages in production
8. ✅ CORS restricted to your domains
9. ✅ Security headers configured
10. ✅ `npm audit` with no critical vulnerabilities
11. ✅ Source maps disabled in production
12. ✅ No sensitive data in `console.log` statements

This takes 30 minutes. It saves you from disaster.

## The Bottom Line

Vibe coding is a tool, and it's a genuinely powerful one. I use AI to write code every day, and it makes me significantly more productive. But tools don't replace judgment. A nail gun builds a house faster than a hammer—but you still need to know where the load-bearing walls are.

The checklist above isn't exhaustive. It's the minimum. The floor, not the ceiling. If you're building something people will rely on—something that handles their data, their money, their trust—you owe it to them and to yourself to get the fundamentals right.

The AI got you to the starting line faster than ever before. The race is everything that comes after.
