# Integration Points — test-criteria-codex

How `/plan` and `/implement` consume this skill, the §7.5 injection format, the user-veto mechanism, and failure modes.

## §1. /plan integration — §7.5 injection format

The orchestrator running `/plan` injects this exact block into the Final Implementation Plan's Section 7 (after 7c Regression Risk Prediction):

```markdown
### 7.5 Codex-Authored Test Criteria (LOCKED AC)

**Source artifact**: `test-criteria.md` (in this plan directory)
**Generated**: <generated_at from frontmatter>
**Codex version**: <codex_version from frontmatter>
**Total criteria**: <total_criteria from frontmatter>
**Coverage of spec**: <coverage_pct from frontmatter>%
**Authority**: AUTHORITATIVE + LOCKED — `/implement` MUST satisfy every criterion as part of per-phase three-tier verification. User-only veto via manual edit of `test-criteria.md` (commit-tracked diff IS the audit trail).

**Summary by phase**:

| Phase | Critical | Supplementary | Total | Tiers |
|---|---|---|---|---|
| Phase 1: <name> | <N> | <M> | <N+M> | <comma-separated distinct tiers> |
| Phase 2: <name> | <N> | <M> | <N+M> | <comma-separated distinct tiers> |
| ... | | | | |

**Gaps flagged by Codex** (spec requirements with no testable criterion — review before shipping):

- <bullet list from `## Gaps` section of test-criteria.md>
- (or: "None — every spec requirement has at least one criterion.")

**Self-attestation from Codex** (verbatim from test-criteria.md):

- Traceability: ✅/❌
- No-invention: ✅/❌
- Coverage: ✅/❌

For full per-criterion detail (assertion text, target file path, suggested test name, traceability quote per criterion), see `test-criteria.md` in this plan directory.
```

### Generating the summary table

The orchestrator parses `test-criteria.md` and groups criteria by `plan_phase` field. For each phase:
- `Critical` = count of criteria with `category: critical`
- `Supplementary` = count of criteria with `category: supplementary`
- `Total` = `Critical + Supplementary`
- `Tiers` = comma-separated unique `tier` values across that phase's criteria

### Unavailable variant

If Codex was unavailable and the user opted to proceed (`unavailable` signal from `invocation-protocol.md` Step 7), the orchestrator writes a stub §7.5:

```markdown
### 7.5 Codex-Authored Test Criteria (LOCKED AC)

`codex-coverage:unavailable — reason: <user-provided reason>`

This plan was approved without Codex-generated locked test criteria. `/implement` will warn-and-proceed in this mode rather than abort. Standard three-tier verification + independent verification sub-agent remain MANDATORY; only the upstream "what new tests must exist" contract is missing.
```

---

## §2. /implement integration — per-phase criterion-verification gate

`/implement` consumes `test-criteria.md` once at startup (Step 2.5) and runs a per-phase criterion-verification gate (Step 4c) AFTER the standard three-tier cumulative regression passes.

### Step 2.5: Load criteria at startup

```
1. Read <plan-directory>/test-criteria.md
2. Parse YAML frontmatter
3. Parse all ### CRIT-NNN: blocks
4. Cache parsed criteria in session state
```

If the file is missing AND §7.5 is marked `codex-coverage:unavailable`: operate without the gate, log warning at every phase completion.

If the file is missing AND §7.5 has no `codex-coverage:unavailable` marker: ABORT with error suggesting user re-run `/plan`.

On `--continue`: RE-READ the file fresh (user may have manually edited it between sessions to add `REMOVED-BY-USER` markers).

### Step 4c: Per-phase criterion-verification gate

After standard three-tier cumulative regression passes, run this gate:

1. Filter criteria to entries where `plan_phase == <current phase>` AND `status != REMOVED-BY-USER`
2. For each filtered criterion, perform 3 mechanical checks:

   **Check 1: target_file_path exists**
   ```bash
   test -f "<PROJECT_ROOT>/<criterion.target_file_path>"
   ```

   **Check 2: suggested_test_name appears in the file**
   ```bash
   grep -i -F "<criterion.suggested_test_name>" "<PROJECT_ROOT>/<criterion.target_file_path>"
   ```
   (Case-insensitive substring match — implementer may have lightly reworded the test description; substring is the canonical key.)

   **Check 3: assertion_text key terms appear in the test body** (heuristic — flag only)
   - Extract 3–5 distinguishing nouns/verbs from `criterion.assertion_text`
   - For each term, grep for it in the file body
   - Tally how many of the key terms appear

3. Categorize each criterion:
   - **SATISFIED**: Check 1 ✅ + Check 2 ✅ + ≥ 50% of key terms appear
   - **PARTIAL**: Check 1 ✅ + Check 2 ✅ + < 50% of key terms appear (suspicious — may be a placeholder test that doesn't actually assert what's required)
   - **MISSING**: Check 1 ❌ OR Check 2 ❌

4. Display verification block (see `commands/orchestrated/implement.md` Step 4c for the exact ASCII box format)

5. Handle results:
   - **SATISFIED == total** (Missing = 0, Partial = 0): ✅ Proceed
   - **PARTIAL > 0 AND MISSING == 0**: ⚠️ Display partials; AskUserQuestion (confirm coverage / return to task loop / mark REMOVED-BY-USER)
   - **MISSING > 0** (HARD FAIL): Phase BLOCKED; AskUserQuestion (add missing tests / mark REMOVED-BY-USER / halt and re-plan)

### Critical constraint: Claude must NOT modify test-criteria.md programmatically

The only legitimate writes to `test-criteria.md` are user manual edits. Claude proposing the edit content for the user to copy-paste is acceptable; Claude using `Write` or `Edit` on the file is FORBIDDEN.

---

## §3. User veto mechanism

The user is the only authority that can modify `test-criteria.md` after generation. Three ways to veto a criterion:

### 3a. Mark REMOVED-BY-USER inline

User edits `test-criteria.md` and replaces a criterion's field block with a `REMOVED-BY-USER` marker:

```markdown
### CRIT-005: ~~Original assertion~~ — REMOVED-BY-USER

REMOVED-BY-USER: <reason for removal>
Date: 2026-05-15
```

The orchestrator's Step 2.5 parser recognizes `REMOVED-BY-USER` as a status marker and skips the criterion in Step 4c filtering.

### 3b. Edit the criterion in place

User edits one or more fields of a criterion (e.g., changes `target_file_path` to a different file, or rewords `assertion_text` to relax the assertion). The orchestrator re-reads on next session start (`--continue`) and uses the edited values.

This is the recommended path for "the criterion is right but the file path/test name needs to change due to a refactor."

### 3c. Drop the entire criterion

User deletes the entire `### CRIT-NNN: ...` block from `test-criteria.md`. The orchestrator's Step 2.5 parser does not see it; Step 4c does not enforce it.

NOT recommended — leaves no audit trail of WHY it was removed. Prefer 3a (REMOVED-BY-USER marker) for traceability.

---

## §4. Plan self-validation checklist additions

When `/plan` produces the Final Implementation Plan, its self-validation checklist gains:

- [ ] §7.5 (Codex-Authored Test Criteria) populated in the plan, OR plan explicitly marked `codex-coverage:unavailable` with documented user opt-out reason
- [ ] `test-criteria.md` artifact exists in the plan directory (or unavailable-marker documented)
- [ ] Codex's self-attestation is all ✅ (if any ❌, the skill will have flagged this and the plan should NOT be considered ready)

A plan that fails any of these is NOT ready for `/implement`. The orchestrator should NOT print the "Ready for: `/implement <plan-path>`" suggestion at the end — instead, surface the gap and offer remediation.

---

## §5. Failure modes summary

| Failure | Detected by | Resolution |
|---|---|---|
| Codex CLI not installed | invocation-protocol.md §A prereq check | User installs OR marks `codex-coverage:unavailable` OR aborts |
| Profile missing | invocation-protocol.md §B prereq check | Same A/B/C choice |
| Spec or draft plan missing | invocation-protocol.md §D prereq check | User provides correct path OR aborts |
| Codex timeout | invocation-protocol.md §E (5 min default) | Retry with shorter spec / mark unavailable / abort |
| Codex auth error | invocation-protocol.md §F | User configures OPENAI_API_KEY |
| Sandbox/permission error | invocation-protocol.md §G | User fixes config |
| Malformed output (1st attempt) | output-schema.md validation | Retry with explicit guidance |
| Malformed output (2nd attempt) | output-schema.md validation | Failure Handling §H — escalate; user marks unavailable OR aborts |
| Self-attested failure (any ❌) | output-schema.md attestation check | Treat as malformed; retry with attestation guidance |
| `test-criteria.md` missing at `/implement` start | implement.md Step 2.5 | ABORT with error if §7.5 lacks unavailable marker; otherwise warn + proceed |
| Phase has MISSING criteria (HARD FAIL) | implement.md Step 4c | AskUserQuestion (add tests / REMOVED-BY-USER / halt) |

---

## §6. Audit trail

Every legitimate state of the contract is git-trackable:

| State | Audit artifact |
|---|---|
| Codex generated criteria | `test-criteria.md` commit (timestamp in frontmatter) |
| User vetoed a criterion | Diff on `test-criteria.md` (commit message should explain why) |
| Plan marked unavailable | Plan §7.5 commit with reason |
| Implement satisfied all criteria | progress.md checkpoint: "Phase N Codex criteria: X/X SATISFIED" |
| Implement encountered PARTIAL | progress.md: "User-confirmed partial: CRIT-NNN" |
| Implement encountered MISSING | progress.md: "Phase N BLOCKED by missing Codex criteria; user resolved by <action>" |

The user is the sole authority for veto/edit decisions. Claude proposes; user disposes; git records.
