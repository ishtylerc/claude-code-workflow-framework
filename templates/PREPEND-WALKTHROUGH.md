# How to Prepend an Entry to a Daily Note

This is the exact pattern Claude should follow when adding a new entry to today's daily note. The critical rule: **new entries go at the TOP of the `## Notes` section, not the bottom.**

## Why Prepend?

- Newest work appears first when scanning the note
- Historical entries stay in chronological order (top = most recent)
- Matches journal/log conventions
- Makes end-of-day review trivial (skim from top until you hit yesterday)

## The 7-Step Protocol

### Step 1: Get the timestamp

```bash
date '+%I:%M %p %m-%d-%Y'
```

Output example: `04:42 PM 04-08-2026`

Use just the time portion (`04:42 PM`) in the entry.

### Step 2: Find today's note

**CRITICAL**: Use `find`, NOT Glob. The `[W]##` brackets break Glob.

```bash
find "/path/to/your/vault" -name "$(date '+%m-%d-%Y').md" -type f 2>/dev/null
```

Example output: `/path/to/your/vault/2026/Q2/[W]15/04-08-2026.md`

### Step 3: Read the existing Notes section

Use the Read tool on the note file. Find the `## Notes` header and read what's below it to understand current content.

### Step 4: Construct the entry

Follow the format from `skills/daily-note-management/entry-format.md`. Minimum structure:

```markdown
- **HH:MM AM/PM** - **Descriptive Title** #tag1 #tag2

  **Work Type**: Brief description

  **Work Completed**:
  - ✅ Item 1
  - ✅ Item 2

  **Files Modified**:
  - 📝 [[Markdown File]] - Description
  - 🔧 'path/to/config.json' - Description

  **Strategic Value**: How this advances goals.

---
```

### Step 5: Use Edit tool to prepend

This is where the magic happens. The Edit tool replaces a unique string. To prepend, use the `## Notes` header + the first existing entry (or empty) as the `old_string`, and put your new entry between them in the `new_string`.

**Case A: Notes section is EMPTY**

```
Current file:
## Notes


---

## Meetings
```

Edit call:
```
old_string: "## Notes\n\n\n---"
new_string: "## Notes\n\n- **04:42 PM** - **Title** #tag\n\n  **Content**: ...\n\n---\n\n---"
```

**Case B: Notes section HAS existing entries**

```
Current file:
## Notes

- **02:15 PM** - **Previous Entry** #tag
  ...
---
```

Edit call:
```
old_string: "## Notes\n\n- **02:15 PM** - **Previous Entry**"
new_string: "## Notes\n\n- **04:42 PM** - **NEW Entry** #tag\n\n  **Content**: ...\n\n---\n\n- **02:15 PM** - **Previous Entry**"
```

The NEW entry is inserted ABOVE the previous one, with `---` as a separator between them.

### Step 6: Verify placement

Read the file again (just the Notes section) and confirm:
- ✅ New entry is at the TOP
- ✅ Previous entries are still below it, in original order
- ✅ Separators (`---`) are between entries
- ✅ No duplicate entries created
- ✅ Indentation is preserved for bullet content

### Step 7: Respond to the user

ONLY after steps 1-6 are complete, respond with your actual answer to what the user asked.

---

## Before/After Example

### BEFORE (starting state)

```markdown
## Notes

- **02:15 PM** - **Docker Port Fix** #infrastructure #docker

  **Configuration Update**: Fixed nginx port mapping

  **Files Modified**:
  - 🔧 'docker-compose.yml' - Fixed port binding

  **Strategic Value**: Resolves local dev access.

---

- **10:30 AM** - **Morning Research** #research #personal

  **Research Completed**: Reviewed 3 papers on WebGPU performance

  **Strategic Value**: Informs upcoming optimization work.

---
```

### AFTER (entry prepended at 04:42 PM)

```markdown
## Notes

- **04:42 PM** - **Framework Documentation Update** #personal #infrastructure #claude_code

  **DOCUMENTATION**: Added templates directory to workflow framework repo.

  **Work Completed**:
  - ✅ Created blank daily/weekly/quarterly/annual note templates
  - ✅ Wrote PREPEND-WALKTHROUGH.md with 7-step protocol
  - ✅ Added populated example showing real entries

  **Files Created**:
  - 📝 [[daily-note-blank]] - Fresh template
  - 📝 [[PREPEND-WALKTHROUGH]] - How to prepend correctly

  **Strategic Value**: Agents can now see exactly what a fresh daily note looks like and the precise prepend pattern.

---

- **02:15 PM** - **Docker Port Fix** #infrastructure #docker

  **Configuration Update**: Fixed nginx port mapping

  **Files Modified**:
  - 🔧 'docker-compose.yml' - Fixed port binding

  **Strategic Value**: Resolves local dev access.

---

- **10:30 AM** - **Morning Research** #research #personal

  **Research Completed**: Reviewed 3 papers on WebGPU performance

  **Strategic Value**: Informs upcoming optimization work.

---
```

Note how:
- The new 04:42 PM entry is at the TOP of the Notes section
- The 02:15 PM and 10:30 AM entries remain in their original order
- Every entry ends with `---` as a separator
- The newest-at-top convention is preserved

---

## Common Mistakes

1. ❌ **Appending to the bottom** — easy trap when using Write instead of Edit
2. ❌ **Using Glob to find the note** — brackets in `[W]##` break Glob; use `find`
3. ❌ **Forgetting the separator `---`** — entries blur together without it
4. ❌ **Not indenting bullet content** — the entry header is `-` but sub-content needs 2-space indent
5. ❌ **Tables with indentation** — tables must start at column 0 or they won't render
6. ❌ **Missing strategic value** — every entry should answer "why does this matter?"
7. ❌ **Skipping the Read step** — you need to see existing entries to construct the Edit correctly
8. ❌ **Responding before documenting** — documentation must happen BEFORE the user-facing response

---

## Edge Cases

### First entry of the day (Notes is empty)

The `## Notes` section will look like this right after the note is auto-created:

```markdown
## Notes


---

## Meetings
```

Prepend by matching the empty section and inserting your entry between `## Notes` and the first `---`.

### Note file doesn't exist yet

If `find` returns nothing, the note hasn't been created yet. Either:
- Run `/daily-note` to create it
- Run the automation script manually
- Tell the user the note is missing (don't create it yourself unless explicitly permitted)

### Multiple entries added in same session

Each call to the daily-note-management skill should PREPEND a new entry — so the most recent work sits at the top. If you added an entry at 02:15 PM and now you're adding one at 04:42 PM, the 04:42 PM entry goes ABOVE the 02:15 PM entry.

### Very large notes (100+ entries)

Read just the first ~20 lines of the Notes section to find the current top entry. You don't need to read the entire note — you just need to find the Edit anchor.
