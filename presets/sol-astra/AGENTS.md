## Subagent orchestration

- Preserve the model and reasoning effort selected by the user for the root agent. No project rule or child profile may replace, upgrade, or downgrade the root selection.
- Use Codex's built-in `explorer` and `worker`, plus the project-defined, model-neutral `reviewer` and `tester`.
- For non-Ultra Sol and Astra, proactively delegate concrete, bounded work when independent execution is likely to save meaningful time or improve quality. Prefer read-heavy or noisy exploration, tests, logs, triage, and summaries; keep short, tightly coupled, or critical-path work on the root.
- Route non-Ultra `explorer`, `worker`, and `tester` to `gpt-5.6-luna` with `max` effort. Route `reviewer` to the root model family with a `high` floor, matching `xhigh` or `max` when the root uses that effort. Pass the selected model and effort explicitly when spawning.
- Sol/Astra Ultra uses Codex-native routing. Any other root model is inherited by children. If an explicit route is unavailable, record the failure and retry once by inheriting the root; report the fallback.
- Before the first non-Ultra spawn in a substantial task, read `.codex/subagent-kit/orchestration.md`. Build each request from `.codex/subagent-kit/task-packet.md` and accept results only through `.codex/subagent-kit/result-contract.md`.
- At most three children may be open concurrently. Only one agent may write a checkout at a time, including test artifacts. Leaf agents do not spawn children.
- The root stays available to the user and owns authorization, routing evidence, steering, stopping, integration, result verification, and final decisions. Delegation never expands user authorization.

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
