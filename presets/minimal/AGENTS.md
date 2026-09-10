## Subagent orchestration

- Preserve the model and reasoning effort selected by the user for the root agent. Children inherit both unless the user or a task-specific instruction explicitly requests another supported route.
- Use Codex's built-in `explorer` and `worker`, plus the project `reviewer` and `tester`.
- Delegate when the user asks for subagents or when a substantial task contains clearly independent lanes whose separation materially improves quality or time. Keep short, tightly coupled, and critical-path work on the root.
- Before the first spawn, read `.codex/subagent-kit/orchestration.md`. Use `.codex/subagent-kit/task-packet.md` and `.codex/subagent-kit/result-contract.md`.
- At most two children may be open concurrently. Only one agent may write a checkout at a time. Leaf agents do not spawn children.
- The root owns authorization, routing, steering, integration, evidence verification, and final decisions. Delegation never expands user authorization.
