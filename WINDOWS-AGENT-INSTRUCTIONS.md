# Windows Agent: Full Framework Replication Instructions

**WHO THIS IS FOR**: The Claude Code instance running on Ish's Windows machine.
**WHAT TO DO**: Replicate the complete workflow framework from this repo into your environment.
**GOAL**: After following these instructions, your environment should have the same hooks, rules, skills, agents, commands, and daily note automation as the macOS instance.

## Your Environment

- **OS**: Windows (WSL/bash available)
- **Vault path**: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- **Windows vault path**: `C:\Users\Ishtyler.Etinne\nonsync\My Brain`
- **Existing script**: `scripts/Windows/daily-note-automation.sh` already exists in the vault
- **Claude Code**: Installed and working

## Execution Plan

Work through these phases sequentially. Each phase is independent — verify it works before moving to the next.

---

## Phase 1: Clone the Framework Repo

```bash
cd /tmp
git clone https://github.com/ishtylerc/claude-code-workflow-framework.git
cd claude-code-workflow-framework
```

---

## Phase 2: Install Rules (the orchestration brain)

Rules are auto-loaded into every conversation. This is the highest-impact change.

```bash
VAULT="/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain"
mkdir -p "$VAULT/.claude/rules"

# Copy ALL rules
cp rules/*.md "$VAULT/.claude/rules/"
```

**Verify**: Start a new Claude Code session in the vault. The rules should be visible in your context. You can confirm by asking Claude "what orchestration rules do you see?"

---

## Phase 3: Install Skills

```bash
mkdir -p "$VAULT/.claude/skills/daily-note-management"
mkdir -p "$VAULT/.claude/skills/task-list-management"

cp skills/daily-note-management/SKILL.md "$VAULT/.claude/skills/daily-note-management/"
cp skills/daily-note-management/entry-format.md "$VAULT/.claude/skills/daily-note-management/"
cp skills/daily-note-management/examples.md "$VAULT/.claude/skills/daily-note-management/"
cp skills/task-list-management/SKILL.md "$VAULT/.claude/skills/task-list-management/"
```

### MANDATORY EDITS for daily-note-management/SKILL.md:

Find and replace ALL occurrences:
- `/Users/ishtyler/Documents/My Brain 2.0` → `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- `Ishtyler Etienne` stays the same (same user)

The critical line is the `find` command in the skill:
```bash
# BEFORE (macOS):
find "/Users/ishtyler/Documents/My Brain 2.0" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null

# AFTER (Windows/WSL):
find "/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null
```

### MANDATORY EDITS for entry-format.md:

No path changes needed — it's format documentation only. Context tags are the same across both machines.

---

## Phase 4: Install Agents

```bash
mkdir -p "$VAULT/.claude/agents"
cp agents/*.md "$VAULT/.claude/agents/"
```

No edits needed — agent definitions are environment-agnostic.

---

## Phase 5: Install Commands

```bash
mkdir -p "$VAULT/.claude/commands"
mkdir -p "$VAULT/.claude/commands/planning"
mkdir -p "$VAULT/.claude/commands/implementation"
mkdir -p "$VAULT/.claude/commands/research"
mkdir -p "$VAULT/.claude/commands/development"

# Top-level commands
cp commands/daily-note.md "$VAULT/.claude/commands/"
cp commands/create-daily-notes.md "$VAULT/.claude/commands/"
cp commands/read-today.md "$VAULT/.claude/commands/"
cp commands/catch-up.md "$VAULT/.claude/commands/"
cp commands/jot-idea.md "$VAULT/.claude/commands/"
cp commands/plan.js "$VAULT/.claude/commands/"
cp commands/research.js "$VAULT/.claude/commands/"
cp commands/implement.js "$VAULT/.claude/commands/"
cp commands/progress.js "$VAULT/.claude/commands/"
cp commands/context-check.js "$VAULT/.claude/commands/"

# Subdirectory commands
cp commands/planning/*.md "$VAULT/.claude/commands/planning/"
cp commands/implementation/*.md "$VAULT/.claude/commands/implementation/"
cp commands/research/*.md "$VAULT/.claude/commands/research/"
cp commands/development/*.md "$VAULT/.claude/commands/development/"
```

### MANDATORY EDITS for command .md files:

Each markdown command has a `Working directory` line. Update ALL of them:

```markdown
# BEFORE (macOS):
- Working directory: `/Users/ishtyler/Documents/My Brain 2.0`

# AFTER (Windows/WSL):
- Working directory: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
```

Files to edit:
- `commands/daily-note.md`
- `commands/create-daily-notes.md`
- `commands/read-today.md`
- `commands/catch-up.md`
- `commands/jot-idea.md`

The JS commands (`plan.js`, `research.js`, etc.) have hardcoded paths in the `outputDir` logic. Update:
```javascript
// BEFORE:
const baseDir = '/Users/ishtyler/Documents/My Brain 2.0';
// AFTER:
const baseDir = '/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain';
```

Check each `.js` file for path references and update accordingly.

---

## Phase 6: Install Hooks

```bash
mkdir -p "$VAULT/.claude/hooks/scripts"

cp hooks/skill-forced-eval-hook.sh "$VAULT/.claude/hooks/"
cp hooks/task-compliance-check.sh "$VAULT/.claude/hooks/"
cp hooks/daily-note-check.sh "$VAULT/.claude/hooks/"

chmod +x "$VAULT/.claude/hooks/"*.sh
```

### Skip these hooks (macOS/project-specific):
- `skill-tree-sync-hook.sh` — references K-Town-Bevy docs paths that don't exist on Windows
- `skill-tree-health-check.sh` — scans macOS-specific skill tree paths
- `tts_response_reader.py` — optional, works on Windows but needs `pyttsx3` or `espeak`

### Wire hooks in settings

Create or edit `$VAULT/.claude/settings.local.json`:

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

**Prerequisite for daily-note-check.sh**: Install `jq`:
```bash
sudo apt install jq    # WSL/Ubuntu
# or
choco install jq       # Windows native
```

### Verify hooks:
```bash
echo '{}' | "$VAULT/.claude/hooks/skill-forced-eval-hook.sh"
# Should output the skill evaluation instructions

echo '{}' | "$VAULT/.claude/hooks/task-compliance-check.sh"
# Should output the task compliance reminder
```

---

## Phase 7: Daily Note Automation (Scheduling)

The vault already has `scripts/Windows/daily-note-automation.sh`. Compare it with the v2 script from this repo (`scripts/daily-note-automation-v2.sh`) and decide which to use.

### Option A: Keep the existing Windows script

The existing script at `scripts/Windows/daily-note-automation.sh` already works with your Windows paths. If it's working fine, keep it.

### Option B: Upgrade to v2

The v2 script has improvements: drift-resistant hardcoded template, content-hash deduplication, stale task tagging, idea carryover, and pure bash fallback. To use it:

```bash
cp scripts/daily-note-automation-v2.sh "$VAULT/scripts/Windows/daily-note-automation-v2.sh"
```

Edit `daily-note-automation-v2.sh`:
```bash
# Line 12 — Update vault path:
VAULT_DIR="/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain"

# Line 14 — Update Claude binary path (find yours with: which claude)
CLAUDE_BIN="$(which claude)"

# macOS date commands → Linux date commands:
# The v2 script uses macOS `date -j` syntax. You need GNU date instead.
# See "Date Command Conversion" section below.
```

### Date Command Conversion (CRITICAL for v2 on WSL)

The v2 script uses macOS `date -j -f` syntax. WSL uses GNU date. Key conversions:

```bash
# macOS → GNU/Linux equivalents:

# Parse a date:
# macOS: date -j -f "%Y-%m-%d" "2026-01-15" '+%m-%d-%Y'
# Linux: date -d "2026-01-15" '+%m-%d-%Y'

# Yesterday:
# macOS: date -v-1d '+%m-%d-%Y'
# Linux: date -d "yesterday" '+%m-%d-%Y'

# Tomorrow:
# macOS: date -v+1d '+%m-%d-%Y'
# Linux: date -d "tomorrow" '+%m-%d-%Y'

# File modification time:
# macOS: stat -f %m "$file"
# Linux: stat -c %Y "$file"

# Epoch from date:
# macOS: date -j -f "%Y-%m-%d" "$DATE" '+%s'
# Linux: date -d "$DATE" '+%s'

# Date from epoch:
# macOS: date -j -f "%s" "$EPOCH" '+%m-%d-%Y'
# Linux: date -d "@$EPOCH" '+%m-%d-%Y'

# MD5 hash:
# macOS: md5 -q
# Linux: md5sum | cut -d' ' -f1
```

The existing `scripts/Windows/daily-note-automation.sh` already uses GNU date syntax — if you choose Option B, port the GNU date patterns from the existing Windows script into v2's structure, or run a find-and-replace using the table above.

### Schedule with Task Scheduler (Windows native)

Create a Windows Task Scheduler task:

1. Open Task Scheduler → Create Basic Task
2. **Name**: "Daily Note Automation"
3. **Trigger**: Daily, at 12:01 AM
4. **Action**: Start a program
   - **Program**: `C:\Windows\System32\wsl.exe`
   - **Arguments**: `-e bash -c "/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain/scripts/Windows/daily-note-automation.sh"`
5. Check "Run whether user is logged on or not"

### Alternative: WSL cron

```bash
# In WSL:
crontab -e

# Add:
1 0 * * * /mnt/c/Users/Ishtyler.Etinne/nonsync/My\ Brain/scripts/Windows/daily-note-automation.sh >> /tmp/daily-note-cron.log 2>&1
```

**Note**: WSL cron only runs when WSL is active. For reliability when the machine sleeps, use Windows Task Scheduler instead.

---

## Phase 8: Create or Update CLAUDE.md

If the vault doesn't already have a `CLAUDE.md` at the root, create one that references the installed rules and skills. At minimum:

```markdown
# CLAUDE.md

## Assigned Role: Personal Knowledge Management Assistant

## Mandatory Behaviors

### Daily Note Documentation
MANDATORY: Document ALL work in today's daily note before responding.
See `.claude/skills/daily-note-management/SKILL.md` for the full protocol.

### Task Tracking
MANDATORY: Automatically create and maintain task lists for every conversation.
See `.claude/rules/task-list-management.md` for the full protocol.

### Orchestration
Follow the orchestration quality standard for all Medium+ tasks.
See `.claude/rules/orchestration-quality-standard.md`.

## Rules
Auto-loaded from `.claude/rules/` — see that directory for all policies.

## Skills
- `daily-note-management` — Enforced work documentation
- `task-list-management` — Automatic task tracking

## Important
- NEVER create daily/weekly/quarterly/annual note FILES unless explicitly permitted
- ALWAYS prefer editing existing files over creating new ones
- NEVER push to git without explicit user approval
```

If a CLAUDE.md already exists, merge the mandatory behaviors section into it.

---

## Phase 9: Verify Everything

Run these checks in order:

### 1. Rules loaded
Start a new session, ask: "What rules do you see in .claude/rules/?"
Expected: Should list all 11 rules.

### 2. Skills available
Ask: "What skills are available?"
Expected: Should list `daily-note-management` and `task-list-management`.

### 3. Hooks firing
Send any message. Check that:
- Scope assessment appears (TRIVIAL/SMALL/MEDIUM/etc.)
- Skill evaluation list appears
- TaskCreate is used for work items

### 4. Daily note documentation
Do some work (search for a file, edit something). Check that:
- An entry is prepended to today's `## Notes` section
- Entry has timestamp, tags, file references, strategic value

### 5. Blocking hook
Try to finish a session after doing work without documenting. The hook should block with:
"STOP: Work was completed but not documented..."

### 6. Slash commands
```
/read-today        → Should load today's note
/jot-idea test     → Should add to Ideas & Insights
```

### 7. Automation script
```bash
cd "/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain"
./scripts/Windows/daily-note-automation.sh
# Check that a daily note was created with proper template
```

---

## Troubleshooting

### Hooks not firing on Windows
- Ensure WSL bash is available: `wsl -e bash -c "echo works"`
- Check that `.sh` files have Unix line endings (not `\r\n`): `dos2unix .claude/hooks/*.sh`
- Check executable permission: `chmod +x .claude/hooks/*.sh`

### `find` command slow on WSL
- WSL filesystem access to `/mnt/c/` is slower than native Linux paths
- The `find` command in the daily note skill may take 1-2 seconds instead of instant
- This is normal — the 5-second timeout on hooks accommodates this

### `jq` not found
```bash
sudo apt update && sudo apt install jq
```

### Line ending issues
Windows can inject `\r` into shell scripts. Fix:
```bash
sudo apt install dos2unix
dos2unix "$VAULT/.claude/hooks/"*.sh
dos2unix "$VAULT/scripts/Windows/"*.sh
```

### Git shows all files as modified after copying
The repo may have been cloned with Windows line endings. Fix:
```bash
git config core.autocrlf input
```

---

## Summary Checklist

After completing all phases:

- [ ] 11 rules in `.claude/rules/`
- [ ] 2 skills (4 files) in `.claude/skills/`
- [ ] 10 agents in `.claude/agents/`
- [ ] 18 commands in `.claude/commands/`
- [ ] 3 hooks in `.claude/hooks/` (eval + compliance + blocking)
- [ ] Hooks wired in `.claude/settings.local.json`
- [ ] Daily note automation scheduled (Task Scheduler or WSL cron)
- [ ] CLAUDE.md exists with mandatory behaviors
- [ ] All vault paths updated from macOS to Windows/WSL
- [ ] `jq` installed for blocking hook
- [ ] Line endings verified (Unix, not Windows)
- [ ] Verification tests passed (Phase 9)
