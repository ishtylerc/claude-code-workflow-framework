# Implementation Guide

Complete setup guide for deploying this framework into a new Claude Code project.

## Prerequisites

- Claude Code CLI installed and working
- A project directory
- `jq` (only for the blocking daily-note-check hook): `brew install jq`

## Setup Tiers

### Tier 1: Core Orchestration (5 minutes)

The minimum that makes Claude significantly better at complex tasks.

```bash
PROJECT="/path/to/your/project"

# Rules — the orchestration brain
mkdir -p "$PROJECT/.claude/rules"
cp rules/orchestration-quality-standard.md "$PROJECT/.claude/rules/"
cp rules/sub-agent-orchestration.md "$PROJECT/.claude/rules/"
cp rules/implementation-plan-standard.md "$PROJECT/.claude/rules/"
cp rules/task-list-management.md "$PROJECT/.claude/rules/"
cp rules/intent-encoding-standard.md "$PROJECT/.claude/rules/"

# Skill — automatic task tracking
mkdir -p "$PROJECT/.claude/skills/task-list-management"
cp skills/task-list-management/SKILL.md "$PROJECT/.claude/skills/task-list-management/"

# Hook — force skill evaluation
mkdir -p "$PROJECT/.claude/hooks"
cp hooks/skill-forced-eval-hook.sh "$PROJECT/.claude/hooks/"
cp hooks/task-compliance-check.sh "$PROJECT/.claude/hooks/"
chmod +x "$PROJECT/.claude/hooks/"*.sh

# Settings
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
      }
    ]
  }
}
EOF
```

**What you get:** Scope assessment on every message, forced skill evaluation, task tracking, orchestration standards for complex work, implementation plan templates.

### Tier 2: Add Agents + Commands (+5 minutes)

Gives Claude specialized sub-agents and slash commands.

```bash
# Agents
mkdir -p "$PROJECT/.claude/agents"
cp agents/*.md "$PROJECT/.claude/agents/"

# Commands
mkdir -p "$PROJECT/.claude/commands"/{planning,implementation,research,development}
cp commands/*.md "$PROJECT/.claude/commands/" 2>/dev/null
cp commands/*.js "$PROJECT/.claude/commands/" 2>/dev/null
cp commands/planning/*.md "$PROJECT/.claude/commands/planning/"
cp commands/implementation/*.md "$PROJECT/.claude/commands/implementation/"
cp commands/research/*.md "$PROJECT/.claude/commands/research/"
cp commands/development/*.md "$PROJECT/.claude/commands/development/"

# Remaining rules
cp rules/*.md "$PROJECT/.claude/rules/"
```

**What you get:** Multi-agent research, implementation planning commands, codebase analysis agents, fact-checking workflows, worktree isolation.

### Tier 3: Daily Notes + Documentation Enforcement (+10 minutes)

Adds daily note automation and blocking documentation compliance.

```bash
# Daily note skill
mkdir -p "$PROJECT/.claude/skills/daily-note-management"
cp skills/daily-note-management/*.md "$PROJECT/.claude/skills/daily-note-management/"

# Blocking hook
cp hooks/daily-note-check.sh "$PROJECT/.claude/hooks/"
chmod +x "$PROJECT/.claude/hooks/daily-note-check.sh"
```

Add to your settings.json Stop hooks:
```json
{
  "hooks": [
    {
      "type": "command",
      "command": ".claude/hooks/daily-note-check.sh",
      "timeout": 30
    }
  ]
}
```

### Tier 4: Cron Automation (+15 minutes)

Automated daily note creation at midnight with task rollover.

```bash
# Install scripts
mkdir -p ~/.local/bin
cp scripts/daily-note-automation-v2.sh ~/.local/bin/
cp scripts/daily-note-wrapper.sh ~/.local/bin/
chmod +x ~/.local/bin/daily-note-*.sh

# Edit VAULT_DIR in the script
vim ~/.local/bin/daily-note-automation-v2.sh
# Change line 12: VAULT_DIR="/path/to/your/vault"

# macOS: Install launchd
cp scheduling/com.user.daily-note.plist ~/Library/LaunchAgents/
# Edit paths in the plist
vim ~/Library/LaunchAgents/com.user.daily-note.plist
launchctl load ~/Library/LaunchAgents/com.user.daily-note.plist

# Linux: Use systemd or crontab
# crontab -e → 1 0 * * * ~/.local/bin/daily-note-wrapper.sh
```

### Tier 5: Optional — `/second-opinion` Codex cross-check (+10 minutes)

Adds the `/second-opinion` slash command for blind cross-checks against OpenAI's Codex CLI with
multi-agent scaffolding (Devil's Advocate / Domain Expert / Pragmatist / Synthesis), autonomous
ideation classification, and an opt-in Claude-side research mode.

**Prerequisites**:
- OpenAI Codex CLI installed (`codex --version` works) — install: https://developers.openai.com/codex/
- `OPENAI_API_KEY` set in your shell environment (or you're logged in via `codex login`)

```bash
# 1. Add the analyst profile to ~/.codex/config.toml (full config block in docs/SECOND-OPINION-SETUP.md §3)
mkdir -p ~/.codex
cat >> ~/.codex/config.toml <<'EOF'
[features]
multi_agent = true

[agents]
max_threads = 4
max_depth = 1
job_max_runtime_seconds = 300

[profiles.analyst]
model_reasoning_effort = "high"
sandbox_mode = "read-only"
EOF

# 2. Make the helper scripts executable
chmod +x scripts/codex-banner.sh scripts/codex-diagnose.sh

# 3. Verify the command is wired up
.claude/scripts/codex-banner.sh        # one-line banner
.claude/scripts/codex-diagnose.sh --quick   # env health check (skips slow model probes)

# 4. (Optional) Bump the model in config.toml — the command uses whatever's configured
# Latest as of v1.3.0: `model = "gpt-5.5"`
```

**Full setup details, flag reference, and troubleshooting**: see `docs/SECOND-OPINION-SETUP.md`.

## Customization Checklist

After copying files, update these references:

### Paths (MUST change)
- [ ] `VAULT_DIR` in `daily-note-automation-v2.sh` (line 12)
- [ ] Working directory in all command `.md` files
- [ ] `find` command paths in `skills/daily-note-management/SKILL.md`
- [ ] Home directory in `scheduling/com.user.daily-note.plist`
- [ ] Home directory in `scripts/daily-note-wrapper.sh`

### Personal info (SHOULD change)
- [ ] Author name "Ishtyler Etienne" in templates/skills
- [ ] Context tags in `entry-format.md` (replace #vast_bank, #secureda, etc.)
- [ ] Category keywords in `commands/jot-idea.md`
- [ ] Folder structure in `rules/file-organization.md`

### Project-specific references (MAY remove)
- [ ] K-Town/Bevy references in `skill-tree-sync-hook.sh` and `skill-tree-health-check.sh`
- [ ] HumanLayer references in some commands (`humanlayer thoughts sync`)
- [ ] Linear ticket references in some commands
- [ ] Obsidian `[[wiki links]]` if not using Obsidian

## Verifying the Setup

### Test hooks
```bash
# Should output skill evaluation instructions
echo '{}' | .claude/hooks/skill-forced-eval-hook.sh

# Should output task compliance reminder
echo '{}' | .claude/hooks/task-compliance-check.sh

# Should allow (no transcript)
echo '{}' | .claude/hooks/daily-note-check.sh
```

### Test in a session
1. Start Claude Code in your project
2. Ask it to do something ("search for X in the codebase")
3. You should see:
   - Scope assessment (TRIVIAL/SMALL/MEDIUM/etc.)
   - Skill evaluation list
   - TaskCreate calls
   - Daily note entry (if Tier 3 installed)

### Test automation
```bash
~/.local/bin/daily-note-automation-v2.sh
cat ~/.local/share/daily-notes-logs/automation-$(date '+%Y-%m-%d').log
```

## How the Pieces Fit Together

```
settings.local.json
  └── Defines which hooks fire at which lifecycle events
       └── skill-forced-eval-hook.sh (UserPromptSubmit)
            └── Forces Claude to read skills/ and evaluate each one
                 └── task-list-management SKILL.md gets activated
                      └── References task-list-management.md rule
                 └── daily-note-management SKILL.md gets activated
                      └── Uses entry-format.md + examples.md

       └── task-compliance-check.sh (Stop)
            └── Reminds Claude about TaskCreate if forgotten

       └── daily-note-check.sh (Stop, BLOCKING)
            └── Reads transcript, blocks if work undocumented

rules/ (always loaded)
  └── orchestration-quality-standard.md
       └── References sub-agent-orchestration.md for tactical patterns
       └── References implementation-plan-standard.md for plan template
  └── sub-agent-orchestration.md
       └── Defines agent types → agents/*.md definitions
       └── Defines file conventions → thoughts/[type]/YYYY-MM-DD-[slug]/
  └── implementation-plan-standard.md
       └── References worktree-implementation-workflow.md
       └── References intent-encoding-standard.md

commands/ (user-invoked)
  └── /plan → plan.js creates plan files
  └── /implement → implement.js creates progress files
  └── /planning:create_plan_generic → follows implementation-plan-standard.md
```

## Troubleshooting

### "No skills found" in evaluation
- Skills need to be in `.claude/skills/<name>/SKILL.md` (exact path)
- Check that SKILL.md exists and has content

### Rules not loading
- Rules must be in `.claude/rules/*.md`
- They load automatically — no configuration needed
- Check for syntax errors that might prevent parsing

### Agents not available
- Agent definitions go in `.claude/agents/*.md`
- They're used via the `Agent` tool with `subagent_type` parameter
- The agent name in the tool call must match the filename (without .md)

### Hook not firing
- Check `chmod +x` on the script
- Check the path in settings.json (relative for project-level, absolute for user-level)
- Check timeout — if script exceeds timeout, it's killed silently

### Daily note not found
- The `[W]##` folder naming breaks Glob — always use `find` command
- Check ISO week year boundary (Dec 31 may be in next year's folder)
