# /second-opinion Setup Guide

The `/second-opinion` slash command gets a structured, independent second opinion from OpenAI's Codex CLI on a topic, decision, or artifact. Claude first forms its own blind position, then Codex analyzes the same inputs under a multi-agent scaffolding (Devil's Advocate → Domain Expert → Pragmatist → Synthesis), and finally Claude produces a side-by-side comparison document in `thoughts/second-opinions/`.

This doc covers everything needed to make the command work.

## What You Get

- **Independent cross-check**: Claude's position is generated *before* Codex is called, then held back from Codex to prevent anchoring bias.
- **Multi-agent Codex analysis**: The Codex prompt explicitly orchestrates four analytical personas in a single non-interactive run.
- **Structured comparison artifact**: Markdown file with Executive Summary, both positions, Agreements, Disagreements, Unique Insights per side, and a Synthesis & Recommendation.
- **Daily note integration**: Completion is logged via the `daily-note-management` skill (mandatory).

## Prerequisites

### 1. OpenAI Codex CLI

Install the OpenAI Codex CLI and confirm `codex --version` works. The command was authored against `codex-cli 0.114.0` and revalidated on `codex-cli 0.130.0`; any version that supports `codex exec`, `-p <profile>`, `-s read-only`, `--skip-git-repo-check`, and `-o <output-file>` should work.

**Note**: as of `codex-cli 0.114.0`, the `-a` (`--ask-for-approval`) flag was moved off the `exec` subcommand; `/second-opinion` v1.1.0+ uses `-s read-only` instead. If you're on an older CLI build that still supports `-a never`, the command will need a one-line edit (`-s read-only` → `-a never`) — but upgrading the CLI is the better path.

Install docs: https://developers.openai.com/codex/

### 2. API Key

Set `OPENAI_API_KEY` in your shell environment (e.g., in `~/.zshrc` or `~/.bashrc`):

```bash
export OPENAI_API_KEY="sk-..."
```

The command's error path will tell the user to check this variable if Codex returns an auth error.

### 3. `analyst` Profile in `~/.codex/config.toml`

The command invokes Codex with `-p analyst`. That profile must exist in `~/.codex/config.toml` and should enable deep reasoning plus a read-only sandbox so Codex cannot mutate the repo while analyzing it.

Minimum config:

```toml
# Enable experimental multi-agent orchestration
[features]
multi_agent = true

# Agent orchestration settings (tune to taste)
[agents]
max_threads = 4
max_depth = 1
job_max_runtime_seconds = 300

# Profile used by /second-opinion
[profiles.analyst]
model_reasoning_effort = "high"
sandbox_mode = "read-only"
```

Notes:
- `multi_agent = true` is what lets the scaffolded "Devil's Advocate / Domain Expert / Pragmatist / Synthesis" agents in the prompt actually spawn as sub-threads instead of being treated as pure prose.
- `max_threads` caps parallelism; 4 is plenty for the four-persona layout.
- `job_max_runtime_seconds = 300` lines up with the 5-minute (`300000ms`) Bash timeout the command uses.
- `sandbox_mode = "read-only"` is paired with `-s read-only` on the CLI for belt-and-braces safety. (Pre-v1.1.0 the command used `-a never`; that flag was removed from `codex exec` in CLI 0.114.0.)

### 4. Directory for Output Artifacts

The command writes to `thoughts/second-opinions/YYYY-MM-DD-<slug>.md` relative to the vault/project root. The command creates the directory if it does not exist, but if you use a non-default vault path you may want to adjust the hardcoded `/Users/ishtyler/Documents/My Brain 2.0` path inside `commands/second-opinion.md` to match your setup.

## How the Command Works

1. **Parse arguments** — topic (free text) plus optional `--files=a,b,c`, `--cwd=path`, `--research`, `--diagnose` flags. `--research` and `--diagnose` are mutually exclusive.
2. **Short-circuit `--diagnose`** *(v1.1.0+)* — if present, run `scripts/codex-diagnose.sh` (heavy env checks: CLI version, npm latest, network, config, cache, optional model probes), print output, exit. Skip everything below.
3. **Print startup banner** *(v1.1.0+)* — run `scripts/codex-banner.sh` (local-only, no network) and print its one-liner showing the active CLI version, model, sandbox, and agent settings.
4. **Classify topic shape (Step 1a, v1.3.0+)** — Claude classifies the topic into one of: `ideation`, `architecture`, `tooling`, `bug`, `strategy`, `code-review`, or other. Bias is deliberately toward `ideation` when in doubt — this drives Codex's framing downstream.
5. **Claude forms its own position** (3–5 bullets, Step 1b) and stores it internally. Not shared with Codex (only the topic shape is shared).
6. **Build context package** — read any `--files`, truncate large files to ~10K chars, assemble a context block.
7. **Pre-computed Research Brief (Step 2.5, only if `--research`, v1.2.0+)** — Phase A: scope-aware decomposition into 2-3 internal + 2-3 external research domains with anti-overlap `excludes:` declarations. Phase B: parallel `research-specialist` sub-agents in a single launch. Phase C: synthesize disk-read agent outputs into a Research Brief at `thoughts/second-opinions/YYYY-MM-DD-<slug>-brief.md`.
8. **Write prompt** to `/tmp/second-opinion-prompt.md` with the multi-agent scaffolding, the Topic Shape annotation, the Ideation Mode lens (only if `topic_shape == "ideation"`), the Research Brief block (only if `--research`), the user-supplied files, and the required output structure.
9. **Run Codex**:
   ```bash
   # Non-git working directory (vault root):
   codex exec -p analyst -s read-only --skip-git-repo-check \
     -o /tmp/codex-response.md - < /tmp/second-opinion-prompt.md

   # Git project directory (via --cwd):
   cd "$CWD" && codex exec -p analyst -s read-only \
     -o /tmp/codex-response.md - < /tmp/second-opinion-prompt.md
   ```
   Bash timeout is set to 300000ms (5 min) to accommodate multi-agent orchestration.
10. **Read Codex response** from `/tmp/codex-response.md`.
11. **Write comparison artifact** to `thoughts/second-opinions/YYYY-MM-DD-<slug>.md` with frontmatter (date, time, topic, engine, files_analyzed, tags, **research_brief** link if `--research` was used) and sections for Executive Summary, Claude's Position, Codex's Analysis, Comparative Analysis (Agreements / Disagreements / Unique Insights per side), Synthesis & Recommendation, and Confidence & Caveats.
12. **Log to daily note** via `daily-note-management` skill. (`--diagnose` is exempt — it's operational, not work product.)
13. **Present concise summary** in chat with the link to the full artifact (and the brief, if `--research`).

## Usage

```
/second-opinion <topic or question> [--files=path1,path2,...] [--cwd=project-path] [--research] [--diagnose]
```

Flags:

- `--files=p1,p2`: include the listed files in Codex's Context section (truncated to ~10K chars each).
- `--cwd=path`: run Codex from the given working directory (likely a git project) instead of the vault root.
- `--research` *(v1.2.0+)*: opt-in pre-Codex research mode. Claude (not Codex) decomposes the topic into 2-3 internal + 2-3 external research domains (anti-overlap enforced via `excludes:`), runs `research-specialist` sub-agents in parallel, synthesizes a structured Research Brief saved at `thoughts/second-opinions/YYYY-MM-DD-{slug}-brief.md`, then concatenates the brief into Codex's Context section with explicit anti-anchoring framing. Adds ~3-5 min. Default behavior unchanged when omitted.
- `--diagnose` *(v1.1.0+)*: run environment diagnostics and exit (no Codex invocation, no topic required). Pair with `--quick` to skip slow model probes.
- `--research` and `--diagnose` are **mutually exclusive** — pick one.

Examples:

```
/second-opinion Should we adopt Bevy for the next version of K-Town?

/second-opinion Review the tradeoffs in this plan --files=thoughts/plans/2026-04-14-migration.md

/second-opinion Evaluate this auth refactor --cwd=/Users/me/code/my-app --files=src/auth/index.ts,src/auth/middleware.ts

/second-opinion --research What am I missing in this feature idea? --files=design.md

/second-opinion --diagnose
```

If no topic is provided (and not in `--diagnose` mode) the command uses `AskUserQuestion` to collect it.

## Startup Banner (v1.1.0+)

Every non-`--diagnose` invocation prints a one-line banner sourced from `scripts/codex-banner.sh`:

```
second-opinion: codex 0.130.0 | model gpt-5.5 configured | sandbox read-only | agents 4x depth 1
```

The banner is **local-only by design** — no network calls. It reads `codex --version` and parses `~/.codex/config.toml`. For full environment checks (npm latest, network reachability, cache writability, model probes) use `--diagnose`.

## Autonomous Ideation Classification (v1.3.0+)

The command classifies the topic shape in Step 1a (always — even in default mode) into one of: `ideation`, `architecture`, `tooling`, `bug`, `strategy`, `code-review`, or other. **The classifier is deliberately biased toward `ideation` when in doubt** — false positives cost ~3 extra meta-questions in Codex's output; false negatives cost premature convergence on a half-formed idea.

Triggers `ideation`:
- Phrasing: "what am I missing?", "I'm thinking about", "bouncing ideas", "what if we…"
- Hole-finding language: "scoped right?", "blind spots?", "thinking big enough?"
- Open-endedness: no specific files in scope, no concrete bug, no decision deadline

When `topic_shape == "ideation"`, Codex's prompt gains an **Ideation Mode lens** (placed BEFORE the existing 4-agent strategy so all agents read it) instructing them to bias toward expansion: surface holes, probe scope, find integration points, invite domain-expert pushback, resist premature convergence.

## Important Design Rules (do not change without understanding why)

- **Never share Claude's position with Codex.** The whole point of the command is blind independent analysis. Anchoring defeats it.
- **Run Codex with `-s read-only` (sandbox flag).** As of Codex CLI 0.114+, `-a never` was moved off the `exec` subcommand — use `-s read-only` instead. The `analyst` profile already sets `sandbox_mode = "read-only"`, so the explicit flag is belt-and-suspenders.
- **The `--research` brief is evidence, not authority.** Codex's prompt includes anti-anchoring framing telling agents to corroborate or challenge brief findings, cross-check HIGH-impact claims at source, and prefer their own analysis when contradictions arise. Do not weaken this framing.
- **Always log via `daily-note-management` skill** — the command is subject to the repo-wide blocking daily-note hook, so skipping this will fail the Stop gate. (`--diagnose` is exempt — it's operational, not work product.)
- **Clean up temp files** after successful runs: `rm -f /tmp/second-opinion-prompt.md /tmp/codex-response.md` (and `rm -rf /tmp/second-opinion-research /tmp/second-opinion-decomposition.yaml` when `--research` was used).

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Auth error | API key not set / not logged in | `export OPENAI_API_KEY=...` or run `codex login` |
| Codex times out | Large context + high reasoning, or `--research` heavy mode on large repo | Reduce `--files`, drop `--research`, or lower `model_reasoning_effort` in profile |
| Codex returns empty output | Transient API failure or malformed prompt | Command retries once, then falls back to presenting Claude's position alone |
| `profile 'analyst' not found` | Missing `[profiles.analyst]` block | Add the profile to `~/.codex/config.toml` (see above) |
| Multi-agent didn't actually spawn | `multi_agent = false` or feature unsupported in your CLI build | Set `[features] multi_agent = true`, upgrade CLI if needed |
| `error: unexpected argument '-a' found` | Stale invocation using deprecated `-a never` | Use `-s read-only` instead (post-v1.1.0 commands already do this) |
| `not a git repository` error on vault root | Codex refuses to run outside a git repo | The command already passes `--skip-git-repo-check` when no `--cwd` is given; make sure you didn't strip that flag |
| `--research and --diagnose are mutually exclusive` | Both flags passed | Pick one — `--diagnose` for env health, `--research` for pre-Codex research |
| Banner missing from output | `scripts/codex-banner.sh` not present or not executable | `chmod +x scripts/codex-banner.sh`; banner is non-blocking, will skip silently if missing |
| Want to know what model is REALLY in use | Configured ≠ accepted (e.g. `gpt-5.5` rejected on stale CLI) | Run `/second-opinion --diagnose` for the full env probe including model acceptance |

## Related Commands

- `/ultra-research` — comprehensive research with the `research-specialist` agent (use when you need *more data*, not a *second perspective*).
- `/prompt-upgrader` — refine a prompt before sending to Codex for tighter, higher-quality analysis.
