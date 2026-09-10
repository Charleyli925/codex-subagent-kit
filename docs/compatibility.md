# Compatibility

Last reviewed: 2026-09-11.

## Public configuration surface

This kit follows the current public Codex subagent documentation and uses:

- `[agents].enabled`;
- `[agents].max_concurrent_threads_per_session`;
- `[agents].interrupt_message`;
- project-scoped `.codex/agents/*.toml` files;
- custom-agent `name`, `description`, `developer_instructions`, and
  `sandbox_mode` fields;
- explicit or inherited `model` and `model_reasoning_effort` at spawn time.

The portable and minimal presets do not require any named model. The Sol/Astra
preset requires the selected models and reasoning efforts to be available to the
current account and client.

## Deliberately excluded

The kit does not set `[features].multi_agent_v2`. Current public documentation
describes subagent workflows as enabled by default and documents `[agents]` as
the supported configuration surface. An environment may expose additional
internal or legacy flags, but the portable contract does not rely on them.

## Runtime verification

Static validation cannot prove which model a hosted or local child actually
used. When client or session metadata is available, the parent should compare it
with the expected route. When it is not visible, report `unverified` rather than
claiming the route was proven.

Custom-agent authoring and sharing may evolve. Recheck the official documentation
after upgrading Codex, and keep compatibility claims tied to a review date.

Official reference:
<https://learn.chatgpt.com/docs/agent-configuration/subagents>
