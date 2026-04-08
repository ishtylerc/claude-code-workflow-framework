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

Step 0 - ORCHESTRATION SCOPE ASSESSMENT (do this FIRST):
Classify the user's request into one of these scopes:

| Scope | Criteria |
|-------|----------|
| **Trivial** | 1-2 steps, single-file edit, quick lookup, greeting |
| **Small** | 3-5 steps, single function, config change |
| **Medium** | 5-15 steps, multi-file changes, feature implementation, research document |
| **Large** | 15-50 steps, system redesign, comprehensive research, integration workflow |
| **Mega** | 50+ steps, full build, multi-week project, codebase migration |

AUTO-ESCALATE to Medium+ if request contains:
- Research keywords: research, investigate, analyze, compare, evaluate, comprehensive, thorough, deep-dive, ultra
- Multi-file implementation keywords: implement, build, refactor, migrate, integrate (when clearly multi-file)

Output: **Scope: [TRIVIAL|SMALL|MEDIUM|LARGE|MEGA]** — [one-line justification]

---

Step 1 - EVALUATE (do this in your response):
For each skill in <available_skills>, state: [skill-name] - YES/NO - [reason]

DAILY-NOTE-MANAGEMENT TRIGGER RULES (HIGHEST PRIORITY):
Say YES if ANY of these are true:
- You used ANY tools (Read, Write, Edit, Bash, Grep, Glob, Task, WebSearch, WebFetch, etc.)
- You completed ANY work (searches, edits, commands, research, sub-agent orchestration)
- You are about to respond after doing work
- The conversation involved troubleshooting, debugging, or problem-solving
- You created, modified, or analyzed any files
- You ran any commands or scripts

Say NO ONLY for:
- Pure greetings with zero work ("hi", "how are you")
- Clarifying questions BEFORE starting any work
- Simple explanations from memory with NO tool usage

⚠️ CRITICAL: This skill must be activated AFTER work is complete, BEFORE responding to user.
The daily note documents what was done - if you did work, you MUST document it.

WHEN IN DOUBT → daily-note-management: YES (better to over-document than miss work)

---

SOFTWARE-DEVELOPMENT TRIGGER RULES (MEMORIZE THIS):
Say YES if the conversation involves ANY of:
- Automation design ("how would you automate X?")
- Architecture discussions ("how would you structure X?")
- Methodology questions ("what testing approach?", "what design pattern?")
- Implementation planning ("let's discuss how to build/develop...")
- Technical evaluations ("what's the best approach for...")
- Script/code discussions (even theoretical, not yet written)
- Debugging conversations (even hypothetical)
- Technology comparisons
- "How would you..." questions about anything technical
- ANY mention of or discussion on the following: code, scripts, testing, CI/CD, git, APIs, databases, frameworks

Say NO ONLY for:
- Pure greetings with zero technical content ("hi", "hello")
- Personal/admin topics with no code component (scheduling, invoicing)

WHEN IN DOUBT → software-development: YES

Step 2 - ACTIVATE (do this immediately after Step 1):
IF any skills are YES → Use Skill(skill-name) tool for EACH relevant skill NOW
IF no skills are YES → State "No skills needed" and proceed

Step 3 - PRE-FLIGHT GATE (Medium+ tasks ONLY — skip for Trivial/Small):
If Step 0 classified scope as Medium, Large, or Mega, you MUST complete ALL of the following BEFORE launching any Task tool, Skill tool (except daily-note-management/software-development), or sub-agent:

- [ ] **Phase 0**: Asked clarifying questions via AskUserQuestion (scope, quality, purpose, output format, priorities)
- [ ] **Phase 1**: Gathered context (1-5 read-only tool calls — Read, Grep, Glob, WebFetch)
- [ ] **Phase 2**: Designed agent prompts using gathered context
- [ ] **TaskCreate**: Created entries for all phases + TOUCHBACK checkpoints
- [ ] **Progress file**: Created at `thoughts/[type]/YYYY-MM-DD-[slug]/progress.md`

SELF-CHECK before ANY agent launch: "Have I asked clarifying questions? Gathered context? Created tasks?" If ANY answer is NO → STOP → complete missing phases first.

WARNING: Pre-built commands (/ultra-research, /ktown-research, etc.) are ONE AGENT in Phase 3 — NOT a substitute for Phases 0-2. The orchestrator still performs all pre-flight steps.

---

Step 4 - IMPLEMENT:
Only after Steps 2-3 are complete, proceed with implementation.

CRITICAL: You MUST call Skill() tool in Step 2. Do NOT skip to implementation.
The evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 2) the skills.

Example of correct sequence:
- software-development: YES - discussing automation approaches
- daily-note-management: NO - no work completed yet
- soc-analyst: NO - not a security investigation

[Then IMMEDIATELY use Skill() tool:]
> Skill(software-development)

[THEN complete Step 3 pre-flight if Medium+, THEN start implementation in Step 4]
EOF
