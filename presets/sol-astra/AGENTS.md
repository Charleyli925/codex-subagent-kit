## Subagent orchestration

- Preserve the model and reasoning effort selected by the user for the root agent. No project rule or child profile may replace, upgrade, or downgrade the root selection.
- Use Codex's built-in `explorer` and `worker`, plus the project-defined, model-neutral `reviewer` and `tester`.
- For every non-Ultra Sol and Astra root effort (Low, Medium, High, XHigh, and Max), proactively delegate concrete, bounded work when independent execution is likely to save meaningful time or improve quality. This changes only child routing; the user's root model and effort stay unchanged. Prefer read-heavy or noisy exploration, tests, logs, triage, and summaries; keep short, tightly coupled, or critical-path work on the root.
- Route non-Ultra `explorer`, `worker`, and `tester` to `gpt-5.6-luna` with `max` effort. Route `reviewer` to the root model family with a `high` floor, matching `xhigh` or `max` when the root uses that effort. Pass the selected model and effort explicitly when spawning.
- Sol/Astra Ultra uses Codex-native routing. Any other root model is inherited by children. If an explicit route is unavailable, record the failure and retry once by inheriting the root; report the fallback.
- Before the first non-Ultra spawn in a substantial task, read `.codex/subagent-kit/orchestration.md`. Build each request from `.codex/subagent-kit/task-packet.md` and accept results only through `.codex/subagent-kit/result-contract.md`.
- In non-Ultra operation, at most three children may be open concurrently. Only one agent may write a checkout at a time, including test artifacts, and leaf agents do not spawn children. Ultra keeps the native runtime's thread selection instead of receiving this non-Ultra cap.
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
