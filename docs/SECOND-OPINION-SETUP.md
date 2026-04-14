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

Install the OpenAI Codex CLI and confirm `codex --version` works. The command was authored against `codex-cli 0.114.0`; any version that supports `codex exec`, `-p <profile>`, `-a never`, `--skip-git-repo-check`, and `-o <output-file>` should work.

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
- `sandbox_mode = "read-only"` is paired with `-a never` on the CLI for belt-and-braces safety.

### 4. Directory for Output Artifacts

The command writes to `thoughts/second-opinions/YYYY-MM-DD-<slug>.md` relative to the vault/project root. The command creates the directory if it does not exist, but if you use a non-default vault path you may want to adjust the hardcoded `/Users/ishtyler/Documents/My Brain 2.0` path inside `commands/second-opinion.md` to match your setup.

## How the Command Works

1. **Parse arguments** — topic (free text) plus optional `--files=a,b,c` and `--cwd=path` flags.
2. **Claude forms its own position** (3–5 bullets) and stores it internally. Not shared with Codex.
3. **Build context package** — read any `--files`, truncate large files to ~10K chars, assemble a context block.
4. **Write prompt** to `/tmp/second-opinion-prompt.md` with the multi-agent scaffolding and required output structure.
5. **Run Codex**:
   ```bash
   # Non-git working directory (vault root):
   codex exec -p analyst -a never --skip-git-repo-check \
     -o /tmp/codex-response.md - < /tmp/second-opinion-prompt.md

   # Git project directory (via --cwd):
   cd "$CWD" && codex exec -p analyst -a never \
     -o /tmp/codex-response.md - < /tmp/second-opinion-prompt.md
   ```
   Bash timeout is set to 300000ms (5 min) to accommodate multi-agent orchestration.
6. **Read Codex response** from `/tmp/codex-response.md`.
7. **Write comparison artifact** to `thoughts/second-opinions/YYYY-MM-DD-<slug>.md` with frontmatter (date, time, topic, engine, files_analyzed, tags) and sections for Executive Summary, Claude's Position, Codex's Analysis, Comparative Analysis (Agreements / Disagreements / Unique Insights per side), Synthesis & Recommendation, and Confidence & Caveats.
8. **Log to daily note** via `daily-note-management` skill.
9. **Present concise summary** in chat with the link to the full artifact.

## Usage

```
/second-opinion <topic or question> [--files=path1,path2,...] [--cwd=project-path]
```

Examples:

```
/second-opinion Should we adopt Bevy for the next version of K-Town?

/second-opinion Review the tradeoffs in this plan --files=thoughts/plans/2026-04-14-migration.md

/second-opinion Evaluate this auth refactor --cwd=/Users/me/code/my-app --files=src/auth/index.ts,src/auth/middleware.ts
```

If no topic is provided the command uses `AskUserQuestion` to collect it.

## Important Design Rules (do not change without understanding why)

- **Never share Claude's position with Codex.** The whole point of the command is blind independent analysis. Anchoring defeats it.
- **Always run Codex with `-a never` and a read-only profile.** The CLI is being used as an analyzer, not an actor.
- **Always log via `daily-note-management` skill** — the command is subject to the repo-wide blocking daily-note hook, so skipping this will fail the Stop gate.
- **Clean up temp files** after successful runs: `rm -f /tmp/second-opinion-prompt.md /tmp/codex-response.md`.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `OPENAI_API_KEY` error | Key not exported in this shell | `export OPENAI_API_KEY=...` and re-run |
| Codex times out | Large context + high reasoning | Reduce `--files`, pass fewer/smaller files, or lower `model_reasoning_effort` |
| Codex returns empty output | Transient API failure or malformed prompt | Command retries once, then falls back to presenting Claude's position alone |
| `profile 'analyst' not found` | Missing `[profiles.analyst]` block | Add the profile to `~/.codex/config.toml` (see above) |
| Multi-agent didn't actually spawn | `multi_agent = false` or feature unsupported in your CLI build | Set `[features] multi_agent = true`, upgrade CLI if needed |
| `not a git repository` error on vault root | Codex refuses to run outside a git repo | The command already passes `--skip-git-repo-check` when no `--cwd` is given; make sure you didn't strip that flag |

## Related Commands

- `/ultra-research` — comprehensive research with the `research-specialist` agent (use when you need *more data*, not a *second perspective*).
- `/prompt-upgrader` — refine a prompt before sending to Codex for tighter, higher-quality analysis.
