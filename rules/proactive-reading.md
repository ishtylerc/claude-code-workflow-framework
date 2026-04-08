# Proactive Reading Protocol

**MANDATORY**: Before working with specific areas, automatically read relevant detailed documentation.

## When to Read Supporting Documentation

### Daily Note Work → Invoke `daily-note-management` skill
Invoke this skill after completing ANY work, BEFORE responding. The skill provides entry format, file location, and complete procedures.

### Command Usage → Read [[Command Usage Guide]]
**Summary**:
- `/add-gdd-request [OPTIONS] [TYPE] [TITLE]` - Add feature requests (FR-XXX) or design constraints (CR-XXX) to K-Town GDD progress file with **automatic research orchestration**. After adding entry, IMMEDIATELY creates progress file, TaskCreate entries, and launches research agents (no prompt). Use `--no-research` to skip research. Supports `-h` for help, `-q` for quick mode (minimal questions, still researches), `--dry-run` for preview.
- `/daily-note N` - Create/backfill daily notes
- `/jot-idea <idea> [; more ideas]` - Quickly jot down ideas to today's daily note Ideas & Insights section. Auto-detects category tags from keywords. Supports multiple ideas separated by semicolons.
- `/ktown-debug <issue> [--verbose]` - Troubleshoot K-Town bugs through hypothesis-driven debugging with iterative fix attempts
- `/ktown-enrich [--phase=N] [--feature=ID] [--batch=N] [--interactive] [--deep] [--dry-run] [--yes] [--commit] [--continue]` - Enrich unenriched roadmap features with comprehensive research, validation, and synthesis. Supports parallel batch processing, interactive review, or deep multi-perspective research modes.
- `/ktown-gdd-context` - Load K-Town GDD creation context, validate progress, identify next action for agent onboarding (use when starting new session or recovering from crash)
- `/ktown-ideate [--count=N] [--phase=N] [--gap-analysis] [--deep] [--dry-run] [--yes] [--commit]` - Generate new feature ideas for K-Town roadmap using multi-agent research with player-centric lenses. Supports gap analysis and deep research modes.
- `/ktown-implement <plan-path> [--phase=N] [--continue] [--verify-only]` - Execute K-Town implementation plan with modular code+test development and verification loops
- `/ktown-plan <research-path> [--interactive]` - Generate K-Town implementation plan from research artifact through 3-round focused planning workflow
- `/ktown-research <feature> [--external] [--deep]` - Comprehensive K-Town feature research with 2-3 agents per round across multiple rounds, creating web of interconnected research documents
- `/ktown-changelog-release [--version=X.X.X] [--contributor=Name] [--title="Title"] [--dry-run] [--no-push] [--yes]` - Smart auto-versioning release: detect changelog state, auto-generate content from conventional commits, update contributors (default: Kaspa_Omega), commit, push to main, and create GitHub release. Supports 6-case state detection (Unreleased/AutoClaude/fresh), semver-aware version bumps from commit prefixes, `--dry-run` preview, `--no-push` for local review, and `--yes` for automation
- `/new-agent` - Create specialized Claude agents
- `/project-init` - Master orchestration command
- `/prompt-upgrader [-Q]` - Transform basic prompts into well-architected prompts using Claude's 10 prompting principles. Uses multiple-choice clarifying questions to understand goal/vision, then applies relevant principles based on scope (project, research, creative, etc.). Output displayed in CLI and saved to daily note. Use `-Q` flag for quick mode (1-3 questions only)
- `/security-report` - Generate SOC incident reports
- `/sync-three-vfx [path]` - Fetch and show full status of the Three-VFX reference repo (or any git repo via optional path arg), then present 4 sync options (fast-forward, hard reset, stash+ff, abort) for the user to choose. Never auto-decides. Logs to daily note via skill.
- `/switch-multiplayer-mode [--to=lan|wan] [--quick] [--dry-run] [--no-verify]` - Intelligently switch K-Town between LAN and WAN (Demo) modes with automatic detection
- `/ai-merge [source-branch] [--into=target] [--dry-run] [--no-commit] [--verbose]` - AI-powered branch merge with intelligent conflict resolution. Detects conflicts via `git merge-tree`, categorizes files (new/deleted/source-only/true-conflicts), auto-resolves simple cases, and uses 3-way merge analysis for true conflicts. Works with any git repository.
- `/second-opinion <topic> [--files=path1,path2,...] [--cwd=project-path]` - Get a structured second opinion from OpenAI Codex CLI with multi-agent analysis. Claude forms independent position first, then Codex provides blind analysis. Produces structured comparison document in `thoughts/second-opinions/`. Requires Codex CLI + OPENAI_API_KEY.
- `/ultra-research` - Create ultra-comprehensive research artifacts with unlimited depth using research-specialist agent
- `/youtube-learn <url> [instructions]` - Extract YouTube video transcript via yt-dlp, comprehend content, and apply learnings to vault. Supports single or multiple URLs (sequential with GO/NO-GO gate). Always saves transcript to `thoughts/yt-transcripts/`. If no instructions given, asks 3-5 comprehensive clarifying questions. Can update rules, skills, codebases, research notes, CLAUDE.md, memory — any part of the vault. Requires `yt-dlp` (auto-installs on first run).
- `/ktown-gdd-sync [--fr=IDs] [--section=Ns] [--all] [--dry-run] [--yes] [--continue]` - Sync FR updates from progress file into relevant GDD sections. Default: sync only unsynced FRs. Use `--all` for full re-dissemination. Includes input condensation (fits 20K token cap), pre-sync content analysis (prevents duplication), lock file (prevents concurrent runs), Numbers Registry READ-ONLY with post-sync consolidation. Creates progress file + TaskCreate entries + launches parallel agents per section. Validates via line counts, key term grep, and marker audit.
- `/present <path-to-markdown> [--theme=dark|light] [--style=<style.yaml-path>]` - Generate visually rich HTML presentation from any markdown document. Auto-triggers after orchestrated workflows complete a final deliverable. Content-adaptive visualizations (charts, cards, timelines, diagrams). Checks for project style.yaml/brand.json; defaults to dark theme.
- **Auto-triggers**: "research"→Research workflow, "new project"→Project init, "FINAL-*.md written"→HTML presentation offer

### K-Town GDD Progress Tracking → MANDATORY
**CRITICAL**: When working on K-Town GDD creation, you MUST update the progress tracker after ANY stage progress or completion.

**Progress Tracker Location**: `Personal/Projects/K-Town/thoughts/plans/2025-10-27/GDD-Creation-Progress-Tracker.md`

**When to Update**:
1. **During Stage Work**: After answering each question within a stage (optional, for long stages)
2. **Stage Completion**: MANDATORY update when any stage completes (Stage 1, 2, 3, or 4)
3. **Section Completion**: MANDATORY update when entire section completes (all 4 stages done)

**What to Update**:
- **Header timestamp**: `**Last Updated**: YYYY-MM-DD | HH:MM AM/PM`
- **Overall progress**: Update section count and percentage (e.g., "1 of 23 sections complete (4%)")
- **Stage status**: Change ⏳ → 🔄 → ✅ with completion date
- **File paths**: Document deliverable files created (e.g., `Stage1-[Section]-Questionnaire.md`)
- **Question summaries**: Brief bullet points of what was answered/resolved
- **Key strategic decisions**: Major pivots, clarifications, or design choices made

**Update Sequence**:
1. Complete work (answer questions, create synthesis, etc.)
2. Document in daily note (per standard protocol)
3. **Update progress tracker** (add this step!)
4. Respond to user with summary

**Example Progress Tracker Update**:
```markdown
#### §1 Executive Summary & Vision
- ✅ Stage 2: Clarifying Questions Complete (8 questions answered, 2025-11-03 to 2025-11-04)
  - File: `Stage2-Executive-Summary-Clarifying-Questions.md`
  - Q1: Success Metrics (comprehensive table, 4 categories × 3 time horizons)
  - Q2: Mobile Wallet Strategy (Year 1 custom account-pairing, social SSO)
  [... Q3-Q8 ...]
- ⏳ Stage 3: Synthesis (Ready to begin - all answers complete)
```

**Why This Matters**: Progress tracker enables session recovery, agent handoffs, and strategic planning visibility. Without updates, progress is lost across sessions.

### Template Usage → Read [[Templates and Content Standards]]
**Summary**:
- Daily Note: YAML frontmatter + Agenda & Tasks + Journal + Notes
- Meeting Note: Attendees + Summary + Action Items + Transcript
- File References: .md files use [[brackets]], others use 'quotes.ext'
- Hub Files: Project overview + status + documents + action items

### Complex Workflows → Read [[Agentic Workflow System]]
**Summary**:
- **Auto-triggers**: "research/investigate/analyze" → Research workflow
- **Project triggers**: "new project/implement/build" → Project initialization
- **Complexity assessment**: Simple (3-5 Q), Medium (5-10 Q), Advanced (10-30 Q)
- **Agents available**: Research Specialist, Discovery Agent, Implementation Specialist

### Research Tasks -> MANDATORY: Verify Orchestration Compliance FIRST
**Auto-trigger keywords**: "research", "investigate", "analyze", "compare", "evaluate", "comprehensive", "thorough", "deep-dive", "ultra"

**BEFORE proceeding with ANY research task**:
1. STOP - Do NOT immediately launch agents or skills
2. Verify Phase 0: Have clarifying questions been asked? If NO -> AskUserQuestion
3. Verify Phase 1: Has context been gathered? If NO -> Read relevant files, grep, web fetch
4. Verify TaskCreate: Have tasks been created? If NO -> Create task list
5. Verify Progress File: Has progress file been created? If NO -> Create it
6. ONLY THEN proceed with agent delegation (Phase 3)

**Summary**:
- Create dedicated .md file for substantial research
- Include Executive Summary + Methodology + Findings + Analysis
- Place in appropriate folder structure with proper citations
- **Triggers**: Multi-file analysis, directory structure review, tool evaluations
- **Location**: Use project-specific thoughts directory if applicable, otherwise root `thoughts/` (see File Organization)

### Implementation Tasks -> MANDATORY: Enter Plan Mode FIRST
**Auto-trigger keywords**: "implement", "build", "create", "develop", "migrate", "refactor", "port", "rewrite", "integrate", "add feature", "redesign", "overhaul", "update" (when multi-file), "setup"/"set up", "configure", "optimize", "upgrade", "deploy", "scaffold", "patch", "extend", "convert", "extract"

**Two-step trigger** (prevents false positives on non-code requests):
1. Keywords activate SCOPE ASSESSMENT — not immediate plan mode entry
2. Only if scope is Medium+ AND the request involves code/system changes → proceed to plan mode

**Exclusion patterns** (route elsewhere):
- Questions ("how to implement", "explain how to build") → treat as informational
- Content generation ("create a summary", "build a comparison table") → not implementation
- Already-handled domains ("create a daily note", "add feature request to GDD") → route to existing commands
- Project-specific commands available (e.g., K-Town has `/ktown-plan`, `/ktown-implement`) → suggest those first

**BEFORE proceeding with ANY implementation task**:
1. STOP — Do NOT write code or launch implementation agents
2. Assess scope → If Medium+ → Invoke EnterPlanMode tool
3. **BLOCKING**: Use the Read tool to read `implementation-plan-standard.md` — do NOT rely on memory or summarized context. The template has 16 numbered sections and a Scaling Guide; skipping the read causes freeform drift.
4. Follow Implementation Plan Flow using the template just read
5. Self-validate plan against compliance checklist (bottom of `implementation-plan-standard.md`)
6. Present plan → ExitPlanMode
7. ONLY THEN proceed with implementation

### Worktree Implementation → Read `worktree-implementation-workflow.md`
**Summary**:
- Use git worktrees for isolated feature implementation
- **Source vs Target**: Source is READ-ONLY reference, Target is where ALL changes happen
- **Progress file**: `thoughts/plans/YYYY-MM-DD-[slug]/progress.md` is North Star
- **TOUCHBACK pattern**: Every phase task followed by checkpoint task that updates progress.md
- **Phase gates**: Build → Typecheck → E2E tests must pass before next phase
- **Constraints**: Document MUST NOT TOUCH files at workflow start
- **Triggers**: Feature integration, multi-file refactoring, autonomous implementation workflows
