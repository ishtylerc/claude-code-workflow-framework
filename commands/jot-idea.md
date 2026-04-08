---
allowed-tools: Bash, Glob, Read, Edit
description: Quickly jot down ideas to today's daily note Ideas & Insights section
argument-hint: <idea text> [; additional ideas separated by semicolons]
---

## Context
- Working directory: `/Users/ishtyler/Documents/My Brain 2.0`
- Target section: Ideas & Insights in today's daily note
- Arguments provided: $ARGUMENTS

## Category Library

Use these categories for auto-detection based on keywords in the idea text:

| Category Tag | Trigger Keywords |
|--------------|------------------|
| `#k_town` | k-town, ktown, game, megacity, avatar, lobby, room, physics, rapier, three.js, bevy |
| `#graphics` | lighting, shader, render, visual, texture, material, glow, emission, shadow |
| `#performance` | fps, optimize, lod, memory, gpu, cpu, batch, instanced, reduce |
| `#security` | security, pentest, vulnerability, soc, siem, edr, incident, threat |
| `#secureda` | secureda, invoice, client, contract, business |
| `#black_cat_security` | black cat, excellere, eckerd, foi, corban, envera |
| `#personal` | personal, home, family, health, finance |
| `#nft` | nft, trait, mint, collection, artist, blender |
| `#research` | research, investigate, explore, compare, evaluate |
| `#infrastructure` | devops, ci/cd, docker, aws, azure, terraform, deploy |
| `#documentation` | docs, readme, guide, tutorial, wiki |
| `#multiplayer` | multiplayer, colyseus, socket, netcode, sync, server |
| `#ui` | ui, ux, interface, button, menu, hud, overlay |
| `#audio` | audio, sound, music, sfx, ambient |
| `#animation` | animation, rigging, skeletal, keyframe, motion |

**Default**: If no keywords match, use `#idea #general`

## Your Task

Quickly add idea(s) to today's daily note's Ideas & Insights section.

### Step-by-step Instructions

1. **Get current timestamp**
   ```bash
   date '+%I:%M %p %m-%d-%Y'
   ```
   Extract time (e.g., "01:15 PM") and date (e.g., "01-01-2026")

2. **Find today's daily note**
   Use Glob pattern: `**/*MM-DD-YYYY.md` (e.g., `**/*01-01-2026.md`)

3. **Parse the arguments**
   - Split by semicolon (`;`) to get individual ideas
   - Trim whitespace from each idea
   - For each idea:
     - Auto-generate title from first 5-7 words
     - Auto-detect category tags from keywords (see Category Library above)
     - If no category detected, use `#idea #general`

4. **Format each idea entry** (WITH CHECKBOX for tracking completion)
   ```markdown
   - [ ] 💡 **[TIME]** - **[Auto-Title from first 5-7 words]** [#detected_tags]
     - [Full idea text if longer than title]
   ```

   Example:
   ```markdown
   - [ ] 💡 **01:15 PM** - **Fix the lighting to be more realistic** #k_town #graphics
     - Fix the lighting to be more realistic for the megacity scene
   ```

5. **Read the daily note** and locate the `## Ideas & Insights` section

6. **Prepend the new idea(s)** directly under `## Ideas & Insights` header (newest first)

7. **Confirm completion** with a brief message showing what was added

### Important Notes
- Always PREPEND ideas (newest at top of Ideas & Insights section)
- Multiple ideas from semicolon separation get individual timestamps (same time is fine)
- Keep the format consistent for all entries
- If Ideas & Insights section doesn't exist, report error (don't create it)

### Expected Output

Brief confirmation like:
```
✅ Added 2 ideas to today's daily note:
- [ ] 💡 Fix the lighting to be more realistic #k_town #graphics
- [ ] 💡 Add LOD for distant buildings #k_town #performance
```
