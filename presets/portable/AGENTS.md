## Subagent orchestration

- Preserve the user's root model and effort. Use built-in `explorer`/`worker` and project `reviewer`/`tester`; children inherit unless explicitly routed.
- Proactively delegate bounded independent work when it materially improves time or quality. Short, tightly coupled work or costly handoffs may stay on the root; no fixed role pipeline.
- Before delegation, read `.codex/subagent-kit/orchestration.md` once for unchanged guidance. Send `.codex/subagent-kit/task-packet.md`, including its execution agreement in every worker request; accept through `.codex/subagent-kit/result-contract.md`.
- At most three open children; one writer per checkout, including the root and test artifacts. Leaf agents do not delegate.
- Complete authorized implementation through agreed acceptance, including in-scope repairs. Ask only for new authority, material requirement choices or unresolved blockers. Consultation stays within scope; delegation adds no authority. The root owns steering, verification and final decisions.
