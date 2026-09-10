# Subagent task packet

Copy this structure into each fresh-context handoff. Remove fields that truly do
not apply, but never omit source identity, permissions, acceptance criteria, or
stop conditions.

```text
Task ID:
Role:
Purpose:
Why this is delegated:

Checkout / workspace:
Base revision:
Exact source revision:
Dirty state or task-related working-tree fingerprint:
Owned files, outputs, ports, and processes:

Expected model:
Expected reasoning effort:
Route mode: explicit | inherited

depends_on:
Related active tasks:
required_reading:
  - path — exact section or reason

Inputs:
Constraints and authorization boundary:
Allowed writes:
Forbidden actions:

Acceptance criteria:
Verification method:
Evidence or artifact destination:
Stop conditions:
Steering checkpoint, if any:
Parent wait condition:

Return format:
  - task ID and recommended status
  - required reading completed
  - source identity used
  - files changed or evidence paths
  - validation performed
  - findings or outcome
  - remaining uncertainty and blockers
```

For read-only tasks, explicitly say that no files may be edited. For write tasks,
give non-overlapping ownership and identify who integrates the result. For tests,
freeze the source and preserve the first failure.
