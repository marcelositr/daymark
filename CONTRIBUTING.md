# Contributing

Daymark is intentionally narrow in scope. Contributions should preserve the project's product principles rather than expand it into a general productivity suite.

## Before proposing a feature

Read:

- `docs/PRODUCT.md`
- `docs/ARCHITECTURE.md`
- `SECURITY.md`

A feature should support the Bullet Journal method, reduce mechanical friction, or improve reliability without adding unnecessary attention, configuration, or engagement mechanics.

## Development expectations

Once the Flutter scaffold exists, changes should:

- keep domain logic independent from platform APIs;
- include tests for domain behavior;
- preserve Linux and Android support;
- avoid unnecessary dependencies;
- keep user data local by default;
- update documentation when behavior or architecture changes.

## Pull requests

Prefer small, reviewable pull requests with one clear responsibility.

Pull requests should explain:

- what changed;
- why it belongs in Daymark;
- how it was validated;
- whether persistence, migration, export, or platform behavior is affected.

Do not mix broad refactoring with unrelated feature work.

## Dependencies

New dependencies require a concrete reason. Prefer standard library and existing project capabilities when they are sufficient.

Do not add packages solely to save a few lines of straightforward code.
