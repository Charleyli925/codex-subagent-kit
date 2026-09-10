# Security policy

Please report security-sensitive installer or configuration issues privately
through GitHub's security advisory flow for this repository.

The installer is intentionally local and non-destructive:

- dry-run is the default;
- existing active project files are not overwritten;
- it does not execute downloaded project code;
- it does not read credentials, personal application data, or Codex session
  contents;
- it does not modify global `~/.codex` configuration.

Review scripts before running them in a sensitive environment. Subagents inherit
the permissions and tools available in the parent environment unless the current
Codex runtime applies a narrower custom-agent setting.
