---
allowed-tools: Read, Write, Bash, Task
description: Create daily notes for today and/or previous days with proper task rollover
argument-hint: (optional) number of days to backfill or specific date YYYY-MM-DD
---

## Context
- Working directory: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- Current date: !`date '+%Y-%m-%d'`
- Arguments provided: $ARGUMENTS

## Your Task

Create daily notes for today and any missing previous days based on the arguments:
- If no arguments: Create today's daily note only
- If a number (e.g., "3"): Create daily notes for today and the previous N days
- If a date (e.g., "2025-07-20"): Create daily note for that specific date

Follow these steps for EACH daily note:

1. **Calculate the folder structure**:
   - Year/Quarter/Week format: `YYYY/QX/[W]##/`
   - Quarters: Q1 (Jan-Mar), Q2 (Apr-Jun), Q3 (Jul-Sep), Q4 (Oct-Dec)
   - Use ISO week numbers

2. **Find the previous daily note** (for task rollover):
   - Search for the most recent daily note before the target date
   - Look for incomplete tasks marked with `- [ ]`

3. **Apply task rollover logic** (following exact script methodology):
   - Top Priorities: Always start empty with 3 blank tasks (- [ ])
   - Secondary Priorities: Yesterday's incomplete Secondary tasks
   - Tertiary Priorities: Yesterday's incomplete Tertiary tasks
   - Other Tasks: Yesterday's incomplete Other tasks

4. **Create the daily note** using this exact template:
```markdown
---
author: Ishtyler Etienne
Last Modified: MM-DD-YYYY | HH:MM:SS AM/PM
tags:
  - daily_notes
---

# Day (W##) - MM-DD-YYYY

<< [[Previous-Date]] | Today | [[Next-Date]] >>

## Agenda & Tasks
- **Top Priorities:**
  - [ ] 
  - [ ] 
  - [ ] 

- **Secondary Priorities:**
  - [ ] [rolled over tasks from previous Secondary Priorities]
  - [ ] 

- **Tertiary Priorities:**
  - [ ] [rolled over tasks from previous Tertiary Priorities]
  - [ ] 

- **Other Tasks:**
  - [ ] [rolled over tasks from previous Other Tasks]
  - [ ] 

## Journal
### Morning Thoughts
- 

### Evening Reflections
- 

## Notes
- 
```

5. **Important details**:
   - Use MM-DD-YYYY format for dates
   - Day name should be full (Monday, Tuesday, etc.)
   - Include proper week number (W30, W31, etc.)
   - Navigation links use [[MM-DD-YYYY]] format
   - Preserve task descriptions and tags exactly when rolling over
   - Only create notes that don't already exist

Report what daily notes were created successfully.