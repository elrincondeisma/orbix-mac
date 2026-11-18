---
key: multiple-accounts
urlSlug: multiple-claude-code-accounts
title: How to use several Claude Code accounts on one Mac
seoTitle: "Multiple Claude Code accounts on one Mac: how to switch"
description: "How to keep your personal and work Claude Code accounts side by side with CLAUDE_CONFIG_DIR, how to use a long-lived token and how to switch between them."
order: 3
published: 2026-11-18
updated: 2026-11-18
---

Claude Code keeps its login, settings and history in `~/.claude`. With a single account you never think about it, but if you have a personal account and a work one, or an account for scripts, each needs its own folder.

Each account also has its own session and weekly limits. When one gets close to the cap, switching to another lets you keep working.

## One folder per account with CLAUDE_CONFIG_DIR

The `CLAUDE_CONFIG_DIR` variable tells Claude Code which folder to use instead of `~/.claude`. According to the [authentication docs](https://code.claude.com/docs/en/authentication), each folder has its own settings, session history and claude.ai login or API key.

The simplest way is an alias in your `~/.zshrc`:

```bash
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work claude'
```

Open a new terminal, run `claude-work` and sign in with `/login` using your work account. You do it once; from then on, `claude` keeps signing in with your usual account and `claude-work` with the other one.

On macOS the credential is stored in the Keychain, tied to that folder, so the two logins don't overwrite each other.

### What isn't shared

A new folder is an empty Claude Code. Your settings, your `CLAUDE.md` instructions, your skills, commands and agents stay in `~/.claude`, and the other account can't see them. If you want the same ones in both, link them:

```bash
for f in settings.json CLAUDE.md skills commands agents; do
  ln -s ~/.claude/$f ~/.claude-work/$f
done
```

Keep the login and the MCP servers separate: each account has its own.

## Long-lived tokens

For an account that will never open a browser (a server, CI or a script) there's:

```bash
claude setup-token
```

The command runs the login in the browser and prints an OAuth token that lasts one year. Nothing is saved: you copy the token and pass it in the `CLAUDE_CODE_OAUTH_TOKEN` variable. Pro, Max, Ultra, Team and Enterprise plans can use it.

Two limitations are worth knowing:

- the token can only make model requests, so Claude Code doesn't report that account's limits;
- if an `ANTHROPIC_API_KEY` is set in the same environment, the key takes priority over the token.

Don't leave the token written in `~/.zshrc` or in a file in your repository. On a Mac, the place to keep it is the Keychain.

## Switching accounts without aliases, with Orbix

Aliases work, but you have to remember which one to use in each terminal, and apps like VS Code don't read your `~/.zshrc`.

[Orbix](/) handles this as profiles. Each profile is an account with its own folder in `~/.claude-perfiles/<name>`. A login profile opens a Terminal where you run `/login` once. A token profile takes the one from `claude setup-token` and Orbix stores it in your Keychain.

When it creates a profile, Orbix links your settings, `CLAUDE.md`, skills, commands and agents to your main account. The login, the `.claude.json` configuration and the MCP servers stay separate.

To switch accounts you flip its switch in the panel. The next `claude` you open signs in with it, in herdr panes too. From the terminal you have:

```bash
claude                      # opens Claude Code with the active account
claude --perfil work        # another account, just this once
orbix-perfil work           # changes the active account
orbix-perfil                # shows the active one and the others
```

The "Aplicar también a las apps" option (apply to apps too; the app's interface is in Spanish for now) makes VS Code and other apps that launch Claude Code use the active profile. Tokens are never exposed this way: only the folder is applied.

The panel shows each account's session and week on its row, so you can see which one has room before you switch. To understand each percentage, read [Claude's 5-hour and weekly limits, explained](/guides/claude-usage-limits-explained/).
