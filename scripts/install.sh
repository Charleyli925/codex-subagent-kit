#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage: scripts/install.sh --project ABSOLUTE_PATH [--preset portable|minimal|sol-astra] [--apply]' \
    '' \
    'Default mode is a dry run. Existing active project files are never overwritten.'
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
repo_dir="$(CDPATH= cd -- "$script_dir/.." && pwd -P)"
preset="portable"
project=""
apply="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      project="$2"
      shift 2
      ;;
    --preset)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      preset="$2"
      shift 2
      ;;
    --apply)
      apply="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$preset" in
  portable|minimal|sol-astra) ;;
  *) printf 'Unknown preset: %s\n' "$preset" >&2; exit 2 ;;
esac

[ -n "$project" ] || { usage >&2; exit 2; }
[ -d "$project" ] || { printf 'Project directory does not exist: %s\n' "$project" >&2; exit 2; }
project="$(CDPATH= cd -- "$project" && pwd -P)"

payload="$project/.codex/subagent-kit"
mode="DRY RUN"
[ "$apply" = "true" ] && mode="APPLY"

printf 'Codex Subagent Kit installer\n'
printf -- '- mode: %s\n' "$mode"
printf -- '- project: %s\n' "$project"
printf -- '- preset: %s\n' "$preset"

copy_if_safe() {
  src="$1"
  dest="$2"
  label="$3"

  if [ -e "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      printf '  unchanged: %s\n' "$label"
    else
      printf '  preserved existing: %s\n' "$label"
    fi
    return
  fi

  if [ "$apply" = "true" ]; then
    mkdir -p "$(dirname -- "$dest")"
    cp "$src" "$dest"
    printf '  installed: %s\n' "$label"
  else
    printf '  would install: %s\n' "$label"
  fi
}

# Fill missing payload files; preserve different existing payloads as well.
copy_if_safe "$repo_dir/presets/$preset/config.toml" "$payload/config.toml" ".codex/subagent-kit/config.toml"
copy_if_safe "$repo_dir/presets/$preset/AGENTS.md" "$payload/AGENTS.snippet.md" ".codex/subagent-kit/AGENTS.snippet.md"
copy_if_safe "$repo_dir/core/agents/reviewer.toml" "$payload/agents/reviewer.toml" ".codex/subagent-kit/agents/reviewer.toml"
copy_if_safe "$repo_dir/core/agents/tester.toml" "$payload/agents/tester.toml" ".codex/subagent-kit/agents/tester.toml"
copy_if_safe "$repo_dir/rules/orchestration.md" "$payload/orchestration.md" ".codex/subagent-kit/orchestration.md"
copy_if_safe "$repo_dir/rules/task-packet.md" "$payload/task-packet.md" ".codex/subagent-kit/task-packet.md"
copy_if_safe "$repo_dir/rules/result-contract.md" "$payload/result-contract.md" ".codex/subagent-kit/result-contract.md"
copy_if_safe "$repo_dir/rules/lifecycle.md" "$payload/lifecycle.md" ".codex/subagent-kit/lifecycle.md"

# Activate only missing files. Existing project-owned files remain untouched.
copy_if_safe "$repo_dir/presets/$preset/config.toml" "$project/.codex/config.toml" ".codex/config.toml"
copy_if_safe "$repo_dir/core/agents/reviewer.toml" "$project/.codex/agents/reviewer.toml" ".codex/agents/reviewer.toml"
copy_if_safe "$repo_dir/core/agents/tester.toml" "$project/.codex/agents/tester.toml" ".codex/agents/tester.toml"
copy_if_safe "$repo_dir/presets/$preset/AGENTS.md" "$project/AGENTS.md" "AGENTS.md"

printf '\nActivation notes:\n'
if [ -e "$project/AGENTS.md" ] && ! cmp -s "$repo_dir/presets/$preset/AGENTS.md" "$project/AGENTS.md"; then
  printf -- '- AGENTS.md already exists. Review %s/presets/%s/AGENTS.md and merge the applicable section manually.\n' "$repo_dir" "$preset"
fi
if [ -e "$project/.codex/config.toml" ] && ! cmp -s "$repo_dir/presets/$preset/config.toml" "$project/.codex/config.toml"; then
  printf -- '- .codex/config.toml already exists. Review %s/presets/%s/config.toml and merge applicable [agents] fields manually.\n' "$repo_dir" "$preset"
fi
printf -- '- Existing payload files are also preserved. For updates, review current preset, rules and core/agents sources; see README.md#updating-an-existing-project.\n'
if [ "$apply" = "true" ]; then
  printf -- '- Start a new Codex session from the project root after activation.\n'
  printf -- '- Run: %s/scripts/doctor.sh --project %s\n' "$repo_dir" "$project"
else
  printf -- '- No files were changed. Rerun with --apply to install.\n'
fi
