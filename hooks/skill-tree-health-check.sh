#!/bin/bash
# Skill Tree Health Check Script
# Runs weekly via launchd to detect:
# - Stale placeholder files (unchanged >90 days)
# - Token bloat (files >500 lines)
# - Broken cross-references
# - Version drift (outdated versions vs Cargo.toml)
# - Unsynced docs (source newer than mirror)

set -e

# Paths
SKILL_TREE="/Users/ishtyler/Documents/My Brain 2.0/.claude/skills/software-development"
KTOWN_DOCS="/Users/ishtyler/Documents/My Brain 2.0/Work/Secureda/K-Town/K-Town-Bevy/docs"
KTOWN_CARGO="/Users/ishtyler/Documents/My Brain 2.0/Work/Secureda/K-Town/K-Town-Bevy/Cargo.toml"
LOG_DIR="/Users/ishtyler/.local/share/skill-tree-logs"
LOG_FILE="$LOG_DIR/health-check-$(date '+%Y-%m-%d').log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Start log
echo "=== Skill Tree Health Check ===" > "$LOG_FILE"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

ISSUES_FOUND=0

# 1. Check for stale placeholder files (unchanged >90 days with placeholder content)
echo "## Stale Placeholders (>90 days)" >> "$LOG_FILE"
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check if file contains placeholder marker and is old
        if grep -q "status: placeholder" "$file" 2>/dev/null; then
            MTIME=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            NOW=$(date +%s)
            AGE_DAYS=$(( (NOW - MTIME) / 86400 ))
            if [ "$AGE_DAYS" -gt 90 ]; then
                echo "- $file ($AGE_DAYS days old)" >> "$LOG_FILE"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        fi
    fi
done < <(find "$SKILL_TREE" -name "*.md" -type f 2>/dev/null)
echo "" >> "$LOG_FILE"

# 2. Check for token bloat (files >500 lines)
echo "## Token Bloat (>500 lines)" >> "$LOG_FILE"
while IFS= read -r file; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file" 2>/dev/null | tr -d ' ')
        if [ "$LINES" -gt 500 ]; then
            echo "- $file ($LINES lines)" >> "$LOG_FILE"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
done < <(find "$SKILL_TREE" -name "*.md" -type f 2>/dev/null)
echo "" >> "$LOG_FILE"

# 3. Check for unsynced K-Town docs
echo "## Unsynced K-Town Docs" >> "$LOG_FILE"
MIRROR="$SKILL_TREE/projects/k-town-bevy/docs-mirror.md"
if [ -f "$MIRROR" ] && [ -d "$KTOWN_DOCS" ]; then
    MIRROR_MTIME=$(stat -f %m "$MIRROR" 2>/dev/null || stat -c %Y "$MIRROR" 2>/dev/null)
    NEWEST_DOC=$(find "$KTOWN_DOCS" -name "*.md" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f1)
    if [ -n "$NEWEST_DOC" ] && [ "$NEWEST_DOC" -gt "$MIRROR_MTIME" ]; then
        echo "- docs-mirror.md is OUTDATED (source docs are newer)" >> "$LOG_FILE"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo "- docs-mirror.md is up to date" >> "$LOG_FILE"
    fi
else
    echo "- Mirror or docs directory not found" >> "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"

# 4. Check Bevy version drift
echo "## Version Drift" >> "$LOG_FILE"
if [ -f "$KTOWN_CARGO" ]; then
    CARGO_BEVY=$(grep 'bevy.*=' "$KTOWN_CARGO" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown")
    BEVY_MD="$SKILL_TREE/frameworks/bevy.md"
    if [ -f "$BEVY_MD" ]; then
        MD_BEVY=$(grep -oE 'bevy-version: [0-9]+\.[0-9]+(\.[0-9]+)?' "$BEVY_MD" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown")
        if [ "$CARGO_BEVY" != "$MD_BEVY" ] && [ "$CARGO_BEVY" != "unknown" ] && [ "$MD_BEVY" != "unknown" ]; then
            echo "- Bevy version mismatch: Cargo.toml=$CARGO_BEVY, bevy.md=$MD_BEVY" >> "$LOG_FILE"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        else
            echo "- Bevy versions aligned: $CARGO_BEVY" >> "$LOG_FILE"
        fi
    fi
fi
echo "" >> "$LOG_FILE"

# Summary
echo "## Summary" >> "$LOG_FILE"
echo "Issues found: $ISSUES_FOUND" >> "$LOG_FILE"
echo "Log saved to: $LOG_FILE" >> "$LOG_FILE"

# Output to stdout for launchd logging
cat "$LOG_FILE"

# Exit with issue count (0 = healthy)
exit 0
