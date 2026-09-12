# Orchestration contract

The root reads this contract at the selected preset's delegation entry point.
Children receive only the constraints and sources needed for their assignment.

## Complete the authorized task

For implementation requests, continue through agreed acceptance, including
in-scope repairs and necessary retests. Plans, first drafts and child results
are intermediate work. Ask only for new authority, material requirement choices
or unresolved blockers. Consultation and planning requests retain their scope.
A child report calls for root judgment, not automatic user approval.

Delegate under the preset's trigger when bounded independent work materially
helps time or quality. No fixed explorer → worker → tester → reviewer pipeline
is required. Keep short, tightly coupled work or assignments whose handoff and
supervision cost approaches direct implementation on the root.

## Coordinate and hand off

Respect the preset's thread cap. One agent writes a checkout at a time,
including the root and test artifacts; read-only work uses frozen source.
Leaf agents do not delegate. Assign resource ownership when relevant.

For dependent or parallel work, track task ID, depends_on, source, ownership and
status. Start ready work only; verified completion unlocks dependencies, while
failed, cancelled or unverified work results do not. Replan circular dependencies.
Otherwise skip the dependency table. Continue useful independent work; wait only
for an actual dependency. Stay responsive to the user.

Build each request from [task-packet.md](task-packet.md), including the Worker
agreement when assigning the built-in worker. Send applicable user permissions
and constraints explicitly. Delegation never grants additional authority.
Read task-specific sources fully enough to understand the change; reuse unchanged
material already read and expand when source or assumptions change. A bounded
handoff does not remove runtime-inherited or automatically injected context.

## Record routing and accept results

The root associates task ID, role, expected model/effort and explicit/inherited
mode with client/session metadata when visible. Children must not guess or prove
their model. Record hidden routing as unverified, not as a mismatch or proof;
it does not invalidate independently verified work.

A route mismatch, or an unavailable explicit route, blocks acceptance of child code changes.
Record the failure and retry once only under the preset's existing fallback.
Use [lifecycle.md](lifecycle.md) for correction or takeover and
[result-contract.md](result-contract.md) before accepting results.
