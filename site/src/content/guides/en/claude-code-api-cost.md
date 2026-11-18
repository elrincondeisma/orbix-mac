---
key: api-cost
urlSlug: claude-code-api-cost
title: What your Claude Code usage would cost on the API
seoTitle: "What your Claude Code usage would cost if you paid for the API"
description: "How to work out what your Claude Code subscription usage would cost on the API: where the token counts come from, how caching is billed and which prices to use."
order: 4
published: 2026-11-18
updated: 2026-11-18
---

On a subscription you pay the same every month, whether you use Claude Code a lot or a little. Knowing what that usage would cost on the API is useful for two things: seeing whether your plan pays off, and having a realistic number if you ever move to paying per token, for a team or for CI.

## How the API bills

The API charges per million tokens, with a different price for each model and each kind of token. Current prices are in [Anthropic's official pricing table](https://platform.claude.com/docs/en/about-claude/pricing). What matters for the math is how they combine:

| Token type | Price |
|---|---|
| Input | The model's base input price |
| Output | The model's output price |
| Cache write, 5 minutes | 1.25 × the input price |
| Cache write, 1 hour | 2 × the input price |
| Cache read | 0.1 × the input price on most models |

Cache reads have exceptions: on Opus 5.5 and Sonnet 5.5 they cost 0.05 × input, and on Fable 5.2, 0.025 ×. Fast mode has its own, higher prices, and stacks with the caching multipliers.

Caching weighs a lot in Claude Code. Every message sends the conversation context again and almost all of it is read from cache, so most of your tokens are cheap cache reads. Counting everything at the input price would inflate the number a lot.

## Where your tokens come from

Claude Code stores every session on your Mac, in JSONL files under `~/.claude/projects/`. Each model response carries the date, the model used and the token count for each type: input, output, cache read and cache write.

With that, the math is a sum per response:

```
cost = input × input_price
     + output × output_price
     + cache_read × cache_read_price
     + cache_write_5m × input_price × 1.25
     + cache_write_1h × input_price × 2
```

One detail is easy to miss: the same response can appear more than once in the logs. Count it once or the total comes out doubled.

## What Orbix does

[Orbix](/) does this math for you and shows it in its panel, in the "If you paid for the API" card: the cost of the current session and of the last 30 days at list prices.

- From each log line it reads only the date, the model and the token counts. Never the content of your conversations.
- It counts repeated responses once.
- It applies the price of each token type, the 5-minute and 1-hour cache, and fast mode.

## How far the estimate goes

Read the number with three caveats:

- It only covers Claude Code usage on that Mac. What you do in claude.ai, Claude Desktop or on another computer isn't in those files.
- It uses list prices. If prices change, the number changes with them.
- Responses from a model without a known price aren't included; Orbix says so under the number.

If you pay through the API with `ANTHROPIC_API_KEY`, you don't need to estimate anything: the "Session" block in `/usage` already shows your API token usage. To follow a subscription's limits, see [how to check your Claude Code usage](/guides/check-claude-code-usage/).
