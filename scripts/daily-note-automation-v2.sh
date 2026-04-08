#!/bin/bash
# Daily Note Automation v2.0
# Drift-resistant, gap-aware, with stale task management AND hierarchical notes automation

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

VAULT_DIR="/Users/ishtyler/Documents/My Brain 2.0"
LOG_DIR="$HOME/.local/share/daily-notes-logs"
CLAUDE_BIN="/opt/homebrew/bin/claude"
CLAUDE_TIMEOUT=120  # seconds

# Stale thresholds (days in Other)
STALE_14=14
STALE_30=30
STALE_60=60
STALE_90=90

# Hierarchical automation configuration
ENABLE_WEEKLY_AUTOMATION=true
ENABLE_QUARTERLY_AUTOMATION=true
ENABLE_ANNUAL_AUTOMATION=true

# Update thresholds (days before forcing update)
WEEKLY_UPDATE_THRESHOLD=7
QUARTERLY_UPDATE_THRESHOLD=14
ANNUAL_UPDATE_THRESHOLD=28

# =============================================================================
# LOGGING
# =============================================================================

LOG_FILE=""

init_logging() {
    LOG_FILE="${LOG_DIR}/automation-${ISO_DATE}.log"
    mkdir -p "$LOG_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - === Daily Note Automation v2.0 Started ===" >> "$LOG_FILE"
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# =============================================================================
# DATE CALCULATIONS
# =============================================================================

calculate_dates() {
    if [ -n "${TARGET_DATE:-}" ]; then
        # Manual date (YYYY-MM-DD format)
        TODAY=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%m-%d-%Y')
        YEAR=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%Y')
        # ISO_WEEK_YEAR uses %G for correct year when date is in week 1 of next year
        # (e.g., Dec 31, 2025 is in ISO week 1 of 2026)
        ISO_WEEK_YEAR=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%G')
        MONTH=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%m')
        WEEK=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%V')
        DAY_NAME=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%A')
        YESTERDAY=$(date -j -v-1d -f "%Y-%m-%d" "$TARGET_DATE" '+%m-%d-%Y')
        TOMORROW=$(date -j -v+1d -f "%Y-%m-%d" "$TARGET_DATE" '+%m-%d-%Y')
        ISO_DATE="$TARGET_DATE"
        TARGET_EPOCH=$(date -j -f "%Y-%m-%d" "$TARGET_DATE" '+%s')
    else
        TODAY=$(date '+%m-%d-%Y')
        YEAR=$(date '+%Y')
        # ISO_WEEK_YEAR uses %G for correct year when date is in week 1 of next year
        # (e.g., Dec 31, 2025 is in ISO week 1 of 2026)
        ISO_WEEK_YEAR=$(date '+%G')
        MONTH=$(date '+%m')
        WEEK=$(date '+%V')
        DAY_NAME=$(date '+%A')
        YESTERDAY=$(date -v-1d '+%m-%d-%Y')
        TOMORROW=$(date -v+1d '+%m-%d-%Y')
        ISO_DATE=$(date '+%Y-%m-%d')
        TARGET_EPOCH=$(date '+%s')
    fi

    # Quarter calculation based on calendar month
    QUARTER=$(echo "$MONTH" | awk '{
        m = int($1)
        if (m <= 3) print "Q1"
        else if (m <= 6) print "Q2"
        else if (m <= 9) print "Q3"
        else print "Q4"
    }')

    # ISO Week Quarter: Determine quarter based on ISO week year
    # Week 1 is always Q1, regardless of calendar month
    # This handles year boundary (e.g., Dec 31, 2025 in Week 1 → 2026/Q1)
    if [ "$WEEK" -le 13 ]; then
        ISO_QUARTER="Q1"
    elif [ "$WEEK" -le 26 ]; then
        ISO_QUARTER="Q2"
    elif [ "$WEEK" -le 39 ]; then
        ISO_QUARTER="Q3"
    else
        ISO_QUARTER="Q4"
    fi

    # Paths - Use ISO_WEEK_YEAR and ISO_QUARTER for week-based folder structure
    TODAY_FOLDER="${ISO_WEEK_YEAR}/${ISO_QUARTER}/[W]${WEEK}"
    TODAY_FILE="${TODAY_FOLDER}/${TODAY}.md"
    TIMESTAMP=$(date '+%m-%d-%Y | %I:%M %p')

    # Hierarchical file paths - Weekly uses ISO week year, quarterly/annual use calendar year
    WEEKLY_FILE="${VAULT_DIR}/${ISO_WEEK_YEAR}/${ISO_QUARTER}/[W]${WEEK}/${ISO_WEEK_YEAR}-W${WEEK}.md"
    QUARTERLY_FILE="${VAULT_DIR}/${YEAR}/${YEAR}-${QUARTER}.md"
    ANNUAL_FILE="${VAULT_DIR}/${YEAR}/${YEAR}-Annual.md"
}

# =============================================================================
# HIERARCHICAL TRIGGER CHECKS
# =============================================================================

needs_weekly_update() {
    local week_file="$1"
    local current_date="$2"

    # Check if it's Sunday (end of week) or if weekly note doesn't exist
    local day_of_week=$(date -j -f "%Y-%m-%d" "$current_date" '+%u')  # 1=Monday, 7=Sunday

    if [ ! -f "$week_file" ] || [ "$day_of_week" = "7" ]; then
        return 0  # True - needs update
    fi

    # Check if significant daily activity has occurred (more than threshold days)
    local last_modified=$(stat -f '%m' "$week_file" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local days_diff=$(( (current_time - last_modified) / 86400 ))

    if [ $days_diff -ge $WEEKLY_UPDATE_THRESHOLD ]; then
        return 0  # True - needs update
    fi

    return 1  # False - no update needed
}

needs_quarterly_update() {
    local quarter_file="$1"
    local current_date="$2"

    # Check if it's end of month (day 28+) or if quarterly note doesn't exist
    local day_of_month=$(date -j -f "%Y-%m-%d" "$current_date" '+%d')

    if [ ! -f "$quarter_file" ] || [ "$day_of_month" -ge 28 ]; then
        return 0  # True - needs update
    fi

    # Check if significant weekly activity has occurred
    local last_modified=$(stat -f '%m' "$quarter_file" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local days_diff=$(( (current_time - last_modified) / 86400 ))

    if [ $days_diff -ge $QUARTERLY_UPDATE_THRESHOLD ]; then
        return 0  # True - needs update
    fi

    return 1  # False - no update needed
}

needs_annual_update() {
    local annual_file="$1"
    local current_date="$2"

    # Check if it's quarter-end month or if annual note doesn't exist
    local current_month=$(date -j -f "%Y-%m-%d" "$current_date" '+%m')

    if [ ! -f "$annual_file" ] || [ "$current_month" = "03" ] || [ "$current_month" = "06" ] || [ "$current_month" = "09" ] || [ "$current_month" = "12" ]; then
        return 0  # True - needs update
    fi

    # Check if significant quarterly activity has occurred
    local last_modified=$(stat -f '%m' "$annual_file" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local days_diff=$(( (current_time - last_modified) / 86400 ))

    if [ $days_diff -ge $ANNUAL_UPDATE_THRESHOLD ]; then
        return 0  # True - needs update
    fi

    return 1  # False - no update needed
}

# =============================================================================
# HIERARCHICAL TOC GENERATION
# =============================================================================

generate_weekly_toc() {
    local year="$1"
    local week="$2"

    # Calculate Monday of the week (ISO week starts Monday)
    # Get January 4th of the year (always in week 1)
    local jan4=$(date -j -f "%Y-%m-%d" "${year}-01-04" '+%s')
    local jan4_dow=$(date -j -f "%Y-%m-%d" "${year}-01-04" '+%u')

    # Monday of week 1
    local week1_monday=$(( jan4 - (jan4_dow - 1) * 86400 ))

    # Monday of target week
    local target_monday=$(( week1_monday + (week - 1) * 7 * 86400 ))

    # Generate 7 days
    local toc=""
    for i in {0..6}; do
        local day_epoch=$(( target_monday + i * 86400 ))
        local day_date=$(date -j -f "%s" "$day_epoch" '+%m-%d-%Y')
        local day_name=$(date -j -f "%s" "$day_epoch" '+%A')
        toc+="- [[$day_date]] | $day_name"$'\n'
    done

    echo -n "$toc"
}

generate_quarterly_toc() {
    local year="$1"
    local quarter="$2"

    # Determine week range for quarter
    local start_week end_week
    case "$quarter" in
        Q1) start_week=1; end_week=13 ;;
        Q2) start_week=14; end_week=26 ;;
        Q3) start_week=27; end_week=39 ;;
        Q4) start_week=40; end_week=52 ;;
    esac

    local toc=""
    for (( w=start_week; w<=end_week; w++ )); do
        toc+="- [[$year-W$w]] | Week $w"$'\n'
    done

    echo -n "$toc"
}

generate_annual_toc() {
    local year="$1"

    echo -n "- [[$year-Q1]] | Quarter 1 (Jan-Mar)
- [[$year-Q2]] | Quarter 2 (Apr-Jun)
- [[$year-Q3]] | Quarter 3 (Jul-Sep)
- [[$year-Q4]] | Quarter 4 (Oct-Dec)"
}

# =============================================================================
# HIERARCHICAL TEMPLATE GENERATION
# =============================================================================

generate_weekly_note() {
    local week="$1"
    local year="$2"
    local quarter="$3"
    local created_date="$4"
    local timestamp="$5"

    # Calculate week date range
    local jan4=$(date -j -f "%Y-%m-%d" "${year}-01-04" '+%s')
    local jan4_dow=$(date -j -f "%Y-%m-%d" "${year}-01-04" '+%u')
    local week1_monday=$(( jan4 - (jan4_dow - 1) * 86400 ))
    local target_monday=$(( week1_monday + (week - 1) * 7 * 86400 ))
    local target_sunday=$(( target_monday + 6 * 86400 ))

    local start_date=$(date -j -f "%s" "$target_monday" '+%b %d')
    local end_date=$(date -j -f "%s" "$target_sunday" '+%b %d')

    # Calculate prev/next week WITH YEAR BOUNDARY HANDLING
    local prev_week=$(( week - 1 ))
    local next_week=$(( week + 1 ))
    local prev_year="$year"
    local next_year="$year"

    # Handle year boundary for previous week
    if [ $prev_week -lt 1 ]; then
        prev_year=$(( year - 1 ))
        # Get last week of previous year (52 or 53) using Dec 28 which is always in last week
        prev_week=$(date -j -f "%Y-%m-%d" "${prev_year}-12-28" '+%V')
    fi

    # Handle year boundary for next week
    # Get max week of current year (52 or 53) using Dec 28
    local max_week=$(date -j -f "%Y-%m-%d" "${year}-12-28" '+%V')
    if [ $next_week -gt $max_week ]; then
        next_week=1
        next_year=$(( year + 1 ))
    fi

    # Format week numbers with leading zeros
    local prev_week_fmt=$(printf "%02d" $prev_week)
    local next_week_fmt=$(printf "%02d" $next_week)
    local week_fmt=$(printf "%02d" $week)

    cat << TEMPLATE_END
---
author: Ishtyler Etienne
Created: $created_date
Last Modified: $timestamp
tags:
  - weekly_notes
week: $week
quarter: $quarter
year: $year
---

# Week $week_fmt - $year ($start_date - $end_date)

<< [[$prev_year-W$prev_week_fmt]] | This Week | [[$next_year-W$next_week_fmt]] >> | Quarter: [[$year-$quarter]] | Year: [[$year-Annual]]

## Table of Contents
$(generate_weekly_toc "$year" "$week")

## Weekly Overview

**Primary Focus**: [Claude generates]

**Achievement Rate**: [Claude calculates from daily notes]

**Strategic Theme**: [Claude generates]

## Progress Tracking

### Major Accomplishments

[Claude generates summary from daily notes]

### Week Patterns & Insights

[Claude analyzes patterns]

## Task Status

### Completed This Week
[Claude extracts completed tasks]

### Carried Forward
[Claude lists incomplete tasks]

## Strategic Alignment

[Claude assesses alignment with quarterly goals]

---
TEMPLATE_END
}

generate_quarterly_note() {
    local year="$1"
    local quarter="$2"
    local created_date="$3"
    local timestamp="$4"

    # Calculate prev/next quarter
    local prev_quarter next_quarter
    case "$quarter" in
        Q1) prev_quarter="Q4"; next_quarter="Q2" ;;
        Q2) prev_quarter="Q1"; next_quarter="Q3" ;;
        Q3) prev_quarter="Q2"; next_quarter="Q4" ;;
        Q4) prev_quarter="Q3"; next_quarter="Q1" ;;
    esac

    cat << TEMPLATE_END
---
author: Ishtyler Etienne
Created: $created_date
Last Modified: $timestamp
tags:
  - quarterly_notes
quarter: $quarter
year: $year
---

# $year $quarter Strategic Plan

<< [[$year-$prev_quarter]] | This Quarter | [[$year-$next_quarter]] >> | Year: [[$year-Annual]]

## Table of Contents
$(generate_quarterly_toc "$year" "$quarter")

## Quarterly Vision & Themes

**Core Theme**: [Claude generates]

**Strategic Priorities**: [Claude generates]

**Success Metrics**: [Claude generates]

## Monthly Check-ins

### Month 1
[Claude generates from weekly notes]

### Month 2
[Claude generates from weekly notes]

### Month 3
[Claude generates from weekly notes]

## Progress Tracking

### Major Projects
[Claude synthesizes from weekly accomplishments]

### Breakthrough Moments
[Claude extracts from weekly breakthroughs]

### Challenges & Learnings
[Claude synthesizes from weekly patterns]

## Strategic Alignment

[Claude assesses alignment with annual goals]

---
TEMPLATE_END
}

generate_annual_note() {
    local year="$1"
    local created_date="$2"
    local timestamp="$3"

    local prev_year=$(( year - 1 ))
    local next_year=$(( year + 1 ))

    cat << TEMPLATE_END
---
author: Ishtyler Etienne
Created: $created_date
Last Modified: $timestamp
tags:
  - yearly_notes
  - planning
  - strategic_goals
year: $year
---

# $year Annual Strategic Plan

<< [[$prev_year-Annual]] | This Year | [[$next_year-Annual]] >>

## Table of Contents
$(generate_annual_toc "$year")

## Annual Vision & Themes

**Core Vision**: [Claude generates]

**Primary Themes**: [Claude generates]

**Strategic Goals**: [Claude generates]

## Quarterly Breakdown

### Q1 - Foundation
[Claude generates from quarterly notes]

### Q2 - Development
[Claude generates from quarterly notes]

### Q3 - Acceleration
[Claude generates from quarterly notes]

### Q4 - Integration
[Claude generates from quarterly notes]

## Progress Tracking

### Major Achievements
[Claude synthesizes from quarterly accomplishments]

### Breakthrough Patterns
[Claude extracts from quarterly breakthroughs]

### Annual Themes
[Claude analyzes year-long patterns]

## Strategic Insights

[Claude assesses annual strategic evolution]

---
TEMPLATE_END
}

# =============================================================================
# HIERARCHICAL UPDATE FUNCTIONS
# =============================================================================

update_weekly_note() {
    local week_file="$1"
    local target_date="$2"

    log "Updating weekly note: $week_file"

    # Ensure directory exists
    mkdir -p "$(dirname "$week_file")"

    # Generate template with placeholders filled - use ISO_WEEK_YEAR for correct year
    local template=$(generate_weekly_note "$WEEK" "$ISO_WEEK_YEAR" "$ISO_QUARTER" "$TODAY" "$TIMESTAMP")

    # Write template to file
    echo "$template" > "$week_file"

    # Create Claude prompt to fill content
    local prompt="You need to analyze daily notes from this week and update the weekly note.

WEEKLY FILE: $week_file
WEEK NUMBER: W$WEEK
YEAR: $ISO_WEEK_YEAR
QUARTER: $ISO_QUARTER
DAILY NOTES FOLDER: $VAULT_DIR/$TODAY_FOLDER

Read all daily notes from this week (found in the folder above) and fill in the [Claude generates] and [Claude calculates] sections ONLY.

CRITICAL: Do NOT modify the template structure. Only replace the placeholder text with appropriate content based on your analysis of the daily notes.

Sections to fill:
- Primary Focus (what was the main theme of work this week?)
- Achievement Rate (calculate task completion percentage)
- Strategic Theme (overall pattern/insight)
- Major Accomplishments (list key deliverables)
- Week Patterns & Insights (productivity patterns observed)
- Completed Tasks (extract completed tasks from daily notes)
- Carried Forward Tasks (extract incomplete tasks)
- Strategic Alignment (how does this week advance quarterly/annual goals?)

Use actual file content to create comprehensive analysis. Preserve all markdown formatting and structure."

    # Execute Claude prompt
    if timeout "$CLAUDE_TIMEOUT" "$CLAUDE_BIN" --print --dangerously-skip-permissions "$prompt" >> "$LOG_FILE" 2>&1; then
        log "SUCCESS: Weekly note updated"
    else
        log "WARNING: Weekly note update failed - template created but Claude analysis incomplete"
    fi
}

update_quarterly_note() {
    local quarter_file="$1"
    local target_date="$2"

    log "Updating quarterly note: $quarter_file"

    # Ensure directory exists
    mkdir -p "$(dirname "$quarter_file")"

    # Generate template with placeholders filled
    local template=$(generate_quarterly_note "$YEAR" "$QUARTER" "$TODAY" "$TIMESTAMP")

    # Write template to file
    echo "$template" > "$quarter_file"

    # Create Claude prompt to fill content
    local prompt="You need to analyze weekly notes from this quarter and update the quarterly note.

QUARTERLY FILE: $quarter_file
QUARTER: $QUARTER
YEAR: $YEAR
QUARTERLY FOLDER: $VAULT_DIR/$YEAR/$QUARTER

Read all weekly notes from this quarter and fill in the [Claude generates] sections ONLY.

CRITICAL: Do NOT modify the template structure. Only replace the placeholder text with appropriate content based on your analysis of the weekly notes.

Sections to fill:
- Core Theme (what was the overarching theme of this quarter?)
- Strategic Priorities (main focus areas)
- Success Metrics (quantifiable achievements)
- Monthly Check-ins (synthesis of weeks into monthly patterns)
- Major Projects (key initiatives and deliverables)
- Breakthrough Moments (significant achievements or insights)
- Challenges & Learnings (obstacles and growth)
- Strategic Alignment (how does this quarter advance annual goals?)

Use actual weekly note content to create comprehensive quarterly synthesis. Preserve all markdown formatting and structure."

    # Execute Claude prompt
    if timeout "$CLAUDE_TIMEOUT" "$CLAUDE_BIN" --print --dangerously-skip-permissions "$prompt" >> "$LOG_FILE" 2>&1; then
        log "SUCCESS: Quarterly note updated"
    else
        log "WARNING: Quarterly note update failed - template created but Claude analysis incomplete"
    fi
}

update_annual_note() {
    local annual_file="$1"
    local target_date="$2"

    log "Updating annual note: $annual_file"

    # Ensure directory exists
    mkdir -p "$(dirname "$annual_file")"

    # Generate template with placeholders filled
    local template=$(generate_annual_note "$YEAR" "$TODAY" "$TIMESTAMP")

    # Write template to file
    echo "$template" > "$annual_file"

    # Create Claude prompt to fill content
    local prompt="You need to analyze quarterly notes from this year and update the annual note.

ANNUAL FILE: $annual_file
YEAR: $YEAR
YEAR FOLDER: $VAULT_DIR/$YEAR

Read all quarterly notes (Q1-Q4) from this year and fill in the [Claude generates] sections ONLY.

CRITICAL: Do NOT modify the template structure. Only replace the placeholder text with appropriate content based on your analysis of the quarterly notes.

Sections to fill:
- Core Vision (what was the overarching vision for the year?)
- Primary Themes (main strategic themes)
- Strategic Goals (major objectives)
- Quarterly Breakdown (synthesis of each quarter's achievements)
- Major Achievements (key accomplishments across the year)
- Breakthrough Patterns (significant patterns and insights)
- Annual Themes (year-long trends and evolution)
- Strategic Insights (assessment of annual strategic evolution)

Use actual quarterly note content to create comprehensive annual synthesis. Preserve all markdown formatting and structure."

    # Execute Claude prompt
    if timeout "$CLAUDE_TIMEOUT" "$CLAUDE_BIN" --print --dangerously-skip-permissions "$prompt" >> "$LOG_FILE" 2>&1; then
        log "SUCCESS: Annual note updated"
    else
        log "WARNING: Annual note update failed - template created but Claude analysis incomplete"
    fi
}

# =============================================================================
# FIND PREVIOUS NOTE & CALCULATE GAP
# =============================================================================

find_previous_note() {
    # Find most recent daily note (excluding today)
    PREVIOUS_NOTE=$(find "$VAULT_DIR" \
        \( -path "*/20*/Q*/\[W\]*/*.md" \) \
        -name "[0-9][0-9]-[0-9][0-9]-20*.md" \
        ! -name "${TODAY}.md" \
        -exec ls -t {} + 2>/dev/null | head -1)

    if [ -z "$PREVIOUS_NOTE" ]; then
        GAP_DAYS=0
        log "No previous note found"
        return
    fi

    # Extract date from filename (MM-DD-YYYY.md)
    PREV_FILENAME=$(basename "$PREVIOUS_NOTE" .md)
    PREV_MONTH=${PREV_FILENAME:0:2}
    PREV_DAY=${PREV_FILENAME:3:2}
    PREV_YEAR=${PREV_FILENAME:6:4}
    PREV_ISO="${PREV_YEAR}-${PREV_MONTH}-${PREV_DAY}"

    # Calculate gap in days
    PREV_EPOCH=$(date -j -f "%Y-%m-%d" "$PREV_ISO" '+%s' 2>/dev/null || echo 0)
    if [ "$PREV_EPOCH" -gt 0 ]; then
        GAP_DAYS=$(( (TARGET_EPOCH - PREV_EPOCH) / 86400 ))
    else
        GAP_DAYS=1
    fi

    log "Previous note: $PREVIOUS_NOTE (gap: $GAP_DAYS days)"
}

# =============================================================================
# PURE BASH TASK EXTRACTION (NO CLAUDE)
# =============================================================================

extract_tasks_bash() {
    local source_file="$1"

    TOP_TASKS=""
    SECONDARY_TASKS=""
    TERTIARY_TASKS=""
    OTHER_TASKS=""

    if [ ! -f "$source_file" ]; then
        return
    fi

    local current_section=""

    while IFS= read -r line; do
        # Detect section headers
        case "$line" in
            *"Top Priority"*) current_section="TOP" ;;
            *"Secondary Priority"*) current_section="SECONDARY" ;;
            *"Tertiary Priority"*) current_section="TERTIARY" ;;
            *"Other Tasks"*) current_section="OTHER" ;;
            "## Journal"*|"## Notes"*|"---") current_section="" ;;
        esac

        # Extract incomplete tasks only
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]\[[[:space:]]\] ]]; then
            # Skip empty placeholder tasks
            local task_text=$(echo "$line" | sed 's/^[[:space:]]*- \[ \] //')
            if [ -n "$task_text" ] && [ "$task_text" != " " ]; then
                case "$current_section" in
                    "TOP") TOP_TASKS+="$line"$'\n' ;;
                    "SECONDARY") SECONDARY_TASKS+="$line"$'\n' ;;
                    "TERTIARY") TERTIARY_TASKS+="$line"$'\n' ;;
                    "OTHER") OTHER_TASKS+="$line"$'\n' ;;
                esac
            fi
        fi
    done < "$source_file"
}

# =============================================================================
# IDEA EXTRACTION (for carryover)
# =============================================================================

extract_ideas_bash() {
    local source_file="$1"

    IDEAS=""

    if [ ! -f "$source_file" ]; then
        return
    fi

    local in_ideas_section=false
    local current_idea=""
    local collecting_idea=false

    while IFS= read -r line; do
        # Detect Ideas & Insights section
        if [[ "$line" =~ ^##[[:space:]]*Ideas ]]; then
            in_ideas_section=true
            continue
        fi

        # Detect section end (next ## header or ---)
        if [[ "$in_ideas_section" == true ]] && [[ "$line" =~ ^##[[:space:]] || "$line" =~ ^---$ ]]; then
            # Save any pending idea
            if [ -n "$current_idea" ]; then
                IDEAS+="$current_idea"
            fi
            in_ideas_section=false
            break
        fi

        # Extract unchecked ideas only (- [ ] 💡 pattern)
        if [[ "$in_ideas_section" == true ]]; then
            # Start of a new idea (unchecked with 💡 emoji)
            if [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\][[:space:]]💡 ]]; then
                # Save previous idea if any
                if [ -n "$current_idea" ]; then
                    IDEAS+="$current_idea"
                fi
                current_idea="$line"$'\n'
                collecting_idea=true
            # Continuation lines (indented sub-items)
            elif [[ "$collecting_idea" == true ]] && [[ "$line" =~ ^[[:space:]]+-[[:space:]] || "$line" =~ ^[[:space:]]+\*[[:space:]] ]]; then
                current_idea+="$line"$'\n'
            # Empty line or non-continuation ends the idea
            elif [[ "$collecting_idea" == true ]] && [[ -z "$line" || ! "$line" =~ ^[[:space:]] ]]; then
                # Check if this is another unchecked idea
                if [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\][[:space:]]💡 ]]; then
                    # Save current and start new
                    IDEAS+="$current_idea"
                    current_idea="$line"$'\n'
                elif [[ -z "$line" ]]; then
                    # Empty line - add to current idea
                    current_idea+=$'\n'
                else
                    # Non-idea line - stop collecting
                    collecting_idea=false
                fi
            fi
        fi
    done < "$source_file"

    # Save final idea if any
    if [ -n "$current_idea" ]; then
        IDEAS+="$current_idea"
    fi
}

# =============================================================================
# APPLY ROLLOVER N TIMES
# =============================================================================

apply_rollover() {
    local days="$1"

    # Apply rollover N times
    for ((i=1; i<=days; i++)); do
        # Other stays Other
        # Tertiary → Other
        OTHER_TASKS="${OTHER_TASKS}${TERTIARY_TASKS}"
        TERTIARY_TASKS=""

        # Secondary → Tertiary
        TERTIARY_TASKS="${SECONDARY_TASKS}"
        SECONDARY_TASKS=""

        # Top → Secondary
        SECONDARY_TASKS="${TOP_TASKS}"
        TOP_TASKS=""
    done
}

# =============================================================================
# STALE TASK TAGGING
# =============================================================================

get_task_age_days() {
    local task="$1"

    # Extract timestamp from task: #HH:MM_AM/PM_MM-DD-YYYY
    if [[ "$task" =~ \#([0-9]{2}:[0-9]{2}_[AP]M_([0-9]{2})-([0-9]{2})-([0-9]{4})) ]]; then
        local task_month="${BASH_REMATCH[2]}"
        local task_day="${BASH_REMATCH[3]}"
        local task_year="${BASH_REMATCH[4]}"
        local task_iso="${task_year}-${task_month}-${task_day}"

        local task_epoch=$(date -j -f "%Y-%m-%d" "$task_iso" '+%s' 2>/dev/null || echo 0)
        if [ "$task_epoch" -gt 0 ]; then
            echo $(( (TARGET_EPOCH - task_epoch) / 86400 ))
            return
        fi
    fi

    echo 0
}

apply_stale_tags() {
    local new_other=""

    while IFS= read -r task; do
        [ -z "$task" ] && continue

        local age=$(get_task_age_days "$task")
        local tagged_task="$task"

        # Remove existing stale tags first
        tagged_task=$(echo "$tagged_task" | sed 's/ #stale_[0-9]*d//g; s/ #stale//g')

        # Apply appropriate stale tag
        if [ "$age" -ge "$STALE_90" ]; then
            tagged_task=$(echo "$tagged_task" | sed 's/$/ #stale_90d/')
        elif [ "$age" -ge "$STALE_60" ]; then
            tagged_task=$(echo "$tagged_task" | sed 's/$/ #stale_60d/')
        elif [ "$age" -ge "$STALE_30" ]; then
            tagged_task=$(echo "$tagged_task" | sed 's/$/ #stale_30d/')
        elif [ "$age" -ge "$STALE_14" ]; then
            tagged_task=$(echo "$tagged_task" | sed 's/$/ #stale/')
        fi

        new_other+="$tagged_task"$'\n'
    done <<< "$OTHER_TASKS"

    OTHER_TASKS="$new_other"
}

# =============================================================================
# DEDUPLICATION
# =============================================================================

normalize_task() {
    # Remove timestamp tag for comparison
    echo "$1" | sed 's/#[0-9]\{2\}:[0-9]\{2\}_[AP]M_[0-9]\{2\}-[0-9]\{2\}-[0-9]\{4\}//g' | \
                sed 's/#stale_[0-9]*d//g; s/#stale//g' | \
                sed 's/[[:space:]]*$//' | \
                tr -s ' '
}

deduplicate_tasks() {
    local seen_hashes_file=$(mktemp)
    local deduped_top=""
    local deduped_secondary=""
    local deduped_tertiary=""
    local deduped_other=""

    # Process in priority order (highest first keeps the task)
    for priority in TOP SECONDARY TERTIARY OTHER; do
        local tasks_var="${priority}_TASKS"
        local tasks="${!tasks_var}"
        local deduped=""

        while IFS= read -r task; do
            [ -z "$task" ] && continue

            local normalized=$(normalize_task "$task")
            local hash=$(echo "$normalized" | md5 -q)

            # Check if hash already seen
            if ! grep -q "^${hash}$" "$seen_hashes_file" 2>/dev/null; then
                echo "$hash" >> "$seen_hashes_file"
                deduped+="$task"$'\n'
            else
                log "Deduplicated: $task"
            fi
        done <<< "$tasks"

        case "$priority" in
            TOP) deduped_top="$deduped" ;;
            SECONDARY) deduped_secondary="$deduped" ;;
            TERTIARY) deduped_tertiary="$deduped" ;;
            OTHER) deduped_other="$deduped" ;;
        esac
    done

    TOP_TASKS="$deduped_top"
    SECONDARY_TASKS="$deduped_secondary"
    TERTIARY_TASKS="$deduped_tertiary"
    OTHER_TASKS="$deduped_other"

    # Cleanup
    rm -f "$seen_hashes_file"
}

# =============================================================================
# HARDCODED TEMPLATE
# =============================================================================

generate_daily_note() {
    cat << 'TEMPLATE_START'
---
author: Ishtyler Etienne
Last Modified: TIMESTAMP_PLACEHOLDER
tags:
  - daily_notes
---

<< [[YESTERDAY_PLACEHOLDER]] | Today | [[TOMORROW_PLACEHOLDER]] >> | Week: [[ISO_WEEK_YEAR_PLACEHOLDER-WWEEK_PLACEHOLDER]]

# TODAY_PLACEHOLDER | DAY_PLACEHOLDER

## Agenda & Tasks

### Top Priority
TEMPLATE_START

    # Insert top tasks or empty
    if [ -n "$TOP_TASKS" ]; then
        echo -n "$TOP_TASKS"
    fi

    cat << 'TEMPLATE_MID1'

### Secondary Priority
TEMPLATE_MID1

    if [ -n "$SECONDARY_TASKS" ]; then
        echo -n "$SECONDARY_TASKS"
    fi

    cat << 'TEMPLATE_MID2'

### Tertiary Priority
TEMPLATE_MID2

    if [ -n "$TERTIARY_TASKS" ]; then
        echo -n "$TERTIARY_TASKS"
    fi

    cat << 'TEMPLATE_MID3'

### Other Tasks
TEMPLATE_MID3

    if [ -n "$OTHER_TASKS" ]; then
        echo -n "$OTHER_TASKS"
    fi

    cat << 'TEMPLATE_MID4'

---

## Journal

### Morning Thoughts


### Evening Reflection


---

## Notes


---

## Meetings


---

## Ideas & Insights

TEMPLATE_MID4

    # Insert carried-over ideas
    if [ -n "$IDEAS" ]; then
        echo -n "$IDEAS"
    fi

    cat << 'TEMPLATE_END'

---

## Questions & Decisions


---

## Links & Resources


---

## Tomorrow's Prep

- [ ]

---
TEMPLATE_END
}

write_daily_note() {
    local output
    output=$(generate_daily_note)

    # Replace placeholders
    output="${output//TIMESTAMP_PLACEHOLDER/$TIMESTAMP}"
    output="${output//YESTERDAY_PLACEHOLDER/$YESTERDAY}"
    output="${output//TOMORROW_PLACEHOLDER/$TOMORROW}"
    output="${output//YEAR_PLACEHOLDER/$YEAR}"
    output="${output//ISO_WEEK_YEAR_PLACEHOLDER/$ISO_WEEK_YEAR}"
    output="${output//WEEK_PLACEHOLDER/$WEEK}"
    output="${output//TODAY_PLACEHOLDER/$TODAY}"
    output="${output//DAY_PLACEHOLDER/$DAY_NAME}"

    echo "$output" > "$VAULT_DIR/$TODAY_FILE"
}

# =============================================================================
# CLAUDE-ENHANCED EXTRACTION (WITH VALIDATION)
# =============================================================================

extract_tasks_claude() {
    local source_file="$1"

    if [ ! -f "$source_file" ]; then
        return 1
    fi

    local prompt="Extract ONLY incomplete tasks from the file below. Output EXACTLY in this format:

TOP:
(one task per line starting with '- [ ] ', or empty if none)

SECONDARY:
(one task per line starting with '- [ ] ', or empty if none)

TERTIARY:
(one task per line starting with '- [ ] ', or empty if none)

OTHER:
(one task per line starting with '- [ ] ', or empty if none)

RULES:
- ONLY lines starting with '- [ ]' (incomplete)
- NEVER include '- [x]' (completed)
- PRESERVE all #hashtags and timestamps exactly
- NO explanations, NO summaries, ONLY the format above

FILE:
$(cat "$source_file")"

    local output
    output=$(timeout "$CLAUDE_TIMEOUT" "$CLAUDE_BIN" --print --dangerously-skip-permissions "$prompt" 2>/dev/null) || return 1

    # Validate output structure
    if ! echo "$output" | grep -q "^TOP:" || \
       ! echo "$output" | grep -q "^SECONDARY:" || \
       ! echo "$output" | grep -q "^TERTIARY:" || \
       ! echo "$output" | grep -q "^OTHER:"; then
        log "Claude output validation failed - missing sections"
        return 1
    fi

    # Parse validated output
    parse_claude_output "$output"
    return 0
}

parse_claude_output() {
    local output="$1"
    local current_section=""

    TOP_TASKS=""
    SECONDARY_TASKS=""
    TERTIARY_TASKS=""
    OTHER_TASKS=""

    while IFS= read -r line; do
        case "$line" in
            "TOP:"*) current_section="TOP" ;;
            "SECONDARY:"*) current_section="SECONDARY" ;;
            "TERTIARY:"*) current_section="TERTIARY" ;;
            "OTHER:"*) current_section="OTHER" ;;
            "- [ ] "*)
                case "$current_section" in
                    "TOP") TOP_TASKS+="$line"$'\n' ;;
                    "SECONDARY") SECONDARY_TASKS+="$line"$'\n' ;;
                    "TERTIARY") TERTIARY_TASKS+="$line"$'\n' ;;
                    "OTHER") OTHER_TASKS+="$line"$'\n' ;;
                esac
                ;;
        esac
    done <<< "$output"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    cd "$VAULT_DIR" || exit 1

    calculate_dates
    init_logging

    log "Target: $TODAY_FILE"
    log "Date: $TODAY ($DAY_NAME), Week: W$WEEK, Quarter: $QUARTER"

    # Create folder structure
    mkdir -p "$VAULT_DIR/$TODAY_FOLDER"
    log "Created folder: $TODAY_FOLDER"

    # Find previous note and calculate gap
    find_previous_note

    if [ -n "$PREVIOUS_NOTE" ]; then
        # Try Claude first, fall back to bash
        log "Attempting Claude extraction..."
        if ! extract_tasks_claude "$PREVIOUS_NOTE"; then
            log "Claude failed, using bash fallback"
            extract_tasks_bash "$PREVIOUS_NOTE"
        fi

        # Extract ideas from previous note
        log "Extracting ideas from previous note..."
        extract_ideas_bash "$PREVIOUS_NOTE"
        if [ -n "$IDEAS" ]; then
            log "Found $(echo -n "$IDEAS" | grep -c '^- \[ \]' || echo 0) unchecked ideas to carry over"
        fi

        # Apply rollover based on gap
        if [ "$GAP_DAYS" -gt 0 ]; then
            log "Applying $GAP_DAYS day(s) of rollover"
            apply_rollover "$GAP_DAYS"
        fi

        # Deduplicate
        log "Deduplicating tasks..."
        deduplicate_tasks

        # Apply stale tags to Other tasks
        log "Applying stale tags..."
        apply_stale_tags
    else
        log "No previous note - creating fresh template"
    fi

    # Write the note
    log "Writing daily note..."
    write_daily_note

    # Verify
    if [ -f "$VAULT_DIR/$TODAY_FILE" ]; then
        local size=$(wc -c < "$VAULT_DIR/$TODAY_FILE")
        log "SUCCESS: Created $TODAY_FILE ($size bytes)"
    else
        log "ERROR: Failed to create $TODAY_FILE"
        exit 1
    fi

    # =============================================================================
    # HIERARCHICAL UPDATES
    # =============================================================================

    if [ "$ENABLE_WEEKLY_AUTOMATION" = true ] ||
       [ "$ENABLE_QUARTERLY_AUTOMATION" = true ] ||
       [ "$ENABLE_ANNUAL_AUTOMATION" = true ]; then

        log "=== Checking Hierarchical Updates ==="

        # Weekly
        if [ "$ENABLE_WEEKLY_AUTOMATION" = true ]; then
            if needs_weekly_update "$WEEKLY_FILE" "$ISO_DATE"; then
                log "Weekly update required"
                update_weekly_note "$WEEKLY_FILE" "$ISO_DATE"
            else
                log "Weekly update not required"
            fi
        fi

        # Quarterly
        if [ "$ENABLE_QUARTERLY_AUTOMATION" = true ]; then
            if needs_quarterly_update "$QUARTERLY_FILE" "$ISO_DATE"; then
                log "Quarterly update required"
                update_quarterly_note "$QUARTERLY_FILE" "$ISO_DATE"
            else
                log "Quarterly update not required"
            fi
        fi

        # Annual
        if [ "$ENABLE_ANNUAL_AUTOMATION" = true ]; then
            if needs_annual_update "$ANNUAL_FILE" "$ISO_DATE"; then
                log "Annual update required"
                update_annual_note "$ANNUAL_FILE" "$ISO_DATE"
            else
                log "Annual update not required"
            fi
        fi
    fi

    log "=== Daily Note Automation v2.0 Completed ==="
}

main "$@"
