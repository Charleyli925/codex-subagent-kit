#!/usr/bin/env bash
set -euo pipefail

test_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
repo_dir="$(CDPATH= cd -- "$test_dir/.." && pwd -P)"
temp_root="$(mktemp -d "${TMPDIR:-/tmp}/codex-subagent-kit.XXXXXX")"
trap 'rm -rf "$temp_root"' EXIT INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

printf 'Parsing TOML files...\n'
python3 - "$repo_dir" <<'PY'
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
paths = sorted(root.glob("core/agents/*.toml")) + sorted(root.glob("presets/*/config.toml"))
assert paths, "no TOML files discovered"
for path in paths:
    with path.open("rb") as handle:
        value = tomllib.load(handle)
    if "agents" in value:
        assert value["agents"].get("enabled") is True
    else:
        for key in ("name", "description", "developer_instructions"):
            assert value.get(key), f"{path}: missing {key}"
PY

if grep -R -n 'multi_agent_v2' "$repo_dir/core" "$repo_dir/presets"; then
  fail 'core or preset depends on multi_agent_v2'
fi

printf 'Checking user-facing documentation contracts...\n'
grep -q 'only two custom agent TOML files' "$repo_dir/README.md" || fail 'README does not explain built-in versus custom roles'
grep -q 'Codex already provides' "$repo_dir/README.md" || fail 'README does not separate native runtime from kit policy'
grep -q 'Ultra passes through' "$repo_dir/README.md" || fail 'README does not explain the Ultra pass-through decision'
grep -q 'Every non-Ultra Sol/Astra effort' "$repo_dir/README.md" || fail 'README does not explain non-Ultra routing scope'
grep -q '可以增加自己的 Agent 吗' "$repo_dir/README.zh-CN.md" || fail 'Chinese README lacks custom-agent guidance'
if grep -q 'max_concurrent_threads_per_session' "$repo_dir/presets/sol-astra/config.toml"; then
  fail 'sol-astra config applies a global thread cap to Ultra'
fi
grep -q "Ultra keeps the native runtime's thread selection" "$repo_dir/presets/sol-astra/AGENTS.md" || fail 'sol-astra preset does not preserve native Ultra thread selection'

python3 - "$repo_dir" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
missing = []
for source in root.rglob("*.md"):
    for target in re.findall(r"\[[^]]+\]\(([^)]+)\)", source.read_text()):
        if target.startswith(("http://", "https://", "#")):
            continue
        destination = (source.parent / target.split("#", 1)[0]).resolve()
        if not destination.exists():
            missing.append(f"{source.relative_to(root)} -> {target}")
assert not missing, "missing relative Markdown links:\n" + "\n".join(missing)
PY

clean_project="$temp_root/clean-project"
mkdir -p "$clean_project"

printf 'Checking dry run...\n'
"$repo_dir/scripts/install.sh" --preset portable --project "$clean_project" >/dev/null
[ ! -e "$clean_project/.codex" ] || fail 'dry run created .codex'
[ ! -e "$clean_project/AGENTS.md" ] || fail 'dry run created AGENTS.md'

printf 'Checking clean installation...\n'
"$repo_dir/scripts/install.sh" --preset portable --project "$clean_project" --apply >/dev/null
for relative in \
  AGENTS.md \
  .codex/config.toml \
  .codex/agents/reviewer.toml \
  .codex/agents/tester.toml \
  .codex/subagent-kit/orchestration.md \
  .codex/subagent-kit/task-packet.md \
  .codex/subagent-kit/result-contract.md \
  .codex/subagent-kit/lifecycle.md
do
  [ -f "$clean_project/$relative" ] || fail "clean install missing $relative"
done
"$repo_dir/scripts/doctor.sh" --project "$clean_project" >/dev/null

printf 'Checking preservation of existing project files...\n'
existing_project="$temp_root/existing-project"
mkdir -p "$existing_project/.codex/agents"
printf '%s\n' 'existing agents guidance' > "$existing_project/AGENTS.md"
printf '%s\n' '[project]' 'name = "existing"' > "$existing_project/.codex/config.toml"
printf '%s\n' 'name = "reviewer"' 'description = "existing"' 'developer_instructions = "existing"' > "$existing_project/.codex/agents/reviewer.toml"
agents_before="$(cksum "$existing_project/AGENTS.md")"
config_before="$(cksum "$existing_project/.codex/config.toml")"
reviewer_before="$(cksum "$existing_project/.codex/agents/reviewer.toml")"

"$repo_dir/scripts/install.sh" --preset sol-astra --project "$existing_project" --apply >/dev/null
[ "$(cksum "$existing_project/AGENTS.md")" = "$agents_before" ] || fail 'existing AGENTS.md was overwritten'
[ "$(cksum "$existing_project/.codex/config.toml")" = "$config_before" ] || fail 'existing config.toml was overwritten'
[ "$(cksum "$existing_project/.codex/agents/reviewer.toml")" = "$reviewer_before" ] || fail 'existing reviewer.toml was overwritten'
[ -f "$existing_project/.codex/agents/tester.toml" ] || fail 'missing non-conflicting tester activation'
[ -f "$existing_project/.codex/subagent-kit/AGENTS.snippet.md" ] || fail 'missing reviewable AGENTS snippet'
grep -q 'gpt-6-astra' "$existing_project/.codex/subagent-kit/AGENTS.snippet.md" || fail 'wrong preset payload installed'

printf 'All Codex Subagent Kit checks passed.\n'
