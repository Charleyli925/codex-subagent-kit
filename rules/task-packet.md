# Subagent task packet

The root includes these essentials in each request; combine fields as useful.
Omit irrelevant extensions rather than filling them with "none".

```text
Task: ID, role, goal and intended outcome.
Source: absolute checkout, base and revision; relevant uncommitted diff or working-tree fingerprint, including relevant untracked files.
Ownership: allowed reads/writes, owned files, forbidden actions; no child delegation.
Inputs: facts, constraints and task-specific required_reading paths/sections/symbols.
Acceptance: important scenarios, verification method; evidence destination if persistent output is needed.
Escalation: facts requiring a pause of affected work and safe work that may continue.
Return: task ID/status, reading completed, source used, changes/evidence, validation, deviations and blockers.
```

HEAD alone is insufficient in a dirty checkout. The root owns the task-linked
route record in [orchestration.md](orchestration.md); children do not self-attest.
Add depends_on, related tasks, ports, processes, build directories, checkpoints
and wait conditions only when relevant. Explicitly forbid writes for read-only
tasks; freeze source for tests. Missing or conflicting required sources must be
reported with evidence, not guessed.

## Worker handoff

Before assigning the built-in worker, add the intended behavior, settled key
decisions and reasons, relevant files/symbols, preserved behavior/interfaces,
allowed scope, and important acceptance scenarios to the packet. Resolve
correctness-critical ambiguity without prescribing every line or implementing
the task in advance. Overall complexity does not disqualify Luna; if remaining
work needs continuous design judgment or handoff is not worthwhile, keep it on
the root.

**Include this execution agreement directly in every worker request:**

> Read the implementation and necessary callers, types and tests; check the
> plan's assumptions against current source. Autonomously handle local
> implementation, helper organization, type adaptation, necessary test additions
> and focused self-checks within scope; no plan-restatement approval round trip.
> Preserve others' changes; do not widen scope, weaken assertions or bypass checks.
> Resolve ordinary local differences yourself. Pause affected changes and return
> evidence only when new facts overturn key assumptions, change agreed behavior
> or public interfaces, widen writes, require new authority or invalidate acceptance.
> Continue clearly safe unaffected work without hiding blockers. Report actual
> changes, validation, material deviations and unresolved issues; the root accepts
> the result.
