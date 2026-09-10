# Subagent lifecycle

## Steer

Send one focused correction when a critical input changes, the child drifts out
of scope, duplicates another task, uses stale source, violates ownership, or
cannot return the agreed evidence. State the changed fact and the desired next
action; do not resend the entire task packet unless it is no longer valid.

## Stop or cancel

Mark work `cancelled` when it is obsolete or replaced. Mark it `failed` when it
targets the wrong source, needs unauthorized action, conflicts with another
writer, violates a stop condition, or still makes no valid progress after one
focused correction.

Preserve useful read-only evidence, stop owned processes, and release file,
resource, and port ownership. Never kill unrelated processes.

## Complete

A child may recommend `completed`, but only the root can accept completion after
applying the result contract. A completed thread does not itself prove that its
changes were integrated or that the parent task is finished.

## Close

Let the runtime release completed threads normally. If a completed thread still
occupies capacity, use only controls exposed by the current client. If the client
does not expose closing or releasing, report that limitation instead of
inventing an operation or exceeding the thread cap.
