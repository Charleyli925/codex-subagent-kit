## Subagent orchestration

- Preserve the model and reasoning effort selected by the user for the root agent.
- Use Codex's built-in `explorer` and `worker`, plus the project `reviewer` and `tester`. Roles are model-neutral; children inherit the root model and effort unless the parent explicitly selects another supported route.
- Proactively delegate concrete, bounded work when independent execution is likely to save meaningful time or improve quality. Prefer read-heavy or noisy exploration, tests, logs, triage, and summaries. Keep short, tightly coupled, or critical-path work on the root.
- Before the first spawn in a substantial task, read `.codex/subagent-kit/orchestration.md`. Build each child request from `.codex/subagent-kit/task-packet.md` and accept results only through `.codex/subagent-kit/result-contract.md`.
- At most three children may be open concurrently. Only one agent may write a checkout at a time, including test artifacts. Leaf agents do not spawn children.
- The root stays available to the user and owns authorization, routing, steering, stopping, integration, evidence verification, and final decisions. Delegation never expands user authorization.
- Every fresh-context child receives a self-contained task packet with task-specific `required_reading`. Missing or conflicting required sources block the child; unrelated documents are not loaded.
