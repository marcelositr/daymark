# Contributing

Daymark is deliberately small in scope. Contributions should improve the existing product without turning it into a generic productivity platform.

## Before changing code

Read:

- [`PROJECT.md`](PROJECT.md)
- [`DOMAIN.md`](DOMAIN.md)
- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`SECURITY.md`](SECURITY.md) for security-sensitive work

For AI-assisted work, also read [`AI.md`](AI.md).

## Change scope

Good maintenance changes include:

- bug and regression fixes
- method-fidelity corrections
- security fixes and hardening
- schema/compatibility fixes
- accessibility and localization corrections
- Linux/Android compatibility and packaging maintenance
- documentation corrections

Material product-scope expansion requires an explicit maintainer decision before implementation.

## Pull requests

Keep pull requests focused and reviewable.

A PR should explain:

- what problem it solves
- what behavior changes
- what compatibility/security boundaries are affected
- how it was tested

Avoid unrelated refactors or dependency churn in a behavioral/security fix.

## Validation

Run the relevant local checks described in [`DEVELOPMENT.md`](DEVELOPMENT.md).

Ready PRs are expected to pass the repository merge gate, including tests, Linux build validation, Android debug build, and dependency review where applicable.

## Database changes

Schema changes require:

- schema version increment
- explicit migration step
- regenerated Drift migration snapshots
- upgrade tests

Never replace a user database to avoid implementing a migration.

## Security-sensitive changes

Changes involving cryptography, keys, backup authentication, restore semantics, journal locking, signing, or private material require focused failure-path tests and explicit review.

Never commit private Android signing material.

## Documentation

Technical documentation is English and belongs under `docs/`.

The root `README.md` presents the project and should remain concise.

The user Wiki is Portuguese (Brazil) and its versioned source lives under `wiki/`.

## Merge and release

The maintainer controls merge, tags, and releases. Passing CI is necessary validation, not permission to promote a change.
