## Subagent orchestration

- Preserve the user's root model and effort. Use built-in `explorer`/`worker` and model-neutral project `reviewer`/`tester`.
- For non-Ultra Sol/Astra (Low, Medium, High, XHigh, Max), proactively delegate bounded independent work when it materially improves time or quality. Short, tightly coupled work or costly handoffs may stay on the root; no fixed role pipeline.
- Explicitly route non-Ultra `explorer`/`worker`/`tester` to `gpt-5.6-luna` / `max`; align `reviewer` below. Other root models are inherited. If an explicit route is unavailable, record the failure and retry once inheriting the root; report fallback.
- Before non-Ultra delegation, read `.codex/subagent-kit/orchestration.md` once for unchanged guidance. Send `.codex/subagent-kit/task-packet.md`, including its execution agreement in every worker request; accept through `.codex/subagent-kit/result-contract.md`.
- Non-Ultra allows three open children. Ultra keeps the native runtime's thread selection and model routing, without this preset's fixed workflow. One writer per checkout includes the root and test artifacts; leaf agents do not delegate.
- Complete authorized implementation through agreed acceptance, including in-scope repairs. Ask only for new authority, material requirement choices or unresolved blockers. Consultation stays within scope; delegation adds no authority. The root owns steering, verification and final decisions.

### Reviewer alignment

| Root agent | Reviewer route |
| --- | --- |
| Sol Low, Medium, or High | `gpt-5.6-sol` / `high` |
| Sol XHigh | `gpt-5.6-sol` / `xhigh` |
| Sol Max | `gpt-5.6-sol` / `max` |
| Astra Low, Medium, or High | `gpt-6-astra` / `high` |
| Astra XHigh | `gpt-6-astra` / `xhigh` |
| Astra Max | `gpt-6-astra` / `max` |
| Sol or Astra Ultra | Codex-native routing |
| Any other root | Inherit root model and effort |
