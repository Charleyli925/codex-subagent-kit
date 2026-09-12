## Subagent orchestration

- Preserve the user's root model and effort; children inherit unless the user or task-specific instructions explicitly request another supported route.
- Use built-in `explorer`/`worker` and project `reviewer`/`tester`. Delegate only on request or for clearly independent lanes in substantial work that materially improve time or quality; keep short, tightly coupled and critical-path work on the root.
- Before delegation, read `.codex/subagent-kit/orchestration.md` once for unchanged guidance. Send `.codex/subagent-kit/task-packet.md`, including its execution agreement in every worker request; accept through `.codex/subagent-kit/result-contract.md`.
- At most two open children; one writer per checkout, including the root and test artifacts. Leaf agents do not delegate.
- Complete authorized implementation through agreed acceptance, including in-scope repairs. Ask only for new authority, material requirement choices or unresolved blockers. Consultation stays within scope; delegation adds no authority. The root owns steering, verification and final decisions.
