# Claude Code Workflow Framework

A complete, production-tested workflow framework for Claude Code. 53 files across 7 layers — hooks, rules, skills, agents, commands, automation scripts, and scheduling — that transform Claude Code from a chat assistant into a disciplined project executor with multi-agent orchestration, phased implementation plans, verification gates, progress tracking, session recovery, and enforced documentation.

Battle-tested over 6+ months of daily use across security consulting, game development, and personal knowledge management.

## What This Solves

| Problem | Solution | Impact |
|---------|----------|--------|
| Claude ignores available skills ~80% of the time | Skill evaluation hook fires on every message | **~84% activation rate** |
| Complex tasks get shallow, single-pass treatment | 5-pillar orchestration standard with phased execution | Multi-round agent delegation with verification |
| No progress tracking across sessions | TaskCreate + progress.md dual tracking system | Full session recovery from any checkpoint |
| Work goes undocumented | Blocking Stop hook + daily note skill | Cannot finish without documenting |
| Implementation plans are freeform and incomplete | 16-section gold-standard plan template with scaling guide | Consistent, verifiable plans at every complexity level |
| Agent output bloats orchestrator context | Lean orchestrator pattern with file-based piping | Agents return summaries; pass data via disk |
| No verification between phases | Three-tier gates (Build + Test + Integration) per phase | Cascading verification with autonomous retry |
| Bug fixes claimed as "resolved" without testing | Hypothesis validation + user confirmation protocol | PENDING status until user confirms |

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                        CLAUDE.md                          │
│           (System prompt — role, principles)              │
├──────────────────────────────────────────────────────────┤
│                     rules/ (11 files)                     │
│        Always-loaded policies and standards               │
│  ┌─────────────┐ ┌──────────────┐ ┌───────────────────┐  │
│  │ Orchestration│ │ Sub-Agent    │ │ Implementation    │  │
│  │ Quality Std  │ │ Orchestration│ │ Plan Standard     │  │
│  │ (5 pillars)  │ │ (6 phases)   │ │ (16 sections)     │  │
│  └─────────────┘ └──────────────┘ └───────────────────┘  │
│  ┌─────────────┐ ┌──────────────┐ ┌───────────────────┐  │
│  │ Worktree    │ │ Intent       │ │ Fact-Checking     │  │
│  │ Workflow    │ │ Encoding     │ │ Workflow          │  │
│  └─────────────┘ └──────────────┘ └───────────────────┘  │
│  + task-list-management, continuous-improvement,          │
│    parallel-document-building, proactive-reading,         │
│    file-organization                                      │
├──────────────────────────────────────────────────────────┤
│                    skills/ (2 skills)                      │
│  ┌──────────────────┐  ┌─────────────────────────────┐   │
│  │ daily-note-mgmt  │  │ task-list-management        │   │
│  │ (3 files)        │  │ (1 file)                    │   │
│  └──────────────────┘  └─────────────────────────────┘   │
├──────────────────────────────────────────────────────────┤
│                   agents/ (10 definitions)                 │
│  research-specialist, implementation-specialist,          │
│  discovery-agent, verification, codebase-analyzer,        │
│  codebase-locator, codebase-pattern-finder,              │
│  thoughts-analyzer, thoughts-locator, ultra-research      │
├──────────────────────────────────────────────────────────┤
│                  commands/ (18 commands)                   │
│  Daily notes: daily-note, create-daily-notes, read-today, │
│               catch-up, jot-idea                          │
│  Workflow:    plan.js, research.js, implement.js,         │
│               progress.js, context-check.js               │
│  Planning:    create_plan_generic, validate_plan          │
│  Research:    research_codebase_generic                   │
│  Development: debug, describe_pr, commit, create_worktree │
│  Implementation: implement_plan                           │
├──────────────────────────────────────────────────────────┤
│                    hooks/ (7 scripts)                      │
│  UserPromptSubmit: skill-forced-eval (full + simple)      │
│  PostToolUse:      file-change-sync                       │
│  Stop:             task-compliance, daily-note-check,     │
│                    health-check                           │
│  Optional:         tts_response_reader.py                 │
├──────────────────────────────────────────────────────────┤
│              scripts/ + scheduling/ (3 files)             │
│  daily-note-automation-v2.sh, wrapper, launchd plist      │
└──────────────────────────────────────────────────────────┘
```

## The Three Layers

### Layer 1: Enforcement (hooks/)

Shell scripts that fire at lifecycle events, ensuring Claude follows the rules.

| Hook | Event | What It Does |
|------|-------|-------------|
| `skill-forced-eval-hook.sh` | UserPromptSubmit | Forces skill evaluation + orchestration scope assessment on every message |
| `skill-forced-eval-hook-simple.sh` | UserPromptSubmit | Lightweight version — just eval + activate |
| `task-compliance-check.sh` | Stop | Reminds Claude to use TaskCreate/TaskUpdate |
| `daily-note-check.sh` | Stop | **BLOCKS** stopping if work wasn't documented |
| `skill-tree-health-check.sh` | Stop | Scans for stale placeholders, bloat, version drift |
| `skill-tree-sync-hook.sh` | PostToolUse | Detects file changes and reminds to sync docs |
| `tts_response_reader.py` | (Optional) | Text-to-speech for Claude's responses |

### Layer 2: Standards (rules/)

Always-loaded policies that define HOW Claude approaches work.

| Rule | Purpose |
|------|---------|
| `orchestration-quality-standard.md` | **The overarching philosophy.** 5 pillars: Problem Understanding, Right-Sized Orchestration, Progress Tracking, Context-Efficient Decomposition, Continuous Validation |
| `sub-agent-orchestration.md` | **The tactical playbook.** 6-phase pattern, agent types, lean orchestrator, file piping, checkpoints, TaskCreate integration |
| `implementation-plan-standard.md` | **The plan template.** 16 sections, scaling guide (Small/Medium/Large/Mega), self-validation checklist, three-tier verification |
| `worktree-implementation-workflow.md` | Git worktree isolation for safe multi-file changes |
| `intent-encoding-standard.md` | Capture WHY (not just what) before executing |
| `fact-checking-workflow.md` | Multi-session validation with research-specialist agents |
| `parallel-document-building.md` | Batched document creation without write conflicts |
| `task-list-management.md` | Always-on task decomposition and tracking |
| `continuous-improvement.md` | Detect improvement opportunities after every task |
| `proactive-reading.md` | When to read supporting docs before working |
| `file-organization.md` | Folder structure, tagging, linking conventions |

### Layer 3: Capabilities (skills/ + agents/ + commands/)

On-demand tools that get activated when needed.

**Skills** (invoked via `Skill()` tool):
- `daily-note-management` — Enforced work documentation with 7-step protocol
- `task-list-management` — Automatic task decomposition and tracking

**Agents** (invoked via `Agent()` tool):
- `research-specialist` — Deep multi-round research with web + codebase analysis
- `implementation-specialist` — Code writing with plan-driven execution
- `discovery-agent` — Fast file/function location
- `verification` — Independent claim verification (uses Sonnet for cost efficiency)
- `codebase-analyzer` — Detailed implementation analysis
- `codebase-locator` — "Super Grep" for finding where code lives
- `codebase-pattern-finder` — Find similar implementations with code snippets
- `thoughts-analyzer` — Extract insights from research/planning documents
- `thoughts-locator` — Discover relevant documents in thoughts/ directories
- `ultra-research` — Autonomous multi-round research orchestrator

**Commands** (invoked via `/command-name`):
- Daily notes: `/daily-note`, `/create-daily-notes`, `/read-today`, `/catch-up`, `/jot-idea`
- Workflow: `/plan`, `/research`, `/implement`, `/progress`, `/context-check`
- Planning: `/planning:create_plan_generic`, `/planning:validate_plan`
- Research: `/research:research_codebase_generic`
- Development: `/development:debug`, `/development:describe_pr`, `/development:commit`, `/development:create_worktree`
- Implementation: `/implementation:implement_plan`

## The Orchestration Pipeline

How a complex task flows through the system:

```
User: "Implement feature X"
         │
         ▼
┌─ UserPromptSubmit Hook ──────────────────────────┐
│  Scope: LARGE — multi-file implementation        │
│  Skills: task-list-management YES, others...      │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Phase 0: Clarify ──────────────────────────────┐
│  AskUserQuestion: intent, scope, constraints     │
│  "What should this feel like when done?"         │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Phase 1: Context ──────────────────────────────┐
│  Read key files, grep patterns, check tests      │
│  1-5 tool calls by orchestrator                  │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Phase 1.5: Plan Mode ─────────────────────────┐
│  EnterPlanMode → 16-section template             │
│  Three-tier AC per phase                         │
│  Self-validate → ExitPlanMode                    │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Phase 2: Prompt Engineering ───────────────────┐
│  Design agent prompts with gathered context       │
│  Assign file paths, return formats                │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Phase 3: Execution (per phase) ────────────────┐
│  Launch implementation-specialist agent           │
│  Agent: writes code + tests → self-verifies      │
│  Returns: 200-word summary + PASS/FAIL           │
│                                                   │
│  ┌─ Three-Tier Verification ──────────────────┐  │
│  │ Tier 1: Build Gate (typecheck + build)     │  │
│  │ Tier 2: Test Gate (cumulative unit tests)  │  │
│  │ Tier 3: Integration Gate (E2E tests)       │  │
│  │ FAIL → DIAGNOSE-FIX-RETRY (3 attempts)    │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  TOUCHBACK: Update progress.md + TaskUpdate       │
│  → Next phase                                     │
└──────────────────────────────────────────────────┘
         │
         ▼
┌─ Stop Hooks ────────────────────────────────────┐
│  task-compliance-check: TaskCreate used?          │
│  daily-note-check: Work documented? (BLOCKING)   │
└──────────────────────────────────────────────────┘
```

## Quick Start

### Minimum Viable Setup (10 minutes)

```bash
git clone https://github.com/ishtylerc/claude-code-workflow-framework.git
cd claude-code-workflow-framework

# Copy the essentials into your project
PROJECT="/path/to/your/project"

# 1. Rules (the brain)
mkdir -p "$PROJECT/.claude/rules"
cp rules/orchestration-quality-standard.md "$PROJECT/.claude/rules/"
cp rules/sub-agent-orchestration.md "$PROJECT/.claude/rules/"
cp rules/task-list-management.md "$PROJECT/.claude/rules/"

# 2. Skill (task tracking)
mkdir -p "$PROJECT/.claude/skills/task-list-management"
cp skills/task-list-management/SKILL.md "$PROJECT/.claude/skills/task-list-management/"

# 3. Hook (skill enforcement)
mkdir -p "$PROJECT/.claude/hooks"
cp hooks/skill-forced-eval-hook.sh "$PROJECT/.claude/hooks/"
chmod +x "$PROJECT/.claude/hooks/"*.sh

# 4. Wire it up
cat > "$PROJECT/.claude/settings.local.json" << 'EOF'
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
    ]
  }
}
EOF
```

### Full Setup

See `docs/IMPLEMENTATION-GUIDE.md` for the complete setup including:
- All rules, agents, and commands
- Daily note automation with cron scheduling
- Blocking documentation compliance
- Customization guide for your project/vault

## Customization

### What to Change

| File/Section | What to Customize |
|-------------|-------------------|
| Skill SKILL.md files | Vault path, author name, `find` command paths |
| Commands `.md` files | Working directory paths |
| `daily-note-automation-v2.sh` | `VAULT_DIR`, `CLAUDE_BIN`, author name |
| `entry-format.md` | Context tags (#your_company, #your_project) |
| `jot-idea.md` | Category keyword library |
| `file-organization.md` | Your folder structure |
| Agent definitions | Remove project-specific references |

### What to Remove

Some files reference specific projects/tools. Strip or adapt:
- HumanLayer-specific commands (`humanlayer thoughts sync`, linear-ticket-reader)
- K-Town game project references
- Obsidian-specific `[[wiki links]]` (replace with standard markdown if needed)
- macOS-specific scheduling (adapt to systemd/cron for Linux)

### What to Add

Build on this framework:
- Your own skills in `.claude/skills/`
- Project-specific agents in `.claude/agents/`
- Domain-specific slash commands in `.claude/commands/`
- Work context rules in `.claude/rules/work-context/`

## File Inventory (53 files)

```
claude-code-workflow-framework/
├── README.md
├── hooks/                          # Lifecycle enforcement (7)
│   ├── skill-forced-eval-hook.sh
│   ├── skill-forced-eval-hook-simple.sh
│   ├── task-compliance-check.sh
│   ├── daily-note-check.sh
│   ├── skill-tree-health-check.sh
│   ├── skill-tree-sync-hook.sh
│   └── scripts/
│       └── tts_response_reader.py
├── rules/                          # Always-on policies (11)
│   ├── orchestration-quality-standard.md
│   ├── sub-agent-orchestration.md
│   ├── implementation-plan-standard.md
│   ├── worktree-implementation-workflow.md
│   ├── intent-encoding-standard.md
│   ├── fact-checking-workflow.md
│   ├── parallel-document-building.md
│   ├── task-list-management.md
│   ├── continuous-improvement.md
│   ├── proactive-reading.md
│   └── file-organization.md
├── skills/                         # On-demand capabilities (2)
│   ├── daily-note-management/
│   │   ├── SKILL.md
│   │   ├── entry-format.md
│   │   └── examples.md
│   └── task-list-management/
│       └── SKILL.md
├── agents/                         # Sub-agent personas (10)
│   ├── research-specialist.md
│   ├── implementation-specialist.md
│   ├── discovery-agent.md
│   ├── verification.md
│   ├── codebase-analyzer.md
│   ├── codebase-locator.md
│   ├── codebase-pattern-finder.md
│   ├── thoughts-analyzer.md
│   ├── thoughts-locator.md
│   └── ultra-research.md
├── commands/                       # Slash commands (18)
│   ├── daily-note.md
│   ├── create-daily-notes.md
│   ├── read-today.md
│   ├── catch-up.md
│   ├── jot-idea.md
│   ├── plan.js
│   ├── research.js
│   ├── implement.js
│   ├── progress.js
│   ├── context-check.js
│   ├── planning/
│   │   ├── create_plan_generic.md
│   │   └── validate_plan.md
│   ├── implementation/
│   │   └── implement_plan.md
│   ├── research/
│   │   └── research_codebase_generic.md
│   └── development/
│       ├── debug.md
│       ├── describe_pr.md
│       ├── commit.md
│       └── create_worktree.md
├── scripts/                        # Automation (2)
│   ├── daily-note-automation-v2.sh
│   └── daily-note-wrapper.sh
├── scheduling/                     # Cron config (1)
│   └── com.user.daily-note.plist
├── examples/                       # Example configs (4)
│   ├── settings-project.json
│   ├── settings-user-project.json
│   ├── settings-global.json
│   └── settings-daily-note-hook.json
└── docs/
    └── IMPLEMENTATION-GUIDE.md
```

## Replicating the Daily Note System

The daily note system is the documentation backbone — every work session gets logged, entries are consistent, and nothing falls through the cracks. Here's how to replicate it.

### The Folder Structure

Notes live in a hierarchical time-based structure:

```
vault/
├── 2026/
│   ├── Q1/
│   │   ├── [W]01/
│   │   │   ├── 01-01-2026.md      ← daily note
│   │   │   ├── 01-02-2026.md
│   │   │   └── 2026-W01.md        ← weekly summary (auto-generated)
│   │   ├── [W]02/
│   │   │   └── ...
│   │   └── ...
│   ├── 2026-Q1.md                  ← quarterly summary (auto-generated)
│   └── 2026-Annual.md              ← annual summary (auto-generated)
```

**Why `[W]##` brackets?** Visually distinct, sorts correctly. Tradeoff: Glob tools break on brackets — always use `find` instead.

**ISO week year boundary:** Dec 31 can be in Week 1 of the *next* year. The automation script uses `%G` (ISO week year) so these notes land in the correct folder.

### The Daily Note Template

Each note has 12 sections. The automation script creates them at midnight:

```markdown
---
author: Your Name
Last Modified: MM-DD-YYYY | HH:MM AM/PM
tags:
  - daily_notes
---

<< [[prev-date]] | Today | [[next-date]] >> | Week: [[YYYY-W##]]

# MM-DD-YYYY | DayName

## Agenda & Tasks
### Top Priority
### Secondary Priority        ← rolled over from yesterday's Top
### Tertiary Priority          ← rolled over from yesterday's Secondary
### Other Tasks                ← everything else, with stale tags

## Journal
### Morning Thoughts
### Evening Reflection

## Notes                       ← WHERE CLAUDE WRITES ENTRIES (primary)

## Meetings

## Ideas & Insights            ← quick ideas via /jot-idea

## Questions & Decisions

## Links & Resources

## Tomorrow's Prep
```

### Task Rollover (Automatic Priority Demotion)

The automation script demotes incomplete tasks one tier per day of gap:

```
Day 0 (yesterday):        Day 1 (today, 1-day gap):
  Top:    [A, B]            Top:    [] (fresh — you set new priorities)
  Secondary: [C]            Secondary: [A, B] (from Top)
  Tertiary:  [D]            Tertiary:  [C] (from Secondary)
  Other:     [E]            Other:     [E, D] (Other stays + Tertiary added)
```

If you skip 3 days, tasks demote 3 levels — everything cascades to Other. Tasks in Other get age tags:

| Age | Tag | Meaning |
|-----|-----|---------|
| 14+ days | `#stale` | Starting to age |
| 30+ days | `#stale_30d` | Needs attention |
| 60+ days | `#stale_60d` | Consider removing |
| 90+ days | `#stale_90d` | Likely dead |

Deduplication uses content hashing — the same task never appears twice.

### The Entry Format (How Claude Documents Work)

Every time Claude does work, it prepends an entry to the `## Notes` section. Entries follow a consistent format with three depth levels:

**Minimal** (quick fixes):
```markdown
- **02:15 PM** - **Docker Port Fix** #infrastructure #docker

  **Configuration Update**: Fixed nginx port mapping in docker-compose

  **Files Modified**:
  - 🔧 'docker-compose.yml' - Fixed port binding

  **Strategic Value**: Resolves local dev access issues.

---
```

**Standard** (most work):
```markdown
- **03:30 PM** - **Feature Implementation** #personal #k_town

  **Implementation Work**: Added character selection UI

  **Tasks Completed**:
  - ✅ Created character grid component
  - ✅ Wired selection state to game store
  - ✅ Added keyboard navigation

  **Files Modified**:
  - 📝 [[CharacterSelect]] - New component
  - 🔧 'src/stores/gameStore.ts' - Added selection state

  **Key Decisions**:
  - 💡 Grid layout scales better than carousel for 10+ characters

  **Deliverable Created**: [[CharacterSelect]] - Character selection UI component

  **Strategic Value**: Core UX feature for game demo.

---
```

**Extended** (complex multi-step work):
```markdown
- **11:20 AM** - **Research Orchestration** #research #orchestration

  **Orchestration Work**: Coordinated 3 research agents for security analysis

  **Orchestration Tasks**:
  - ✅ Loaded agents with environment context
  - ✅ Set research parameters and constraints
  - ✅ Reviewed outputs for completeness

  **Agent Activities**:
  - Research Specialist analyzed 847 alert rules
  - Identified 23 misconfigured detections
  - Generated remediation timeline

  **Files Created**:
  - 📝 [[Security Posture Analysis]] - Research output
  - 📊 'reports/alert-rules-analysis.csv' - Detailed assessment

  **Key Decisions**:
  - 💡 Prioritized by MITRE ATT&CK coverage gaps
  - 🎯 Phased approach: critical (Week 1), medium (Month 1), optimization (Q1)

  **Roadblocks**:
  - 🚧 Log retention insufficient for forensic requirements

  **Research Findings**:
  - 23 rules had overly broad scope causing alert fatigue
  - 5 critical MITRE techniques completely unmonitored

  **Deliverable Created**: [[Security Assessment Report]] - Full analysis with remediation roadmap

  **Strategic Value**: Data-driven security improvements for compliance.

---
```

### Entry Consistency Rules

These rules produce uniform entries across every session:

1. **Always PREPEND** — newest entries at the top of `## Notes`
2. **Always timestamp** — `**HH:MM AM/PM**` in 12-hour format
3. **Always tag** — minimum 2 context tags (#project, #work_type)
4. **Always separate** — `---` after every entry
5. **File references** — `[[Brackets]]` for .md files, `'quotes'` for everything else
6. **Strategic value** — every entry explains *why* the work matters
7. **Emoji conventions** — 📝 new markdown, ✏️ edited markdown, 🔧 config, 📜 scripts, 💡 insight, 🎯 decision, 🚧 roadblock, ✅ completed

### The Enforcement Stack

Four layers ensure Claude *always* documents work:

```
Layer 1: CLAUDE.md
  "MANDATORY: Daily Note Documentation"
  "ZERO TOLERANCE: Work without documentation is a critical failure"
       ↓
Layer 2: Skill (daily-note-management/)
  7-step protocol: STOP → timestamp → find note → read → prepend → verify → respond
  Invoked via Skill() tool on every work message
       ↓
Layer 3: Hook (skill-forced-eval-hook.sh)
  Forces Claude to evaluate daily-note-management skill before every response
  Without this, Claude activates skills only ~20% of the time
       ↓
Layer 4: Blocking Hook (daily-note-check.sh)
  Reads session transcript at Stop event
  If work tools were used BUT daily-note-management was NOT invoked:
    → {"decision": "block", "reason": "Must document before stopping"}
  Claude literally cannot finish without documenting
```

### How to Set It Up

**Step 1: Create your vault structure**
```bash
mkdir -p "vault/$(date '+%Y')/Q$(date '+%m' | awk '{if($1<=3) print 1; else if($1<=6) print 2; else if($1<=9) print 3; else print 4}')/[W]$(date '+%V')"
```

**Step 2: Install the skill** (tells Claude HOW to document)
```bash
mkdir -p .claude/skills/daily-note-management
cp skills/daily-note-management/* .claude/skills/daily-note-management/
# Edit SKILL.md: update vault path and find command paths
```

**Step 3: Install the hook** (forces Claude to USE the skill)
```bash
cp hooks/skill-forced-eval-hook.sh .claude/hooks/
chmod +x .claude/hooks/skill-forced-eval-hook.sh
# Add to settings.local.json UserPromptSubmit hooks
```

**Step 4: Install the blocking hook** (prevents Claude from SKIPPING documentation)
```bash
cp hooks/daily-note-check.sh .claude/hooks/
chmod +x .claude/hooks/daily-note-check.sh
# Add to settings.local.json Stop hooks (requires jq)
```

**Step 5: Install the automation** (creates notes at midnight)
```bash
cp scripts/daily-note-automation-v2.sh ~/.local/bin/
cp scripts/daily-note-wrapper.sh ~/.local/bin/
chmod +x ~/.local/bin/daily-note-*.sh
# Edit VAULT_DIR in the script
# Install launchd plist (macOS) or crontab entry (Linux)
```

**Step 6: Customize your tags**

Edit `skills/daily-note-management/entry-format.md` and replace the context tags:
```markdown
# Replace these with YOUR projects/clients/contexts:
- `#your_company` - Work items
- `#personal` - Personal projects
- `#project_alpha` - Specific project
```

### Slash Commands for Daily Notes

| Command | What It Does |
|---------|-------------|
| `/daily-note` | Create today's note with task rollover |
| `/create-daily-notes 5` | Backfill the last 5 days of missing notes |
| `/read-today` | Load today's note into context |
| `/catch-up 7` | Summarize last 7 days of notes (1/3/7/14 day options) |
| `/jot-idea fix the lighting` | Quick-add to Ideas & Insights with auto-category detection |

### What It Looks Like After a Month

After consistent daily use, you get:
- **Complete work audit trail** — search any date to see exactly what happened
- **Task archaeology** — stale tags reveal forgotten commitments
- **Pattern recognition** — `/catch-up 14` surfaces recurring themes
- **Session recovery** — new Claude sessions can read today's note for context
- **Hierarchical summaries** — weekly, quarterly, and annual notes auto-aggregate

## Supersedes

This repo consolidates and supersedes:
- [claude-code-hooks-framework](https://github.com/ishtylerc/claude-code-hooks-framework) (hooks only)
- [claude-code-daily-notes](https://github.com/ishtylerc/claude-code-daily-notes) (daily notes only)

## Credits

Built and battle-tested by [@ishtylerc](https://github.com/ishtylerc)

## License

MIT
