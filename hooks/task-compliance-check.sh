#!/bin/bash
# Task Compliance Stop Hook
# Fires at end of Claude's turn as a lightweight backstop reminder.
# Stop hooks cannot detect tool usage — this is prompt-layer reinforcement.

cat <<'EOF'
TASK COMPLIANCE CHECK: Before finalizing your response, verify:
1. Did this conversation involve work? If YES:
   - Were tasks created via TaskCreate at the start?
   - Were completed tasks marked via TaskUpdate?
   - Are there any new work items that need TaskCreate?
2. If you have NOT used TaskCreate/TaskUpdate in a work conversation,
   use them NOW before your response is complete.
EOF
