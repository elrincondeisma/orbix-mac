---
key: limits-explained
urlSlug: claude-usage-limits-explained
title: Claude's 5-hour and weekly limits, explained
seoTitle: "Claude's 5-hour limit and weekly limit: how they work"
description: "When Claude's 5-hour session starts and resets, how the weekly limits work, what shares them and what happens when you hit the cap."
order: 2
published: 2026-11-18
updated: 2026-11-18
---

If you pay for Claude (Pro, Max or another paid plan), two limits run at the same time. Anthropic sums it up on its [help page](https://support.claude.com/en/articles/11647753-usage-and-length-limits): a session limit that resets every five hours, and weekly limits that reset once a week. Each one keeps its own clock.

## The 5-hour session

The window starts when you send your first message and resets in full five hours later. It doesn't follow fixed hours of the day.

An example: if your first message of the morning goes out at 9:40, the session resets at 14:40, whether you used a lot or a little. If you aren't using Claude at that point, the next session starts with the next message you send, at 16:00 or at 20:00.

That has a practical consequence. If you know a heavy afternoon is coming, it helps to have the session already running, so the reset lands in the middle of your work instead of at the end.

## The weekly limits

Weekly limits reset at a fixed time each week that is assigned to your account. That day and time stay the same no matter when you start using Claude. You can see them on claude.ai, under **Settings → Usage**.

There's more than one weekly limit. Max plans, for example, have one across all models and a separate one for Fable. So you can have plenty of session left and still run out of a specific model until the weekly reset.

On accounts with no 5-hour limit, such as Ultra, the weekly limit is the one that matters. Orbix detects this and shows the weekly limit in the menu bar ring on those accounts.

## Everything counts toward the same limit

Your usage in claude.ai, Claude Desktop and Claude Code counts toward the same limit. A chat on your phone reduces what you have left for coding, and the other way around.

Accounts using an API key (`ANTHROPIC_API_KEY`) are the exception: they don't have plan limits and pay per token. Long-lived tokens from `claude setup-token` use your subscription, but Claude Code doesn't report their limits; more on that in [using several Claude Code accounts on one Mac](/guides/multiple-claude-code-accounts/).

## How much each plan gives you

Anthropic doesn't publish absolute numbers of messages or tokens per plan, and says it may adjust the limits. What it does say is relative: the Max plan includes five times the Pro plan's usage, every five hours and every week.

Since the amount depends on how you use Claude (a message with a large repository in context costs far more than a short question), the useful number is the percentage, which is what `/usage`, the usage page and Orbix show.

## What happens when you hit a limit

If you reach the session or weekly cap, you have three ways out:

- wait for the reset;
- move to a plan with more usage;
- keep going on usage credits, if you've turned them on: your work continues on credits instead of stopping.

Some accounts also have resets that bring the session or the weekly limits back to full. Orbix reads them from claude.ai and shows how many you have saved and when they expire.

If you use several accounts, there's a fourth option: switch to one that still has room. Each account has its own limits.

## How to avoid surprises

The trouble with these limits is that Claude tells you once you've already hit them. To see them coming:

- in Claude Code, `/usage` shows your plan's bars;
- on claude.ai, **Settings → Usage** gives you the reset days and times;
- [Orbix](/) keeps them in the Mac menu bar, amber at 70% and red at 90%.

All three, with their commands, are in [how to check your Claude Code usage](/guides/check-claude-code-usage/).
