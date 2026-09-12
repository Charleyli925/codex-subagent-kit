# Subagent lifecycle

## Correct or take over

For planning or key-assumption errors, the root revises the plan within existing
authorization. For local implementation errors, send concrete evidence to the
original worker. Ordinary compile errors or local differences need no user approval.

Steer when inputs change, work drifts, duplicates effort, uses stale source or
cannot supply agreed evidence. Repeated misunderstanding of a constraint, no valid
progress after one focused correction, or renewed continuous design calls for
root takeover; do not resend the whole history.

## Stop and transfer ownership

Cancel obsolete/replaced work; fail wrong-source, unauthorized, conflicting or
unsuccessfully corrected work. Preserve useful evidence and the first test failure.
Before any repair or takeover, stop or finish the affected worker/tester and owned
processes, confirm write ownership is released, then edit. Never modify frozen
source while testing runs or stop unrelated processes.

## Complete and close

A child recommends completion; the root applies [result-contract.md](result-contract.md).
Let the runtime release completed threads. If capacity stays occupied, use only
the current client's exposed close/release controls; report missing capabilities
rather than inventing operations or exceeding the cap.
