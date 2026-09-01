# Contributing

Daymark is intentionally narrow in scope. Contributions should preserve the project's product principles rather than expand it into a general productivity suite.

The repository is also intentionally structured for AI-assisted development across multiple sessions and agents. Continuity rules are part of the engineering process, not optional housekeeping.

## Before starting work

Read, in this order:

1. `AGENTS.md`
2. `PROJECT.md`
3. `docs/PRODUCT.md`
4. `docs/DOMAIN.md`
5. `docs/ARCHITECTURE.md`
6. `SECURITY.md`
7. `docs/WORKFLOW.md`

Then inspect the current branch, open pull request, relevant code, and tests.

Do not assume a previous chat or agent summary is newer than the repository.

## Before proposing a feature

A feature should support the Bullet Journal method, reduce mechanical friction, improve safety/reliability, or improve portability without adding unnecessary attention, configuration, or engagement mechanics.

Use the feature test in `docs/PRODUCT.md`.

Features that turn Daymark into a generic planner, dashboard, social product, configurable database, or freeform canvas require explicit product reconsideration rather than slipping in as implementation details.

## Development expectations

Changes should:

- keep domain logic independent from Flutter and platform APIs;
- include tests for domain behavior;
- preserve Linux and Android support;
- keep encrypted persistence and plaintext boundaries intact;
- avoid unnecessary dependencies and code generation;
- keep user data local by default;
- include database migration tests when schema changes;
- update documentation when behavior, architecture, security, or workflow changes;
- update `PROJECT.md` before the work is handed off.

## Git and pull requests

Follow `docs/WORKFLOW.md`.

Normal work starts from current `main` on a short-lived task branch.

Pull requests should be small enough to review and have one coherent responsibility.

Pull request titles use Conventional Commit style so squash commits remain useful, for example:

```text
feat(journal): add daily rapid logging
fix(storage): preserve migration lineage
docs: define backup format
```

AI agents must not merge pull requests unless the user explicitly requests it.

Pull requests should explain:

- what changed;
- why it belongs in Daymark;
- how it was validated;
- whether persistence, migration, export, backup, security, localization, or platform behavior is affected;
- whether `PROJECT.md` was updated.

Do not mix broad refactoring with unrelated feature work.

## Testing

Prefer behavior-focused tests and real fakes over excessive mocking.

Security-sensitive behavior must test failure paths as well as success paths.

Schema changes require migration fixtures that represent supported predecessor schemas.

A build compiling is not sufficient validation for persistence, backup, recovery, or security work.

## Dependencies

New dependencies require a concrete reason.

Before adding one:

- verify Flutter/Dart or an existing dependency cannot reasonably provide the capability;
- check current maintenance activity and published stable versions;
- check known security advisories;
- review license compatibility;
- avoid mutable Git dependencies;
- document the reason in the pull request.

Do not add packages solely to save a few lines of straightforward code or to reserve a future implementation choice before that feature exists.

Generated-code tooling has a maintenance cost. The architecture baseline currently permits Drift and Flutter localization generation and intentionally avoids additional generators until there is demonstrated need.

## Documentation and handoff

`PROJECT.md` is the canonical live handoff document.

Before stopping meaningful work, update it with:

- completed checklist items;
- newly discovered work;
- reopened work and why it was reopened;
- blockers;
- unresolved decisions;
- the next concrete action.

Do not rewrite the work log to hide changes of direction. A future contributor needs the real path, including reversals that explain the current design.
