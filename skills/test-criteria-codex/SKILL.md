---
name: test-criteria-codex
description: Codex-authored test-criteria contract for /plan Phase 1.5. Invokes the OpenAI Codex CLI ONCE per feature (single-agent analyst profile, read-only sandbox) to generate an AUTHORITATIVE + LOCKED acceptance-criteria contract that /implement must satisfy per phase. Output is `test-criteria.md` injected into the plan's Section 7 as §7.5. Use when planning any feature where "graded your own homework" failure mode is a concern — Codex acts as the unbiased third-party reviewer that defines WHICH new tests must exist for the feature to ship. Triggers: "/plan Phase 1.5", "Codex test criteria", "lock test criteria", "test-criteria-codex".
---

# Test Criteria Skill (Codex-Driven)

## Purpose

When Claude writes both the code AND the tests in a single implementation pass (the standard `/implement` "small unit → unit test → verify → repeat" loop), the test surface is bounded only by what Claude thinks is sufficient — the classic "graded your own homework" failure mode. The independent-verification sub-agent catches false-positive PASS claims, but it cannot tell you that **the test set itself is too small** to prove the spec was implemented.

This skill closes that gap by invoking **OpenAI Codex CLI as an unbiased third-party reviewer of the spec + draft plan**, producing a strict, machine-parseable list of test criteria that:

1. Each cite a specific spec line or section (no inventing requirements not in the spec)
2. Each get a tier (`unit` / `integration` / `e2e` / `performance` / `manual`)
3. Each name a target file path under the project's existing test tree
4. Each get a suggested test-function name implementation must produce
5. Each are grouped by which **draft plan phase** they belong to

The criteria become **authoritative + locked** acceptance criteria for the plan's Section 7 (injected as a new §7.5 subsection). They cannot be silently dropped by `/implement` — the only legitimate way to remove a criterion is for the **user** to manually edit `test-criteria.md`, producing a commit-tracked audit trail.

## When invoked

**EXACTLY ONCE per feature**, at `/plan` Phase 1.5 — specifically:

- AFTER Rounds 1–3 of the planning flow produce the draft-plan + potential-issues + SME-synthesis artifacts
- AFTER the SME synthesis has consolidated the plan, BEFORE "Final: Create Implementation Plan" writes the canonical plan document
- BEFORE `/plan` exits (BEFORE the user is offered `/implement <plan-path>`)

**NOT invoked**:

- ❌ Per-phase during `/implement` (the contract is locked at plan time and consumed, not re-generated)
- ❌ As a final-sweep audit at end of `/implement`
- ❌ On bug-fix or debug workflows
- ❌ On research workflows

**Invocation is optional but recommended** for any feature plan. The `/plan` flow self-validation checklist considers a plan complete either when `test-criteria.md` exists OR when §7.5 is marked `codex-coverage:unavailable` with an explicit user opt-out reason.

## What it produces

A single artifact written to the plan directory:

```
<plan_output_dir>/<date>-<slug>/test-criteria.md
```

The file structure is defined in `output-schema.md`. In short:

- YAML frontmatter (generation timestamp, codex version, spec/plan paths, total criteria, coverage %)
- One section per draft-plan-phase, listing the criteria assigned to that phase
- Per-criterion fields: `id`, `tier`, `requirement_id_from_spec`, `assertion_text`, `target_file_path`, `suggested_test_name`, `traceability_quote`, `category`, `plan_phase`
- A coverage matrix mapping each spec requirement to its criteria
- A gaps section listing spec requirements with NO testable criterion (explicit human review)
- Codex's self-attestation block (✅/❌ on traceability, no-invention, and coverage)

The same content is mirrored into the plan's §7.5:

```
## 7. Test Inventory
### 7a. Existing Test Suite ...        # already exists
### 7b. New Tests Plan (per phase) ... # already exists
### 7c. Regression Risk Prediction ... # already exists
### 7.5 Codex-Authored Test Criteria (LOCKED AC)   # ← NEW, injected by this skill
```

§7.5 contains a summary table (criterion ID → tier → phase → target file) plus the `test-criteria.md` artifact path. Full per-criterion detail stays in `test-criteria.md` to keep the plan readable.

## Authority model

**AUTHORITATIVE + LOCKED**. Implications:

1. **Contractual** — `/implement` MUST satisfy every criterion as part of per-phase three-tier verification. The phase cannot pass if any criterion assigned to that phase is unmet. See `integration-points.md` for the exact verification protocol.
2. **Claude cannot unilaterally skip** a criterion. No `--skip-criterion` flag, no "this seems unnecessary" fast-path. If Claude believes a criterion is wrong (e.g., it references a file path that doesn't make sense), Claude must **HALT and surface the conflict to the user** — user resolves by either (a) updating the implementation to fit the criterion, or (b) manually editing `test-criteria.md`.
3. **User-only veto** via direct edit of `test-criteria.md`. Editing produces a commit-tracked diff that IS the audit trail. There is no "advisory" mode — every criterion in the file is active until removed.
4. **Removed criteria require a reason** — when the user edits a criterion out, add a `REMOVED-BY-USER: <reason>` comment line near where it was, for posterity and so downstream sessions don't try to re-add it.

The locked-from-plan-time design is deliberate. Allowing Claude to add or modify criteria during implementation would defeat the unbiased-third-party value of having Codex generate them. The user is the only authority who can modify the contract after generation.

## Configuration

Reads `.claude/workflow-config.json`. Key fields:

```json
{
  "codex": {
    "enabled": true,
    "profile": "analyst",
    "sandbox": "read-only",
    "timeout_seconds": 300,
    "min_version": "0.130.0"
  },
  "test_tree_paths": [
    "tests/unit",
    "tests/integration",
    "tests/e2e",
    "tests/performance"
  ],
  "test_commands": {
    "test_unit": "npm run test:unit",
    "test_e2e": "npm run test:e2e"
  }
}
```

`test_tree_paths` tells Codex where new test files should land. If absent, defaults to common conventions (`tests/`, `__tests__/`, `spec/`).

## Prerequisites

Before invoking:

- `codex --version` returns ≥ configured `min_version` (default `0.130.0`)
- `~/.codex/config.toml` exists with `[profiles.<profile>]` (default `analyst`) configured with `sandbox_mode = "read-only"` and `model_reasoning_effort = "high"`
- The spec path passed to `/plan` exists and is readable
- The draft plan (from Round 3 SME synthesis) exists and is readable

If any prerequisite fails, the skill reports the gap and offers options (see `invocation-protocol.md`).

## Reference Files

| Path | Role |
|------|------|
| `invocation-protocol.md` | Step-by-step protocol (prereq check → prompt build → Codex exec → output parse → schema validation → criteria injection → cleanup) |
| `output-schema.md` | Strict schema Codex must produce (YAML frontmatter, per-criterion fields, coverage matrix, gaps section, self-attestation) and validation rules that detect malformed output |
| `codex-prompt-template.md` | Verbatim Codex prompt with `{PLACEHOLDER}` substitutions for spec body, draft plan body, existing test inventory, project-specific constraints from workflow-config.json |
| `integration-points.md` | How `/plan` and `/implement` consume the skill, §7.5 injection format, user-veto mechanism, failure modes |

## What this skill is NOT

- **NOT a wrapper around `/second-opinion`** — that command is multi-agent + structured comparison. This skill is single-agent, focused on test criteria. Different output, different lifecycle.
- **NOT a research tool** — does not browse the web. Codex runs in read-only sandbox over the spec + draft plan + test inventory it is fed.
- **NOT a code reviewer** — looks at SPEC and PLAN, not implementation code. Post-implementation code review is a separate concern (use `/second-opinion`).
- **NOT a regression-test selector** — generates NEW test criteria. The downstream cumulative-regression layer (governed by `rules/regression-testing-protocol.md` if you have it, or by your test-running conventions) selects which EXISTING tests to run.

## Relationship to other skills/rules

| Domain | Authority | This skill's relationship |
|---|---|---|
| HOW to write good tests for this project | Project-specific test patterns (e.g., your own `testing.md` skill or doc) | DEFERS — Codex's prompt explicitly directs criteria to follow the project's existing patterns |
| Cumulative gate model, three-tier verification, stash-revert disambiguation | `rules/regression-testing-protocol.md` (in this framework) or equivalent | DEFERS — this skill adds an **upstream layer** (what new tests must be written) BEFORE that rule's layer (what existing tests must continue passing) |
| Plan structure, Section 7 format, three-tier acceptance criteria | `rules/implementation-plan-standard.md` | DEFERS — this skill INJECTS a new §7.5 subsection, does NOT redefine the section |
| Codex CLI invocation patterns | `commands/second-opinion.md` | REUSES the patterns (analyst profile, `-s read-only`, prompt-to-file, output-to-file) — does NOT wrap or call `/second-opinion` |
