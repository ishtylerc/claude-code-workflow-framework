---
allowed-tools: [Bash, Read, Glob]
description: Load the current day's daily note into context with visual feedback
---

## Context
- Working directory: `/mnt/c/Users/Ishtyler.Etinne/nonsync/My Brain`
- This command loads today's daily note for subsequent work
- Arguments provided: $ARGUMENTS

## Your Task

Load the current day's daily note into context, providing visual feedback about the operation.

### Step-by-step Instructions

1. **Get Current Date and Time**
   - Run `date '+%m-%d-%Y'` to get current date in MM-DD-YYYY format
   - Run `date '+%m-%d-%Y | %I:%M:%S %p'` to get full timestamp for potential logging

2. **Calculate Daily Note Path**
   - Use the folder calculation command:
   ```bash
   YEAR=$(date '+%Y')
   QUARTER=$(date '+%m' | awk '{if($1<=3) print "Q1"; else if($1<=6) print "Q2"; else if($1<=9) print "Q3"; else print "Q4"}')
   WEEK=$(date '+%V')
   echo "${YEAR}/${QUARTER}/[W]${WEEK}/"
   ```

3. **Find Today's Daily Note**
   - First try the calculated path: `[calculated-folder]/MM-DD-YYYY.md`
   - If not found, use Glob to search entire vault: `**/*MM-DD-YYYY.md`
   - This handles cases where notes may be in different week folders due to date calculation variations

4. **Read and Validate Note**
   - Use Read tool to load the note content
   - Check basic daily note structure (has "# Day" header, has task sections)
   - Count tasks and note entries for statistics

5. **Provide Visual Feedback**
   - **Success:** `✅ Loaded daily note for [date] ([X] tasks, [Y] note entries)`
   - **Not Found:** `❌ Daily note for [date] not found. Use /daily-note or /create-daily-notes to create it.`
   - **Empty/Minimal:** `⚠️ Daily note for [date] loaded but appears empty or incomplete. Consider adding content.`
   - **Invalid Format:** `⚠️ Daily note loaded but doesn't follow standard template format.`

### Important Notes

- **Error Handling:** Always check if the note file exists before attempting to read
- **Path Calculation:** Use the exact same folder calculation logic as other daily note commands
- **Silent Loading:** The note content should be available for subsequent commands without explicitly displaying it
- **Fallback Search:** If calculated path fails, search entire vault to handle edge cases
- **Statistics:** Count incomplete tasks (`- [ ]`) and recent note entries for useful feedback

### Expected Output

The user should see a clean status message indicating success or failure, with the note content silently loaded into context for further work. Examples:

```
✅ Loaded daily note for 07-25-2025 (8 pending tasks, 3 note entries)
```

```
❌ Daily note for 07-25-2025 not found. Use /daily-note or /create-daily-notes to create it.
```

```
⚠️ Daily note for 07-25-2025 loaded but appears empty. Consider adding tasks or notes.
```