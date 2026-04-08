---
name: daily-note-management
description: |
  MANDATORY pre-response workflow for documenting ALL completed work in daily notes.
  INVOKE THIS SKILL after completing ANY work (file edits, searches, research, commands,
  troubleshooting, agent orchestration, investigations) and BEFORE responding to user.
  Triggers: work completed, before responding, log work, document tasks, daily note entry,
  prepend notes, track completion. ZERO TOLERANCE - work without documentation is failure.
---

# Daily Note Management Skill

## Purpose

This skill enforces mandatory daily note documentation for ALL work performed by Claude. It ensures comprehensive work tracking, maintains context across sessions, and provides a complete audit trail of all activities.

## 🚨 CRITICAL: PRE-RESPONSE REQUIREMENT

**MANDATORY**: Claude MUST add a daily note entry BEFORE responding to the user whenever any work has been completed.

**🚨 ZERO TOLERANCE ENFORCEMENT**: This is a CRITICAL SYSTEM REQUIREMENT with no exceptions. Failure to document work before responding is a severe violation.

## Core Protocol (MANDATORY SEQUENCE)

### 7-Step Implementation Process

1. **STOP**: Before any response to user, ask "Have I completed any work that requires documentation?"
2. **Run timestamp command**: `date '+%I:%M %p %m-%d-%Y'`
3. **Locate today's daily note**: **⚠️ MUST use `find` command, NOT Glob** (brackets in path break Glob):
   ```bash
   find "/Users/ishtyler/Documents/My Brain 2.0" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null
   ```
4. **Read existing Notes section**: Understand current content
5. **Add comprehensive entry**: Use full format template at TOP of Notes section
6. **Verify placement**: Confirm entry was prepended correctly
7. **ONLY THEN respond to user**: Documentation must be complete before any user response

### Entry Requirements

- **Always document BEFORE responding** - Never provide a response without first updating the daily note
- **Add entries directly under "## Notes" header** in today's daily note
- **PREPEND entries** - New entries go to the TOP of existing Notes section content
- **Use comprehensive format** - Follow the detailed template (see entry-format.md)
- **File References** - Use [[Double Brackets]] for ALL .md files (e.g., [[Mail-Bombing-Mitigation-Proposal]]), use 'single quotes with relative paths' for non-markdown files (e.g., 'server/config.json')
- **Add separator** - Append '---' to each note entry to separate from previous entries

## What Gets Logged

**Daily note entries should be a log of the work being done by the agent(s), big or small.**

### Always Log (ALL of these)
- ✅ Creating or modifying any files
- ✅ Running searches or investigations
- ✅ Answering questions that required looking things up
- ✅ Making edits (even small ones)
- ✅ Running commands or scripts
- ✅ Orchestrating sub-agents
- ✅ Troubleshooting or debugging
- ✅ Research of any depth
- ✅ Any task that took meaningful effort

### Never Log
- ❌ Pure conversation (greetings, clarifying questions before work starts)
- ❌ Reading the daily note itself
- ❌ Simply explaining something from memory without investigation

**Simple Rule**: If you did work → Log it

## File Reference Conventions

### Markdown Files
Use [[Double Brackets]] for ALL `.md` files **regardless of location**:
- ✅ [[Mail-Bombing-Mitigation-Proposal]]
- ✅ [[Daily Note Management Guide]]
- ✅ [[Command Usage Guide]]
- ✅ [[README]] (even if in external repo like K-Town-Bevy/docs/)
- ✅ [[SKILL]] (even if in .claude/skills/)

**IMPORTANT**: The convention is based on **file type**, not location. Even if a file is outside the vault (e.g., in a git repo subdirectory), if it ends in `.md`, use [[brackets]]. This maintains consistency and signals "this is a markdown document."

### Non-Markdown Files
Use 'single quotes with relative paths' for all other file types:
- ✅ 'server/config.json'
- ✅ 'scripts/daily-note-automation-macos.sh'
- ✅ '.github/workflows/ci.yml'
- ✅ 'Cargo.toml'

## Daily Note Structure Reference

### Folder Structure
```
YYYY/QX/[W]##/MM-DD-YYYY.md
```

Examples:
- `2025/Q4/[W]50/12-09-2025.md`
- `2025/Q1/[W]01/01-02-2025.md`

### Critical File Search Pattern

**⚠️ IMPORTANT**: The folder structure uses literal brackets `[W]##` (e.g., `[W]03`). The Glob tool interprets brackets as character classes, causing file searches to FAIL.

**ALWAYS use the Bash `find` command** to locate daily notes:

```bash
# Find today's daily note (replace MM-DD-YYYY with actual date)
find "/Users/ishtyler/Documents/My Brain 2.0" -name "MM-DD-YYYY.md" -type f 2>/dev/null
```

Example: To find January 12, 2026 daily note:
```bash
find "/Users/ishtyler/Documents/My Brain 2.0" -name "01-12-2026.md" -type f 2>/dev/null
```

**Why Glob Fails**:
- Path contains `[W]03` which Glob interprets as "match any character W, ], 0, or 3"
- Pattern `**/*01-12-2026.md` returns "No files found" even when file exists
- The `find` command treats brackets literally and works correctly

**Alternative (if Glob must be used)**: Escape brackets with backslash:
```
**/\[W\]**/MM-DD-YYYY.md
```

### Task Rollover Logic
The automated daily note creation script (`scripts/daily-note-automation-macos.sh`) rolls over incomplete tasks:
- **Top Priority** → Secondary Priority
- **Secondary Priority** → Tertiary Priority
- **Tertiary Priority** → Other Tasks
- **Only incomplete tasks** (- [ ]) are rolled over
- **Completed tasks** (- [x]) are excluded

## Template Structure Overview

Daily notes created by automation include these sections:
1. **YAML frontmatter** - Date, day, week, quarter, year, tags
2. **Navigation links** - Previous/next day, week link
3. **Agenda & Tasks** - 4 priority levels with automatic rollover
4. **Journal** - Morning Thoughts, Evening Reflection
5. **Notes** - Main work documentation section (PRIMARY FOCUS)
6. **Meetings** - Meeting notes and references
7. **Ideas & Insights** - Brainstorming and discoveries
8. **Questions & Decisions** - Decisions made and questions raised
9. **Links & Resources** - Reference materials
10. **Daily Metrics** - Quantitative tracking
11. **Tomorrow's Prep** - Next day preparation
12. **Tags** - Contextual categorization

**IMPORTANT**: The authoritative template is hardcoded in `scripts/daily-note-automation-macos.sh` (lines 593-679). DO NOT reference "CLAUDE.md template" for daily note format.

## Entry Format

See `entry-format.md` for the complete comprehensive entry template with all fields and descriptions.

### Quick Template Reference
```markdown
- **HH:MM AM/PM** - **[Descriptive Title]** #tag1 #tag2 #tag3

  **[WORK TYPE]**: [Brief description of work completed]

  **[Work Category]**:
  - ✅ [Primary deliverable completed]
  - ✅ [Secondary task accomplished]

  **Files Modified**:
  - 📝 [[File Name]] - [Description of changes]
  - 🔧 'relative/path/to/config.json' - [Configuration updates]

  **[Key Decisions/Insights]**:
  - 💡 [Important discovery or decision made]

  **[Roadblocks/Issues]**:
  - 🚧 [Obstacle encountered and how addressed]

  **[Results/Impact Category]**:
  - [Key finding or result]

  **Deliverable Created**: [[Document Name]] - [Description]

  **Strategic Value**: [How this work advances goals/objectives]

---
```

## Context Tags

**MANDATORY**: All entries must include appropriate context tags:
- `#vast_bank` - Vast Bank work
- `#personal` - Personal projects, research, learning
- `#mbanq` - Mbanq projects and initiatives
- `#secureda` - Secureda projects
- `#black_cat_security` - Black Cat Security projects
- `#research` - Research activities
- `#documentation` - Documentation work
- `#infrastructure` - Infrastructure/DevOps work
- `#security` - Security-related work

## Enforcement Rules

### Zero Tolerance Policy
- **ZERO TOLERANCE**: Work completion without daily note documentation is a critical failure
- **No exceptions**: Even minor work requires documentation before response
- **Quality requirement**: Use the comprehensive format for all entries
- **Strategic context**: Always include how work advances broader objectives

### Quality Standards
1. **Comprehensive**: Include all relevant fields from the template
2. **Specific**: Provide concrete details, not vague descriptions
3. **Strategic**: Connect tactical work to broader objectives
4. **Accurate**: Ensure file references and technical details are correct
5. **Timely**: Document immediately after work completion, before responding

## Examples

See `examples.md` for real-world examples of:
- Simple work entries
- Research completion entries
- Multi-file modification entries
- Sub-agent orchestration entries
- Slash command completion entries

## Related Documentation

- **Detailed Procedures**: [[CLAUDE-DAILY-NOTES]]
- **Management Guide**: [[Daily Note Management Guide]]
- **Strategic Integration**: [[Strategic Planning System]]
- **Slash Commands**: [[Command Usage Guide]]

## Quick Reference Commands

```bash
# Get timestamp for daily note entry
date '+%I:%M %p %m-%d-%Y'

# Get date for file search
date '+%m-%d-%Y'

# Find today's daily note (MUST use find, NOT Glob - brackets in path break Glob)
find "/Users/ishtyler/Documents/My Brain 2.0" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null

# One-liner: Get timestamp and find file path
echo "Timestamp: $(date '+%I:%M %p')" && find "/Users/ishtyler/Documents/My Brain 2.0" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null
```

## Table Formatting (CRITICAL)

**Tables MUST start at column 0** - no leading whitespace. This is a Markdown requirement.

### Why This Matters
Tables inside bulleted list items naturally get indented. However, indented tables render as plain text instead of formatted tables in Obsidian and most Markdown renderers.

### Correct Pattern
When including a table in a daily note entry:

```markdown
- **05:50 PM** - **Completed Research** #tag

  **Summary of findings**:

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data A   | Data B   | Data C   |

  **Next steps**:
  - Continue with implementation
```

### Key Rules
1. **Add a blank line** before the table
2. **Remove ALL leading spaces** from table rows (tables must be at column 0)
3. **Add a blank line** after the table before resuming indented content
4. The surrounding content can stay indented, but the table itself must be flush left

### Wrong (Will Not Render)
```markdown
  | Column 1 | Column 2 |
  |----------|----------|
  | Data     | More     |
```

### Correct (Will Render)
```markdown
| Column 1 | Column 2 |
|----------|----------|
| Data     | More     |
```

## Common Pitfalls to Avoid

1. ❌ Responding to user before documenting work
2. ❌ Appending entries to bottom of Notes section (should PREPEND to top)
3. ❌ Using incomplete entry format (missing fields)
4. ❌ Forgetting file reference conventions ([[brackets]] vs 'quotes')
5. ❌ Missing context tags
6. ❌ Omitting strategic value explanation
7. ❌ Not separating entries with '---'
8. ❌ **Indenting tables** - Tables MUST start at column 0 (no leading spaces)
9. ❌ **Using Glob to find daily notes** - Path contains `[W]##` which Glob interprets as character class; use `find` command instead

## Success Criteria

✅ Entry added BEFORE user response
✅ Entry prepended to TOP of Notes section
✅ Comprehensive format used with all relevant fields
✅ File references use correct conventions
✅ Context tags included
✅ Strategic value explained
✅ Separator '---' added
✅ Timestamp accurate
