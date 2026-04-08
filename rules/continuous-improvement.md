# Continuous Improvement Monitoring

SENSITIVITY: aggressive
<!-- Options: conservative | moderate | aggressive -->
<!-- conservative: 3+ signals required, Critical/High only, max 1/conversation -->
<!-- moderate: 2+ signals required, Critical/High/Medium, max 2/conversation -->
<!-- aggressive: 1+ signal sufficient if high-confidence, all severities, no limit -->

## Detection Triggers (evaluate after completing any task)

After completing work and before responding, briefly assess whether any of these signals appeared:

- **Repeated workaround**: Same multi-step manual pattern performed 2+ times this session
- **Error-correction loop**: Tool/command failure required manual fix that could be automated
- **Documentation friction**: Had to read docs to perform a task that should be codified in a rule/skill
- **Stale content**: Found outdated information (dates >6 months old, deprecated APIs, broken links)
- **Missing cross-links**: Navigated between related files lacking [[wiki links]]
- **Missed skill activation**: A skill/command exists for this task but was not used
- **Suboptimal tool selection**: Used a general tool when a specialized one exists
- **Quality gap**: Output required significant rework that a better process would prevent
- **No distributional shift**: Skill restates default Claude behavior without shifting output quality — no unique workflow, lived experience, or domain packaging
- **Missing gotchas flywheel**: Skill used 3+ times but has accumulated zero gotchas or known pitfalls
- **Railroading over guidance**: Skill uses rigid step-by-step scripting where goal-first guidance with context (WHY) would produce better results
- **Repeated API derivation**: Skill does repeated API/CLI work that could be cached in pre-built scripts to save tokens
- **Work context drift**: Conversation reveals team changes (new hires, departures, reorgs), new tools adopted, role/responsibility changes, compensation updates, or organizational shifts not reflected in `work-context/` rule files. Also triggers when `goodwin.md` Last Verified date is >90 days old.

## Activation Protocol

When a signal is detected:
1. **Complete the user's task first** -- never interrupt current work
2. After responding, note the opportunity in a single sentence with evidence
3. Ask: "I noticed [signal + specific evidence]. Worth researching an improvement?"
4. If YES: Invoke the `continuous-improvement-assessor` skill
5. If NO/LATER: Log to daily note under "Improvement Opportunities" for future reference

## Guards

- Respect the SENSITIVITY level configured above
- Max improvement suggestions per conversation: conservative=1, moderate=2, aggressive=unlimited
- Never suggest improvements to THIS rule file or the assessor skill itself in the same session where they were last modified (recursion guard)
- Skip if Large+ orchestration is in progress (user is focused on complex work)
- If user declined a similar improvement category in the last 3 sessions, suppress (negative memory)
