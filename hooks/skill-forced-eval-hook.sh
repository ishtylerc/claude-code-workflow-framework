#!/bin/bash
# UserPromptSubmit hook that forces explicit skill evaluation
#
# This hook requires Claude to explicitly evaluate each available skill
# before proceeding with implementation.
#
# Based on: https://github.com/spences10/svelte-claude-skills
# Results: ~84% skill activation rate (vs ~20% without)
#
# Installation:
# 1. Save to .claude/hooks/skill-forced-eval-hook.sh
# 2. chmod +x .claude/hooks/skill-forced-eval-hook.sh
# 3. Add to settings.local.json under hooks.UserPromptSubmit

cat <<'EOF'
INSTRUCTION: MANDATORY SKILL ACTIVATION SEQUENCE

Step 1 - EVALUATE (do this in your response):
For each skill in <available_skills>, state: [skill-name] - YES/NO - [reason]

Step 2 - ACTIVATE (do this immediately after Step 1):
IF any skills are YES → Use Skill(skill-name) tool for EACH relevant skill NOW
IF no skills are YES → State "No skills needed" and proceed

Step 3 - IMPLEMENT:
Only after Step 2 is complete, proceed with implementation.

CRITICAL: You MUST call Skill() tool in Step 2. Do NOT skip to implementation.
The evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 2) the skills.

Example of correct sequence:
- task-list-management: YES - user requested work, need to decompose and track
- daily-note-management: YES - work was completed, need to document
- soc-analyst: NO - not a security investigation

[Then IMMEDIATELY use Skill() tool:]
> Skill(task-list-management)
> Skill(daily-note-management)

[THEN and ONLY THEN start implementation]
EOF
