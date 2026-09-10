# Codex Subagent Kit

[![CI](https://github.com/Charleyli925/codex-subagent-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/Charleyli925/codex-subagent-kit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

A portable, project-scoped subagent workflow for Codex: narrow roles, explicit
routing, bounded parallelism, progressive disclosure, and evidence-based result
acceptance.

This repository turns a working multi-agent setup into a reusable kit without
copying product-specific delivery rules into every project.

> Independent community project. It is not an official OpenAI repository.

[中文说明](README.zh-CN.md)

## What it includes

- Codex's built-in `explorer` and `worker` roles.
- Model-neutral custom `reviewer` and `tester` roles.
- A portable preset that inherits the root agent's model and reasoning effort.
- An optional Sol/Astra routing preset.
- A minimal preset for teams that prefer explicit delegation.
- Task-packet, lifecycle, dependency-wave, and result-acceptance contracts.
- A non-destructive installer and a local diagnostic command.

The kit keeps role and model selection separate. A role says what an agent does;
a preset says which model and reasoning effort it should use.

## Requirements

- A current local Codex client with subagent support.
- Bash 3.2 or newer for installation.
- Python 3.11 or newer for `doctor.sh` TOML validation and repository tests.

## Quick start

Clone the repository, preview the installation, then apply it to a project:

```bash
git clone https://github.com/Charleyli925/codex-subagent-kit.git
cd codex-subagent-kit
./scripts/install.sh --preset portable --project /absolute/path/to/project
./scripts/install.sh --preset portable --project /absolute/path/to/project --apply
./scripts/doctor.sh --project /absolute/path/to/project
```

The installer never overwrites an existing `AGENTS.md`, `.codex/config.toml`,
`reviewer.toml`, or `tester.toml`. When one already exists, it installs a
reviewable source copy under `.codex/subagent-kit/` and prints the manual merge
step.

Start a new Codex session from the project root after installation. Codex loads
project-scoped agents when the session starts.

## Presets

| Preset | Delegation | Model routing | Best for |
| --- | --- | --- | --- |
| `portable` | Proactive when parallel work materially helps | Children inherit the root unless explicitly overridden | Most projects |
| `sol-astra` | Proactive below Ultra; native Ultra behavior | Luna Max for exploration/work/tests; aligned Sol/Astra reviewer | The opinionated routing used by the originating workflow |
| `minimal` | Direct request or clearly independent lanes | Inherit the root | Small repositories and cautious adoption |

The portable preset is the default because model availability varies by account,
client, and time. The Sol/Astra preset is optional and documents its fallback.

## Roles

| Role | Source | Permission intent | Responsibility |
| --- | --- | --- | --- |
| `explorer` | Built into Codex | Read-heavy | Trace files, execution paths, state, and risks |
| `worker` | Built into Codex | Workspace write | Implement one bounded change |
| `reviewer` | This kit | Read-only | Independently find correctness, regression, and test risks |
| `tester` | This kit | Workspace write | Run existing tests and collect evidence without editing source |

The parent agent remains responsible for authorization, routing, conflict
avoidance, steering, integration, and final acceptance.

## Installed files

For a clean project, installation activates:

```text
AGENTS.md
.codex/config.toml
.codex/agents/reviewer.toml
.codex/agents/tester.toml
.codex/subagent-kit/
```

The `.codex/subagent-kit/` directory contains the selected preset and the
progressively disclosed operating contracts. It is also the source used for
manual merging when a project already owns one of the active files.

## Why progressive disclosure

The root `AGENTS.md` stays short. It tells the root agent when delegation is
appropriate and points to `.codex/subagent-kit/orchestration.md` before the first
subagent spawn in a substantial task. Each child receives only a self-contained
task packet plus its task-specific `required_reading` list.

This keeps exploration logs, test output, and detailed coordination rules out of
the main context until they are needed.

## Sol/Astra routing

The optional preset uses this policy below Ultra:

| Root selection | `explorer` / `worker` / `tester` | `reviewer` |
| --- | --- | --- |
| Sol Low, Medium, or High | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `high` |
| Sol XHigh | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `xhigh` |
| Sol Max | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `max` |
| Astra Low, Medium, or High | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `high` |
| Astra XHigh | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `xhigh` |
| Astra Max | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `max` |
| Sol or Astra Ultra | Codex-native routing | Codex-native routing |
| Any other root | Inherit root | Inherit root |

The custom role files intentionally do not pin models. Dynamic reviewer
alignment is a parent-agent routing decision made at spawn time.

## Safety properties

- At most three open child threads by default.
- Only one agent writes a checkout at a time, including test artifacts.
- Read-only tasks may run in parallel against frozen source.
- Leaf agents do not spawn more agents.
- Child summaries are leads, not acceptance proof.
- A route mismatch blocks acceptance of child code changes.
- Delegation never expands the user's authorization.
- Existing project configuration is never overwritten by the installer.

## Validation

Run the repository checks:

```bash
bash tests/test-kit.sh
```

The checks parse every TOML file, exercise clean and preconfigured project
installation, verify dry-run behavior, and reject undocumented
`multi_agent_v2` dependencies.

## Compatibility

The kit follows the public Codex subagent configuration documented at
<https://learn.chatgpt.com/docs/agent-configuration/subagents>.

It uses `[agents]`, `.codex/agents/*.toml`, `model`,
`model_reasoning_effort`, and `sandbox_mode`. It intentionally does not require
`[features].multi_agent_v2`. Custom-agent authoring and sharing may evolve, so
runtime compatibility is tracked in [docs/compatibility.md](docs/compatibility.md).

## Project adapters

Product-specific test commands, release rules, architecture contracts, and
approval policies do not belong in the shared core. Add them to the consuming
project's `AGENTS.md` and pass the relevant paths through each task packet's
`required_reading` field.

See [adapters/example-project/AGENTS.md](adapters/example-project/AGENTS.md) for
a small example.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
