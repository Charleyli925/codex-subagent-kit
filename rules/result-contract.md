# Result acceptance contract

A child summary is a lead, not final proof. Before using it to unlock dependent
work or claim completion, the root verifies the evidence appropriate to the task.

## Required result fields

- Task ID and recommended status.
- Role and completed `required_reading`.
- Expected route and the actual route when independently visible, otherwise
  `unverified`.
- Source revision or working-tree fingerprint used.
- Changed files, findings, or persistent evidence paths.
- Validation performed and exact outcome.
- Remaining uncertainty and blockers.

## Root acceptance checks

1. The result used the intended source and base.
2. The child stayed within its file, resource, and authorization boundary.
3. Required reading was available and completed.
4. The diff, cited files, logs, reports, or artifacts support the summary.
5. Acceptance criteria were actually exercised.
6. Model routing met the preset, was an authorized fallback, or is honestly
   recorded as unverified.
7. No conflicting writer invalidated the result.
8. Required processes are no longer running, unless ownership was explicitly
   transferred.

Only the root publishes the authoritative final status. If evidence is stale,
missing, contradictory, or tied to changed source, keep the task blocked or
failed and preserve useful partial evidence.
