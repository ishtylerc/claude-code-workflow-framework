#!/bin/bash

# Daily Note Documentation Check Hook
# Fires when Claude tries to stop - blocks if work was done but not documented
# Location: ~/.claude/hooks/daily-note-check.sh

# Read hook input from stdin
INPUT=$(cat)

# Extract key fields
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops - if stop_hook_active is true, we already blocked once
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# If no transcript path, allow stopping
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Check if work was done by looking for tool calls in transcript
# Look for Edit, Write, Bash, WebSearch, Task tools (indicators of work)
WORK_TOOLS="Edit|Write|Bash|WebSearch|Task|Grep|Glob"
if grep -qE "\"tool\":\s*\"($WORK_TOOLS)\"" "$TRANSCRIPT_PATH" 2>/dev/null; then

  # Check if daily-note-management skill was already invoked
  if grep -q "daily-note-management" "$TRANSCRIPT_PATH" 2>/dev/null; then
    # Skill was invoked - allow stopping
    exit 0
  fi

  # Work was done but skill not invoked - block and instruct
  echo '{
    "decision": "block",
    "reason": "STOP: Work was completed but not documented in daily notes. You MUST invoke the `daily-note-management` skill NOW using the Skill tool to document this session before you can stop. This is mandatory per CLAUDE.md requirements."
  }'
  exit 0
fi

# No work detected - allow stopping
exit 0
