# Example project guidance

Follow the installed Subagent Kit rules. Before the first substantial spawn,
read `.codex/subagent-kit/orchestration.md`.

## Project adapter

- Before implementation, read `docs/architecture.md` and only the component
  contract relevant to the requested change.
- The tester runs the project's existing test command against frozen source; it
  does not modify tests or dependencies.
- The reviewer receives the acceptance goal, actual diff, relevant source, and
  `docs/architecture.md` through `required_reading`.
- Implementation may create a tested branch. Commit, push, pull-request, merge,
  install, and release permissions remain separate user decisions unless this
  project's own policy says otherwise.
