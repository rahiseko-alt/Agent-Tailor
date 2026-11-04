# Agent Kobo（エージェント工房）

Agent Kobo builds Claude plugins (agents) that you can hand over to a customer. Tell it who the customer is and what work they want done, and it interviews you, builds the plugin with Anthropic's official plugin-dev guidance, measures whether the plugin beats plain Claude, runs the pre-submission checks, and packages the result.

## Install

```
/plugin install agent-kobo --marketplace rahiseko-alt/Dev-agent-01
```

Installing it also installs Anthropic's `plugin-dev` plugin from `claude-plugins-official`, which Agent Kobo reads while building.

## Use it

Ask in Claude Code, for example: 「〇〇さん向けに、毎週の売上報告を作るエージェントを作って」. Agent Kobo works in four steps and records progress in a folder per customer, so you can stop and resume later:

1. Interview: asks a few plain questions at a time and writes a spec memo with three real example tasks.
2. Build: writes the plugin, its README and LICENSE.
3. Improve: runs `claude plugin eval` with and without the plugin. It tells you before it uses your plan's usage.
4. Check and package: runs `claude plugin validate --profile directory --strict` and its own extra checks, tags the version, and makes a zip you can upload in claude.ai (Customize > Plugins > Add > Upload plugin).

## Data

Agent Kobo sends nothing anywhere by itself. It reads and writes files only in your working folder, reads your own Google Drive through Google's official connector (sign in once from Claude's connector settings), and runs the `claude` command on your machine for evaluation and checks, which uses your own Claude account. Every agent it builds is connected to your Google Drive by default. See [Privacy](PRIVACY.md).
