---
allowed-tools: Read, Write, Bash
description: Create today's daily note with task rollover from the most recent previous note
---

## Context
- Working directory: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- Today's date: !`date '+%m-%d-%Y'`
- Current time: !`date '+%I:%M:%S %p'`

## Your Task

Create today's daily note if it doesn't already exist:

1. **Calculate today's folder**: 
   - Run: `YEAR=$(date '+%Y'); QUARTER=$(date '+%m' | awk '{if($1<=3) print "Q1"; else if($1<=6) print "Q2"; else if($1<=9) print "Q3"; else print "Q4"}'); WEEK=$(date '+%V'); echo "${YEAR}/${QUARTER}/[W]${WEEK}/"`

2. **Find the most recent daily note**:
   - Search for the latest .md file in the pattern `*/20*/Q*/[W]*/*.md`
   - Read it to find incomplete tasks (- [ ])

3. **Create today's note** with:
   - Proper YAML frontmatter
   - Navigation links to yesterday and tomorrow
   - Rolled over tasks following the EXACT script logic:
     - Top Priorities: Leave empty with 3 blank tasks (- [ ])
     - Secondary Priorities: Yesterday's incomplete Secondary tasks
     - Tertiary Priorities: Yesterday's incomplete Tertiary tasks
     - Other Tasks: Yesterday's incomplete Other tasks

4. **Use the daily note template** from CLAUDE.md with all sections

Report if the daily note was created successfully or if it already existed.