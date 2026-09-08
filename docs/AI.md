# AI-assisted development

This is the entry point for AI tools working on Daymark.

Do not reconstruct project state from old pull-request history when the current code and tests answer the question.

## Read first

Before making product/code changes, read in this order:

1. [`README.md`](README.md)
2. [`PROJECT.md`](PROJECT.md)
3. [`DOMAIN.md`](DOMAIN.md)
4. [`ARCHITECTURE.md`](ARCHITECTURE.md)
5. the implementation/tests for the affected area
6. [`SECURITY.md`](SECURITY.md) when the change touches persistence, keys, backup, lock, signing, or private data

Use [`DEVELOPMENT.md`](DEVELOPMENT.md) for validation and [`RELEASE.md`](RELEASE.md) only for release work.

## Source-of-truth hierarchy

When information conflicts:

1. current implementation invariants and tests
2. canonical docs under `docs/`
3. current GitHub release/tag/CI evidence
4. old pull requests and commits as historical context only

Never preserve stale documentation merely because it is detailed.

## Product constraints

Daymark is a minimal local-first Bullet Journal, not a generic planner.

Preserve:

- deliberate reflection
- deliberate migration/scheduling
- historical lineage
- one real owner per Entry
- distinction between Collection ownership and Collection references
- distinction between persisted Index and read-only Search
- explicit Daymark-specific adaptations
- local-first/offline-first behavior
- encryption-at-rest guarantees
- supported Linux and Android behavior

Do not introduce accounts, cloud systems, feeds, gamification, streaks, productivity scoring, engagement loops, or broad planner abstractions without explicit maintainer direction.

## Change discipline

- inspect before editing
- prefer the smallest correct change
- do not invent architecture layers for symmetry
- do not weaken security to make tests/builds pass
- do not combine unrelated dependency, schema, security, UI, and packaging work
- keep generated files generated
- preserve historical branches unless the maintainer explicitly asks to remove them

## GitHub workflow

`main` is protected.

Use a focused branch and pull request. Squash merge is the normal default.

Do not merge, tag, publish, or delete historical branches without explicit maintainer approval.

CI may be skipped only where repository policy allows it and correctness/security are not put at risk.

## Validation

Choose validation from the affected contract, then run the full ready-PR checks when appropriate.

Typical code baseline:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Remember generation steps for localization/Drift and Wiki validation when those areas change.

## User interaction

Do as much repository work autonomously as is safe.

Stop for maintainer input when:

- merge/release promotion is required
- local physical-device behavior must be tested
- signing/private material is required
- GitHub/CI evidence is unavailable or ambiguous enough to affect a decision

When local testing is required, provide one complete, copyable command block and a concise checklist of what to verify.

## Documentation rule

Technical documentation is English and lives in `docs/`.

The user Wiki is Portuguese (Brazil) and lives in `wiki/`.

The root README is an introduction and navigation page, not a technical handoff file.
