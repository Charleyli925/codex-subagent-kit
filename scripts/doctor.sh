#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' 'Usage: scripts/doctor.sh --project ABSOLUTE_PATH'
}

project=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      project="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$project" ] || { usage >&2; exit 2; }
[ -d "$project" ] || { printf 'Project directory does not exist: %s\n' "$project" >&2; exit 2; }
project="$(CDPATH= cd -- "$project" && pwd -P)"

errors=0
warnings=0

ok() { printf 'ok: %s\n' "$1"; }
warn() { printf 'warning: %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'error: %s\n' "$1"; errors=$((errors + 1)); }

for relative in \
  .codex/config.toml \
  .codex/agents/reviewer.toml \
  .codex/agents/tester.toml \
  .codex/subagent-kit/orchestration.md \
  .codex/subagent-kit/task-packet.md \
  .codex/subagent-kit/result-contract.md \
  .codex/subagent-kit/lifecycle.md
do
  if [ -f "$project/$relative" ]; then
    ok "$relative exists"
  else
    fail "$relative is missing"
  fi
done

if [ -f "$project/AGENTS.md" ]; then
  if grep -q '.codex/subagent-kit/orchestration.md' "$project/AGENTS.md"; then
    ok 'AGENTS.md activates the orchestration read gate'
  else
    warn 'AGENTS.md does not reference .codex/subagent-kit/orchestration.md'
  fi
else
  fail 'AGENTS.md is missing'
fi

if grep -R -q 'multi_agent_v2' "$project/.codex/config.toml" "$project/.codex/agents" 2>/dev/null; then
  warn 'active configuration depends on multi_agent_v2, which this kit does not require'
else
  ok 'active configuration has no multi_agent_v2 dependency'
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 - "$project" <<'PY'
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
for path in [root / ".codex/config.toml", *sorted((root / ".codex/agents").glob("*.toml"))]:
    with path.open("rb") as handle:
        tomllib.load(handle)
PY
  then
    ok 'active TOML files parse successfully'
  else
    fail 'one or more active TOML files are invalid'
  fi
else
  warn 'python3 is unavailable; TOML parsing was skipped'
fi

if command -v codex >/dev/null 2>&1; then
  version="$(codex --version 2>/dev/null || true)"
  [ -n "$version" ] && ok "Codex detected: $version" || warn 'Codex command exists but version detection failed'
else
  warn 'Codex CLI was not found on PATH; desktop or IDE use may still be available'
fi

printf '\nDoctor summary: %s error(s), %s warning(s)\n' "$errors" "$warnings"
[ "$errors" -eq 0 ]
