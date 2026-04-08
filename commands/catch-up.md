---
allowed-tools: Read, Write, Bash, Glob, Task
description: Generate intelligent summary of recent daily notes to get back up to speed
argument-hint: [days] - Number of days to review (1, 3, 7, or 14). Defaults to 3.
---

## Context
- Working directory: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- Daily notes location: Year/Quarter/Week structure
- Arguments provided: $ARGUMENTS

## Your Task

Generate a comprehensive "catch-up" summary by analyzing recent daily notes to help the user get back up to speed after time away. This command is designed for situations where the user has been away (from a lunch break to a 2-week vacation) and needs to quickly understand what happened, what needs attention, and what opportunities exist.

### Step-by-step Instructions

1. **Get Current Date and Time**
   - Run `date '+%m-%d-%Y'` to get current date
   - Run `date '+%m-%d-%Y | %I:%M:%S %p'` for full timestamp
   - Calculate current daily note location using folder structure calculation

2. **Parse Arguments**
   - If no argument provided, default to 3 days
   - Valid arguments: 1, 3, 7, or 14
   - If invalid argument, show help message with valid options

3. **Identify Daily Notes to Review**
   - Calculate date range based on argument (today minus N days)
   - Use Glob tool to find ALL daily notes matching the date pattern: `**/*MM-DD-YYYY.md`
   - DO NOT rely on folder structure calculations - search the entire vault
   - Check which daily notes exist and which are missing from the date range
   - Note any gaps for user awareness

4. **Extract and Analyze Content**
   For each daily note found, extract:
   - **Tasks**: All task items with their status (completed/incomplete)
   - **Notes Section**: All work performed entries with timestamps
   - **Meeting Information**: Any meeting notes or references
   - **Tags**: Preserve all tags for context
   - **Journal**: Skip Morning Thoughts/Evening Reflections (keep private)

5. **Categorize by Macro Environment**
   Group all findings into:
   - **Work - Vast Bank**: Items tagged #vast_bank
   - **Work - Mbanq**: Items tagged #mbanq  
   - **Work - Secureda/Black Cat Security**: Items tagged #secureda or #black_cat_security
   - **Personal**: Items tagged #personal or in Personal/ directory
   - **Uncategorized**: Items without clear categorization

6. **Generate Intelligent Summary**
   Create sections based on timeframe scale:
   
   **For 1-3 days**: Detailed view
   - Include all task descriptions and statuses
   - Full notes entries with work performed
   - Complete meeting summaries
   - All file creations/modifications
   
   **For 7 days**: Balanced view
   - Group similar tasks by theme
   - Summarize work by project/initiative
   - Highlight key meetings and decisions
   - Focus on completions and blockers
   
   **For 14 days**: Strategic view
   - High-level themes and patterns
   - Major accomplishments only
   - Strategic decisions and pivots
   - Trend analysis across the period

7. **Create Summary Structure**
   ```markdown
   ---
   author: Ishtyler Etienne
   Created: [current date]
   Last Modified: [current timestamp]
   tags:
     - catch_up_summary
     - [relevant period tag like weekly_summary]
   ---
   
   # Catch-Up Summary: [Date Range]
   Generated: [timestamp]
   Period: Last [N] days ([start date] to [end date])
   Daily Notes Found: X of Y expected
   
   ## 🚨 What Needs Immediate Attention
   - [Blocked/stalled items]
   - [Incomplete high-priority tasks]
   - [Pending decisions or approvals]
   - [Time-sensitive items]
   
   ## 📊 Summary by Environment
   
   ### Work - Vast Bank
   **Key Accomplishments:**
   - [Major completions]
   
   **In Progress:**
   - [Current initiatives]
   
   **Meetings & Decisions:**
   - [Important outcomes]
   
   ### Work - Mbanq
   [Similar structure]
   
   ### Personal
   [Similar structure]
   
   ## 🔍 Strategic Insights & Patterns
   - [Pattern observations like "3 automation tasks started but not completed"]
   - [Time allocation insights]
   - [Recurring blockers or dependencies]
   - [Opportunities for efficiency gains]
   
   ## 📅 Missing Daily Notes
   The following dates are missing daily notes:
   - [List missing dates]
   Consider running `/create-daily-notes [date]` to backfill.
   
   ## 📎 Source Notes
   - [[MM-DD-YYYY]] - [Brief highlight of that day]
   - [[MM-DD-YYYY]] - [Brief highlight of that day]
   [Continue for all reviewed dates]
   ```

8. **Save Summary File**
   - Create filename: `Catch-Up Summary - MM-DD-YYYY.md`
   - Save in `/Summaries/` directory (create if doesn't exist)
   - Include all preserved tags from source notes

9. **Update Current Daily Note**
   - Add entry to Notes section with timestamp
   - Include: "Generated catch-up summary for last [N] days. See: [[Catch-Up Summary - MM-DD-YYYY]]"
   - Tag appropriately based on work performed

10. **Display Results**
    - Show brief confirmation of summary creation
    - Provide path to summary file
    - Highlight any critical items needing attention
    - Suggest next actions if applicable

### Important Notes
- Always preserve original tags from daily notes in the summary
- Respect privacy by excluding journal sections
- Scale detail appropriately to timeframe to avoid information overload
- Focus on actionable insights rather than just listing information
- Ensure summary provides real value for getting back up to speed
- Handle missing daily notes gracefully with helpful suggestions

### Expected Output
User sees a confirmation message with the summary file location and any critical items requiring immediate attention. The comprehensive summary file is created and linked in their current daily note for easy access.