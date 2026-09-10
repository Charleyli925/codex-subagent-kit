# Contributing

Contributions should keep the shared core portable and evidence-based.

1. Open an issue or pull request describing the behavior being changed.
2. Keep product-specific commands and policies in adapters, not the core.
3. Do not add undocumented Codex feature flags to a default preset.
4. Preserve the non-destructive installer contract.
5. Run `bash tests/test-kit.sh`.
6. Update `docs/compatibility.md` when a public Codex field or behavior changes.

Model-specific presets are welcome when they remain optional, state their
availability assumptions, and define an honest fallback.
