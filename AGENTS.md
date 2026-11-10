# AGENTS.md

## Agent skills

Skills come from [mattpocock/skills](https://github.com/mattpocock/skills), installed into `.claude/skills/` with `npx skills add mattpocock/skills` and pinned in `skills-lock.json`. Do not edit them locally; update with `npx skills update`.

### Issue tracker

Issues and specs live as GitHub issues in this repo, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` at the repo root, ADRs in `docs/adr/`. Both are created lazily by `domain-modeling`. See `docs/agents/domain.md`.

While working on the template itself (`.template/` exists), the template's own glossary and ADRs live in `.template/CONTEXT.md` and `.template/docs/adr/` instead, so they are not copied into new projects (`.template/` is removed in a copy on its first session). Read and enforce them exactly as you would the root ones.

## Navigation (repo-local)

This repo may be driven by a non-engineer. Never assume the user knows which slash command to run.

- **Research best practices first.** Before proposing a direction, recommending an option, or asking the user to decide, research how established companies and the tool vendors (e.g. Anthropic) actually do it, and cite direct links. Never recommend from your own assumption. (User's standing instruction.)
- **Clarify vague statements before acting.** When the user says something vague (「なんか違う」「いい感じに」「改善して」), pin it down to the granularity you can act on: which job, which output, what happened, what it should be (one concrete example), and the scope. Fill in what the conversation or Drive already tells you; ask the rest at most two questions at a time, each with a recommended answer, then restate it in one line and confirm. (User's standing instruction.)
- **Don't make the user approve each step. Agents grow and produce results on their own.** The user's biggest complaint is being asked to confirm things. Decide with sensible defaults and act; report results, not questions. Ask only when a choice is truly the user's and cannot be undone (money, contracts, deleting their data, a new kind of outward action never authorized before). Recurring work the user has set up (e.g. daily sales emails within the agreed rules) runs without per-item approval. Every agent you build must include a self-improvement loop: measure its own outcomes, adjust, and log what it changed. (User's standing instruction, 2026-11-06.)
- **Everything left on Drive is also recorded in this repo, and kept in sync.** Whenever an agent creates or updates a file on the user's Google Drive, write the same content (spreadsheets as one CSV per sheet, docs as Markdown) under `docs/drive/<file name>/` of the repository that owns that work (a built agent's own private repo; this repo only for Agent Tailor's own files) in the same turn, with a `README.md` holding the Drive file name, file ID, URL, purpose and last-synced date. Update the repo copy every time the Drive file changes. If the repo is public, tell the user once before writing; if they say to go ahead as is, copy it (user's decision, 2026-11-05). (User's standing instruction.)
- **Never read the user's files on your own.** On Google Drive (and Gmail, Calendar, or any other connected account), open only the folders and files the user has named for the task at hand. No searching the Drive, no full-text search, no opening files outside the named folder, even to "fill in what Drive already tells you". If nothing has been named, ask which folder to use. Creating folders or files on Drive also needs the user's go-ahead for that task. (User's standing instruction, 2026-11-10; it overrides the "fill in from Drive" wording above.)
- **No reinventing the wheel. Stand on the shoulders of giants.** Before building anything, look for an existing framework, SDK, library, or service that already does it, and build on top of it. Write from scratch only what nothing existing covers, and say why. (User's standing instruction.)

- **Agent Tailor is available in every session of this repo** through `.claude/skills/make-sellable-agent` (a link to `plugins/agent-tailor/skills/make-sellable-agent`, the single source). When the user asks to make an agent for a customer or a job (e.g. 「〇〇のエージェントを作って」), use that skill. Cloud sessions do not load plugins enabled in `.claude/settings.json`, which is why it is linked as a repo skill instead.
- The `next-step` skill (`.claude/skills/next-step/`, repo-local, not from mattpocock/skills) diagnoses where the work currently stands and proposes exactly one command to run next.
- A `SessionStart` hook in `.claude/settings.json` loads `docs/agents/flow-map.md` into context at the start of every session.
- Before writing implementation code for a request that has not been through the flow, run `next-step` first. Skip it only if the user explicitly says to go straight to code.
- Session ceremonies: `s` reports where the last session left off (run it at the top of the first reply of every session, unprompted); `f` drives the repo to a state where the container can be destroyed safely and then declares, with evidence, whether it is safe to close. Both are repo-local skills, triggered by the bare letter or the slash command.
- Never schedule timed check-ins on yourself (`send_later`, `create_trigger`, `/loop`, `ScheduleWakeup` or similar), including the default "safety-net check-in" after opening a PR. Watch PRs only through event delivery (`subscribe_pr_activity`). The only exception is a check-in the user explicitly asks for in the moment.
- `docs/agents/handover.md` carries state across sessions: the container is ephemeral, so anything not written there is lost. Append a new entry at the top when work is shipped or a direction is agreed, run `.claude/hooks/handover-trim.sh`, and commit it immediately. `.claude/hooks/session-start.sh` owns the retention and read-window numbers; don't restate them elsewhere.

## Development flow

### Starting new work, or adding a feature to an existing codebase

`/grill-with-docs` -> `/conduct`

`/conduct` (repo-local, `.claude/skills/conduct/`) runs everything after the first conversation without asking the user anything except at the mid-point check and the final check: spec, design review, tickets, implementation, final review, fixes, and merge on GO. Each stage is handed to an assignee (tool + model) picked by the router (`.claude/router/route.sh`) from the role table (`.claude/router/roles.txt`). Swapping models means editing only that table. When Codex and Gemini are unavailable it continues in solo mode with Claude and records the other vendors' reviews as `deferred-review` issues for later.

The manual path still works: `/grill-with-docs` -> `/to-spec` (when a spec is warranted) -> `/to-tickets` -> `/implement`

`/grill-with-docs` is the single entry point, whether or not code exists yet. It drives both `/grilling` and
`/domain-modeling`, so the vocabulary and the decisions land in `CONTEXT.md` and `docs/adr/` instead of
evaporating with the session. Those files are created lazily, so there is nothing to write and nothing to skip
when a repo is still empty. `/grill-me` is installed but deliberately unused: it runs `/grilling` alone, so it
records nothing.

`/implement` drives `/tdd` at pre-agreed seams: red -> green, one behaviour at a time, tested through the public interface rather than implementation details, one vertical slice per loop. It closes with `/code-review` before committing.

### Before a large feature, when code is hard to test, or when structure has grown complex

`/improve-codebase-architecture` -> pick a candidate -> `/grill-with-docs` or `/codebase-design` -> `/to-spec` -> `/to-tickets` -> `/implement`

`/improve-codebase-architecture` is a survey: it explores the codebase and hands back candidates. It never rewrites code on its own. Only the candidate the user picks goes through the flow above.
