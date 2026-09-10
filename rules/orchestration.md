# Orchestration contract

Read this document before the first subagent spawn in a substantial task. The
root agent owns this contract; children receive only the parts relevant to their
bounded assignment.

## Decide whether to delegate

Delegate when all of these are true:

1. The task is concrete and bounded.
2. It can run independently from the root's current critical path.
3. Parallel execution is likely to save meaningful time or improve quality.
4. Inputs, permissions, source identity, acceptance criteria, and stop conditions
   can be written down.

Prefer exploration, codebase mapping, test execution, log analysis, issue triage,
independent review, and summarization. Keep short operations, tightly coupled
design decisions, irreversible actions, and work that continuously depends on
the root's judgment on the root thread.

Subagents consume additional tokens and coordination time. More agents are not
automatically better.

## Plan dependency waves

Maintain a compact task table with:

- task ID;
- role;
- `depends_on` task IDs;
- source identity;
- file or resource ownership;
- `blocked | ready | active | completed | failed | cancelled` status.

Start only `ready` tasks. A result unlocks dependent work only after the root
verifies its evidence and marks it `completed`. Failed, cancelled, stale, or
unverified work does not unlock dependencies. Break circular dependencies into a
new sequence instead of forcing them to run.

## Control concurrency

- Respect the selected preset's thread cap.
- Only one agent may write a checkout at a time, including generated test files.
- Read-only agents may inspect the same frozen source or diff in parallel.
- Assign explicit ownership of files, ports, build directories, and app instances.
- Leaf agents do not spawn children.

## Route models explicitly when required

Before spawning, record the role, expected model, expected reasoning effort, and
whether each value is explicit or inherited. Do not ask a child to prove its own
route. When the client exposes thread or session metadata, the root may verify the
actual model and effort there.

If an explicit route is unavailable or mismatched, do not accept child code
changes. Record the original failure and retry once only when the preset allows a
documented fallback. A hidden route is `unverified`, not proven and not
automatically mismatched.

## Send a self-contained task packet

Use `task-packet.md`. Do not send complete conversation history when a bounded
packet is enough. Every fresh-context child receives task-specific
`required_reading`; the child reports missing or conflicting sources instead of
guessing.

Repeat applicable user constraints and authorization boundaries. Delegation does
not authorize commits, pushes, pull-request changes, merges, installs, releases,
messages, purchases, or destructive actions unless the user already placed that
action in scope.

## Stay responsive

The root continues useful non-overlapping work while children run. Wait only
when a child result is a real dependency. Keep the user informed during longer
work, and avoid flooding them with unchanged agent status.

Use `lifecycle.md` to steer, stop, cancel, and close work. Use
`result-contract.md` before accepting any result.
