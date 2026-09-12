#!/usr/bin/env bash
set -euo pipefail

test_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
repo_dir="$(CDPATH= cd -- "$test_dir/.." && pwd -P)"
temp_root="$(mktemp -d "${TMPDIR:-/tmp}/codex-subagent-kit.XXXXXX")"
trap 'rm -rf "$temp_root"' EXIT INT TERM

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

printf 'Checking model-neutral roles, presets and source references...\n'
python3 - "$repo_dir" <<'PY'
import pathlib
import re
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
profiles = {}
for path in sorted((root / "core/agents").glob("*.toml")):
    value = tomllib.loads(path.read_text())
    for key in ("name", "description", "developer_instructions"):
        assert value.get(key), f"{path}: missing {key}"
    assert "model" not in value and "model_reasoning_effort" not in value
    assert value["name"] == path.stem
    profiles[value["name"]] = value
assert set(profiles) == {"reviewer", "tester"}, "built-in roles must not be shadowed"
assert profiles["reviewer"]["sandbox_mode"] == "read-only"
assert profiles["tester"]["sandbox_mode"] == "workspace-write"

for name, cap in (("portable", 3), ("minimal", 2), ("sol-astra", None)):
    value = tomllib.loads((root / "presets" / name / "config.toml").read_text())
    assert "features" not in value
    assert value["agents"]["enabled"] is True
    if cap is None:
        assert "max_concurrent_threads_per_session" not in value["agents"]
    else:
        assert value["agents"]["max_concurrent_threads_per_session"] == cap
    assert "max_threads" not in value["agents"]
    assert "default_subagent_model" not in value["agents"]
    assert "default_subagent_reasoning_effort" not in value["agents"]

# The alignment table is routing data, not a prose/style test.
route = (root / "presets/sol-astra/AGENTS.md").read_text()
rows = [tuple(part.strip() for part in line.strip("|").split("|"))
        for line in route.splitlines() if line.startswith("|")]
assert dict(rows[2:]) == {
    "Sol Low, Medium, or High": "`gpt-5.6-sol` / `high`",
    "Sol XHigh": "`gpt-5.6-sol` / `xhigh`",
    "Sol Max": "`gpt-5.6-sol` / `max`",
    "Astra Low, Medium, or High": "`gpt-6-astra` / `high`",
    "Astra XHigh": "`gpt-6-astra` / `xhigh`",
    "Astra Max": "`gpt-6-astra` / `max`",
    "Sol or Astra Ultra": "Codex-native routing",
    "Any other root": "Inherit root model and effort",
}
for source in root.rglob("*.md"):
    if ".git" in source.parts:
        continue
    for target in re.findall(r"\[[^]]+\]\(([^)]+)\)", source.read_text()):
        if target.startswith(("http://", "https://", "#")):
            continue
        assert (source.parent / target.split("#", 1)[0]).exists(), f"{source}: {target}"
PY

for preset in portable minimal sol-astra; do
  project="$temp_root/$preset project"
  mkdir -p "$project"
  printf 'Checking %s dry run, installation and installed read gates...\n' "$preset"
  "$repo_dir/scripts/install.sh" --preset "$preset" --project "$project" >/dev/null
  [ -z "$(ls -A "$project")" ] || fail "$preset dry run wrote files"
  "$repo_dir/scripts/install.sh" --preset "$preset" --project "$project" --apply >/dev/null
  python3 - "$repo_dir" "$project" "$preset" <<'PY'
import pathlib
import re
import sys
kit, project = map(pathlib.Path, sys.argv[1:3])
preset = sys.argv[3]
payload = project / ".codex/subagent-kit"
pairs = [
    (kit / f"presets/{preset}/AGENTS.md", project / "AGENTS.md"),
    (kit / f"presets/{preset}/AGENTS.md", payload / "AGENTS.snippet.md"),
    (kit / f"presets/{preset}/config.toml", project / ".codex/config.toml"),
    (kit / f"presets/{preset}/config.toml", payload / "config.toml"),
]
for src in (kit / "core/agents").glob("*.toml"):
    pairs += [(src, project / ".codex/agents" / src.name),
              (src, payload / "agents" / src.name)]
for src in (kit / "rules").glob("*.md"):
    pairs.append((src, payload / src.name))
for src, dst in pairs:
    assert dst.read_bytes() == src.read_bytes(), f"wrong payload: {dst}"
assert {p.stem for p in (project / ".codex/agents").glob("*.toml")} == {"reviewer", "tester"}
entry = (project / "AGENTS.md").read_text()
references = re.findall(r"`(\.codex/subagent-kit/[^\x60]+\.md)`", entry)
assert {pathlib.Path(r).name for r in references} >= {
    "orchestration.md", "task-packet.md", "result-contract.md"}
for ref in references:
    assert (project / ref).is_file(), f"broken installed read gate: {ref}"
for source in payload.glob("*.md"):
    for target in re.findall(r"\[[^]]+\]\(([^)]+)\)", source.read_text()):
        if not target.startswith(("http://", "https://", "#")):
            assert (source.parent / target.split("#", 1)[0]).exists(), target
PY
  "$repo_dir/scripts/doctor.sh" --project "$project" >/dev/null

  # Repeated installation cannot change active files OR a customized old payload.
  printf 'Checking %s update preservation...\n' "$preset"
  printf '\nlocal project customization\n' >> "$project/AGENTS.md"
  printf '\n# local reviewer customization\n' >> "$project/.codex/agents/reviewer.toml"
  printf '\n# local tester customization\n' >> "$project/.codex/agents/tester.toml"
  printf '\n# local configuration\n' >> "$project/.codex/config.toml"
  printf '\nold local handoff customization\n' >> "$project/.codex/subagent-kit/task-packet.md"
  printf '\nold local snippet\n' >> "$project/.codex/subagent-kit/AGENTS.snippet.md"
  before="$(cd "$project" && find . -type f -exec cksum {} \; | LC_ALL=C sort)"
  "$repo_dir/scripts/install.sh" --preset "$preset" --project "$project" >/dev/null
  [ "$(cd "$project" && find . -type f -exec cksum {} \; | LC_ALL=C sort)" = "$before" ] || fail 'existing-project dry run wrote files'
  "$repo_dir/scripts/install.sh" --preset "$preset" --project "$project" --apply >/dev/null
  [ "$(cd "$project" && find . -type f -exec cksum {} \; | LC_ALL=C sort)" = "$before" ] || fail 'update overwrote active files or existing payload'
done

printf 'Checking first adoption with pre-existing project files...\n'
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
cmp -s "$repo_dir/core/agents/tester.toml" "$existing_project/.codex/agents/tester.toml" || fail 'missing non-conflicting tester'
cmp -s "$repo_dir/presets/sol-astra/AGENTS.md" "$existing_project/.codex/subagent-kit/AGENTS.snippet.md" || fail 'missing current reviewable snippet'

printf 'All Codex Subagent Kit checks passed (static/install contracts; no live model-quality claim).\n'
