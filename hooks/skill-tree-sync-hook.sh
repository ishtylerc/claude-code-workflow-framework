#!/bin/bash
# Skill Tree Auto-Sync Hook
# Triggers on PostToolUse to detect K-Town docs changes and prompt for sync
#
# This hook checks if recent tool usage modified files in K-Town-Bevy/docs/
# and outputs a reminder to sync the skill tree docs-mirror.md

# Define paths
KTOWN_DOCS="/Users/ishtyler/Documents/My Brain 2.0/Work/Secureda/K-Town/K-Town-Bevy/docs"
SKILL_TREE_MIRROR="/Users/ishtyler/Documents/My Brain 2.0/.claude/skills/software-development/projects/k-town-bevy/docs-mirror.md"

# Check if the tool was Edit or Write and path contains K-Town-Bevy/docs
# This info would be passed via environment or parsed from context
# For now, output a general reminder that can be filtered

# Get last modified time of K-Town docs (any file)
if [ -d "$KTOWN_DOCS" ]; then
    DOCS_MTIME=$(find "$KTOWN_DOCS" -type f -name "*.md" -mmin -5 2>/dev/null | head -1)

    if [ -n "$DOCS_MTIME" ]; then
        cat << 'EOF'
SKILL-TREE-SYNC-CHECK: K-Town-Bevy docs were recently modified.
Consider syncing to skill tree: projects/k-town-bevy/docs-mirror.md
EOF
    fi
fi
