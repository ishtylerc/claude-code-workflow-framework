# Windows Agent: Workflow Framework Alignment

**WHO THIS IS FOR**: The Claude Code instance running on Ish's Windows machine.

**YOUR MISSION**: Bring your environment into alignment with the reference framework in this repo. You likely already have some of these pieces — your job is to figure out what you have, what you're missing, and fill the gaps intelligently.

**APPROACH**: Audit first, then act. Do NOT blindly clone and overwrite. You know your environment better than this document does.

---

## The Reference Framework

This repo (`claude-code-workflow-framework`) represents the production setup on the macOS instance. It has 7 layers:

| Layer | What It Is | Files | Priority |
|-------|-----------|-------|----------|
| **rules/** | Always-loaded policies (orchestration standards, plan templates, task tracking) | 11 .md files | HIGHEST — these define how you think about complex work |
| **hooks/** | Lifecycle enforcement (skill evaluation, task compliance, documentation blocking) | 7 scripts | HIGH — these force consistent behavior |
| **skills/** | On-demand capabilities (daily note documentation, task list management) | 4 files across 2 skills | HIGH — these are the core workflow skills |
| **agents/** | Sub-agent personas (research, implementation, discovery, verification, etc.) | 10 .md files | MEDIUM — extend your multi-agent capabilities |
| **commands/** | Slash commands (daily notes, planning, research, development) | 18 files | MEDIUM — convenience commands |
| **scripts/** | Daily note automation (midnight cron with task rollover, hierarchical notes) | 2 shell scripts | LOWER — you may already have a working version |
| **scheduling/** | macOS launchd plist | 1 file | SKIP — macOS-specific, you need Task Scheduler or WSL cron instead |

---

## Phase 1: Audit Your Current State

**Before changing anything**, map what you already have. Run through this checklist and note what exists, what's missing, and what's outdated.

### Audit checklist

```
YOUR VAULT: /mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain
(Adjust if your vault is at a different path)

Check each location. For items that exist, note whether they look
current or stale compared to the reference versions in this repo.

.claude/rules/
  [ ] orchestration-quality-standard.md     ← The big one. 5-pillar quality framework.
  [ ] sub-agent-orchestration.md            ← Agent delegation patterns, lean orchestrator, piping.
  [ ] implementation-plan-standard.md       ← 16-section plan template with scaling guide.
  [ ] worktree-implementation-workflow.md   ← Git worktree isolation pattern.
  [ ] intent-encoding-standard.md           ← Captures WHY before executing.
  [ ] fact-checking-workflow.md             ← Multi-session validation.
  [ ] parallel-document-building.md         ← Batched doc creation.
  [ ] task-list-management.md               ← Always-on task tracking.
  [ ] continuous-improvement.md             ← Improvement detection.
  [ ] proactive-reading.md                  ← When to read docs before working.
  [ ] file-organization.md                  ← Folder structure conventions.

.claude/skills/
  [ ] daily-note-management/SKILL.md        ← 7-step mandatory documentation protocol.
  [ ] daily-note-management/entry-format.md ← Entry template with emoji/tag conventions.
  [ ] daily-note-management/examples.md     ← 10 real-world examples.
  [ ] task-list-management/SKILL.md         ← Automatic task decomposition.

.claude/agents/
  [ ] research-specialist.md
  [ ] implementation-specialist.md
  [ ] discovery-agent.md
  [ ] verification.md
  [ ] codebase-analyzer.md
  [ ] codebase-locator.md
  [ ] codebase-pattern-finder.md
  [ ] thoughts-analyzer.md
  [ ] thoughts-locator.md
  [ ] ultra-research.md

.claude/hooks/
  [ ] skill-forced-eval-hook.sh             ← Forces skill evaluation every message.
  [ ] task-compliance-check.sh              ← Reminds about TaskCreate on Stop.
  [ ] daily-note-check.sh                   ← BLOCKS stopping if work undocumented.

.claude/commands/
  [ ] daily-note.md, create-daily-notes.md, read-today.md, catch-up.md, jot-idea.md
  [ ] plan.js, research.js, implement.js, progress.js, context-check.js
  [ ] planning/create_plan_generic.md, planning/validate_plan.md
  [ ] implementation/implement_plan.md
  [ ] research/research_codebase_generic.md
  [ ] development/debug.md, describe_pr.md, commit.md, create_worktree.md

.claude/settings.local.json
  [ ] hooks.UserPromptSubmit configured?
  [ ] hooks.Stop configured?

scripts/
  [ ] Daily note automation script exists and runs?
  [ ] Scheduled via Task Scheduler or WSL cron?

CLAUDE.md
  [ ] Exists at vault root?
  [ ] References rules, skills, mandatory behaviors?
```

---

## Phase 2: Decide What to Do

Based on your audit, categorize each component:

| Status | Action |
|--------|--------|
| **Missing entirely** | Fetch from this repo and install. Adapt paths. |
| **Exists but outdated** | Compare with repo version. Merge improvements you want, keep customizations you've made. |
| **Exists and current** | Skip — don't overwrite working config. |
| **Exists but different on purpose** | Keep yours. Document why it differs if useful. |

### Priority order (do these first)

1. **Rules** — highest impact, zero risk (they're just .md files Claude reads)
2. **Skills** — daily-note-management and task-list-management are the behavioral core
3. **Hooks** — skill-forced-eval-hook.sh alone raises skill activation from ~20% to ~84%
4. **Agents + Commands** — extend capabilities, install what you're missing

### Things to skip or adapt

- `scheduling/com.user.daily-note.plist` — macOS only. Use Windows Task Scheduler or WSL cron instead.
- `hooks/skill-tree-sync-hook.sh` — references K-Town-Bevy docs paths, project-specific.
- `hooks/skill-tree-health-check.sh` — scans macOS-specific paths, needs adaptation if you want it.
- Any command `.js` files with hardcoded macOS paths — update to your vault path.

---

## Phase 3: Fetch and Install Missing Pieces

For anything you identified as missing, you have two options:

### Option A: Fetch individual files from GitHub (surgical)

```bash
# Example: fetch a single rule you're missing
curl -o ".claude/rules/orchestration-quality-standard.md" \
  "https://raw.githubusercontent.com/ishtylerc/claude-code-workflow-framework/main/rules/orchestration-quality-standard.md"
```

### Option B: Clone to a temp dir and copy what you need (bulk)

```bash
git clone https://github.com/ishtylerc/claude-code-workflow-framework.git /tmp/framework
# Then selectively copy what your audit identified as missing
cp /tmp/framework/rules/missing-rule.md .claude/rules/
```

**Either way, do NOT blindly overwrite files you already have and have customized.**

---

## Phase 4: Adapt Paths

Any file you install that references paths needs updating:

```
macOS path:   /Users/ishtyler/Documents/My Brain 2.0
Windows path: /mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain
```

**Files that contain vault paths** (grep for them):
- `skills/daily-note-management/SKILL.md` — the `find` command
- `commands/*.md` — the `Working directory` line
- `commands/*.js` — the `baseDir` or output directory logic
- `scripts/daily-note-automation-v2.sh` — `VAULT_DIR` variable (line 12)

**Date command differences** (if using the v2 automation script):

| macOS | GNU/Linux (WSL) |
|-------|----------------|
| `date -j -f "%Y-%m-%d" "2026-01-15" '+%m-%d-%Y'` | `date -d "2026-01-15" '+%m-%d-%Y'` |
| `date -v-1d '+%m-%d-%Y'` | `date -d "yesterday" '+%m-%d-%Y'` |
| `date -v+1d '+%m-%d-%Y'` | `date -d "tomorrow" '+%m-%d-%Y'` |
| `stat -f %m "$file"` | `stat -c %Y "$file"` |
| `md5 -q` | `md5sum \| cut -d' ' -f1` |

Your existing `scripts/Windows/daily-note-automation.sh` already uses GNU date — if you upgrade to v2, port date patterns from your existing Windows script.

---

## Phase 5: Wire Hooks

If you installed new hooks, wire them in `.claude/settings.local.json`. Merge with your existing config — don't replace it.

The three hooks to wire:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/skill-forced-eval-hook.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/task-compliance-check.sh",
            "timeout": 5
          }
        ]
      },
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/daily-note-check.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**Prerequisites**:
- `jq` installed (for daily-note-check.sh): `sudo apt install jq`
- Scripts are executable: `chmod +x .claude/hooks/*.sh`
- Unix line endings: `dos2unix .claude/hooks/*.sh` (Windows can inject `\r`)

---

## Phase 6: Daily Note Scheduling

If you don't already have daily note automation scheduled:

### Windows Task Scheduler (recommended — works even when WSL is idle)

1. Open Task Scheduler → Create Basic Task
2. Name: "Daily Note Automation"
3. Trigger: Daily, 12:01 AM
4. Action: Start a program
   - Program: `C:\Windows\System32\wsl.exe`
   - Arguments: `-e bash -c "/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain/scripts/Windows/daily-note-automation.sh"`
5. Check "Run whether user is logged on or not"

### WSL cron (alternative — only runs when WSL is active)

```bash
crontab -e
# Add:
1 0 * * * "/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain/scripts/Windows/daily-note-automation.sh" >> /tmp/daily-note-cron.log 2>&1
```

If you already have this scheduled and working, skip this phase.

---

## Phase 7: Verify

After making changes, spot-check:

1. **Start a new session** — do you see scope assessment and skill evaluation?
2. **Do some work** — does TaskCreate fire automatically?
3. **Check daily note** — does an entry get prepended to `## Notes`?
4. **Try to stop without documenting** — does the blocking hook catch it?
5. **Run `/read-today`** — does it find and load the note?

If something doesn't work, check:
- Hook executable? (`chmod +x`)
- Line endings? (`dos2unix`)
- Paths correct? (`grep -r "ishtyler/Documents" .claude/` should return nothing on Windows)
- `jq` installed? (`which jq`)

---

## What the Reference Framework Gives You (TL;DR)

If you install everything, you get:

- **Every message**: Scope assessment (Trivial→Mega) + forced skill evaluation
- **Every work session**: Automatic task decomposition and real-time tracking
- **Complex tasks**: 5-pillar orchestration with phased execution, verification gates, progress tracking, session recovery
- **Implementation**: 16-section plan template that scales from Small to Mega, three-tier verification (Build→Test→Integration) at every phase boundary
- **Research**: Multi-agent delegation with fact-checking, lean orchestrator pattern, file-based agent piping
- **Documentation**: Every work session logged in daily notes before Claude can respond, with consistent entry format
- **Daily automation**: Midnight note creation with task rollover, stale tagging, deduplication, hierarchical summaries (weekly/quarterly/annual)

The rules and hooks are the highest-leverage pieces. Start there.
