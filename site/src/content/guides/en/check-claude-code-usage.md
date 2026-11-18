---
key: check-usage
urlSlug: check-claude-code-usage
title: How to check your Claude Code usage
seoTitle: "How to check your Claude Code usage and limits: 3 ways"
description: "Three ways to see how much of your 5-hour session and weekly limit is left in Claude Code: the /usage command, claude.ai's usage page and the Mac menu bar."
order: 1
published: 2026-11-18
updated: 2026-11-18
---

Paid Claude plans have two limits running at once: a session that resets every five hours and weekly limits. Whatever you do in claude.ai, Claude Desktop and Claude Code counts toward the same ones, so a long afternoon in the terminal also shows up in the chat.

There are three places to see how much you have left. Which one suits you depends on how often you check.

## 1. The /usage command, inside Claude Code

Open a Claude Code session and type:

```
/usage
```

On a subscription (Pro, Max or Ultra) you get your plan's usage bars, activity stats and a breakdown of where the usage went. The "Session" block at the top shows API tokens and is meant for people who pay through the API; on a subscription, that usage is already included in your plan.

You can also ask for it without opening an interactive session:

```bash
claude -p "/usage" --no-session-persistence
```

`-p` prints the answer and exits, and `--no-session-persistence` keeps that query out of your history. It's exactly what Orbix runs every time it refreshes.

> If `/usage` shows API costs when you expected your plan limits, check whether `ANTHROPIC_API_KEY` is set in your environment. According to the Claude Code docs, once you approve it, an API key takes priority over your subscription. Run `unset ANTHROPIC_API_KEY`, open `claude` again and look at the "Login" row in `/status`.

## 2. claude.ai's usage page

In the browser, go to **Settings → Usage** on claude.ai, or straight to [claude.ai/settings/usage](https://claude.ai/settings/usage). "Current session" shows how much of the five-hour window you've used, and below it you'll find the weekly limits with their reset day and time.

From Claude Code, the `/usage-credits` command opens that same page if you signed in with a subscription; with an API key it isn't available.

This page gives you more detail than `/usage`, at the cost of opening the browser with your claude.ai session signed in.

## 3. Always in sight, in the menu bar

Both options above share a problem: you have to remember to look, and most people remember right after Claude has cut them off.

[Orbix](/) is a free Mac app that keeps your session percentage in the menu bar, next to the clock. The ring turns amber at 70% and red at 90%, and clicking it opens a panel with:

- the 5-hour session, what's left and the exact reset time;
- the weekly limits, the overall one and the per-model ones;
- your Claude Code accounts, each with its own session and week;
- free resets, prepaid balance and this month's extra usage, read from claude.ai.

Orbix runs `claude /usage` in a folder of its own without saving the session, so the query never shows up in your history. It doesn't ask for any key: it uses the session Claude Code already has.

## Which one to use

| If you want to… | Use |
|---|---|
| Check once, in the middle of a task | `/usage` inside Claude Code |
| See the detail with reset days and times | claude.ai → Settings → Usage |
| Stop having to remember | Orbix in the menu bar |
| Get it from a script | `claude -p "/usage" --no-session-persistence` |

To understand what each bar means and why the session doesn't reset at fixed hours, read [Claude's 5-hour and weekly limits, explained](/guides/claude-usage-limits-explained/).
