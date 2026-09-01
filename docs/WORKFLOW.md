# Development workflow

This document defines the common Git, pull request, versioning, and release process for Daymark.

The purpose is consistency across human and AI contributors. Agents must not invent a different branch model or release numbering scheme for each task.

## Branch model

Daymark uses a simple GitHub-flow-style model.

`main` is the only permanent integration branch.

Do not introduce a permanent `develop` branch. The project is small enough that a second long-lived integration branch would add coordination cost without adding safety.

Normal work happens on short-lived branches created from an up-to-date `main`.

### Branch names

Use one of these prefixes:

- `feat/<short-description>` for user-visible functionality;
- `fix/<short-description>` for defects;
- `docs/<short-description>` for documentation-only work;
- `refactor/<short-description>` for internal restructuring without intended behavior change;
- `test/<short-description>` for test-only work;
- `chore/<short-description>` for tooling, maintenance, CI, and repository work;
- `release/<version>` only when a dedicated release-stabilization branch is explicitly needed;
- `hotfix/<short-description>` only after stable releases exist and an urgent stable fix cannot follow the normal cadence.

Use lowercase ASCII and hyphens. Add an issue number when a real issue exists and the number improves traceability.

Examples:

```text
feat/daily-rapid-logging
fix/migration-lineage
security is expressed as fix/security-... or feat/security-... according to the actual change
docs/backup-format
chore/flutter-scaffold
```

Do not create branches named after agents, chat sessions, dates, or vague buckets such as `changes`, `updates`, or `misc`.

## Pull requests

Every change to `main` goes through a pull request.

A pull request should have one coherent responsibility. Small supporting refactors or documentation required by that responsibility may be included, but unrelated cleanup should not be bundled merely because an agent noticed it.

Draft PRs are acceptable for incomplete work that benefits from visible CI or review.

### PR title

Use Conventional Commit style so the squash commit has a useful history:

```text
feat(journal): add daily rapid logging
fix(storage): preserve migration lineage
refactor(domain): separate task state from entry type
docs: define backup format
chore(ci): add Flutter quality gates
```

Preferred types are:

- `feat`
- `fix`
- `refactor`
- `docs`
- `test`
- `chore`
- `build`
- `ci`
- `perf`
- `revert`

### Merge method

Squash merge is the default.

Reasons:

- one PR becomes one understandable `main` commit;
- agent scratch commits do not pollute permanent history;
- revert and bisect behavior stays understandable;
- PR discussion remains available for detailed history.

Do not create routine merge commits into `main`.

Rebase merge may be used only when preserving individually reviewed commits has a concrete benefit.

Delete the task branch after successful merge unless an explicit reason requires keeping it.

AI agents must never merge a PR unless the user explicitly requests the merge.

## Before merge

Before a PR is eligible for merge:

1. the branch is based on a current enough `main` that conflicts and migration interactions are understood;
2. `PROJECT.md` reflects the work and next step;
3. relevant product/domain/security/architecture documentation is updated;
4. formatting, analysis, tests, and required builds pass;
5. schema changes include migrations and migration tests;
6. security-sensitive changes include their threat-model impact;
7. dependency changes include a concrete rationale and security/license review;
8. no secrets, generated junk, build artifacts, or accidental binaries are committed;
9. review conversations are resolved.

Once CI exists, the main-branch ruleset should require the actual stable check names rather than guessed placeholders.

## Versioning

Daymark uses Semantic Versioning syntax for releases and tags.

Release tags use a leading `v`:

```text
v1.0.0-alpha.1
v1.0.0-alpha.2
v1.0.0-beta.1
v1.0.0-rc.1
v1.0.0
```

The application version itself omits the leading `v`.

The build number after `+` in Flutter's version field is separate from semantic precedence and must increase monotonically for distributable Android artifacts.

Example:

```text
version: 1.0.0-alpha.1+1
```

### Why prereleases target 1.0.0 directly

The first public release train is the path to the first stable `1.0.0`. Using the same base version makes ordering unambiguous:

```text
1.0.0-alpha.1
< 1.0.0-alpha.2
< 1.0.0-beta.1
< 1.0.0-rc.1
< 1.0.0
```

Compatibility guarantees are intentionally weaker during prerelease stages. Stable compatibility policy begins with `1.0.0` and must then be documented precisely.

No release version is ever retagged or rewritten after publication. A changed artifact requires a new version.

## Release stages

### Alpha

Alpha is for incomplete but end-to-end usable builds.

Alpha may include:

- missing v1 features;
- schema changes;
- UI changes;
- breaking prerelease behavior;
- security model refinement when migration is explicitly handled.

An alpha must still protect user data according to the currently documented security model. `alpha` is not permission to store sensitive data in plaintext or skip migration safety.

### Beta

Beta begins when the intended v1 core scope is feature-complete.

During beta:

- focus shifts to correctness, usability, migrations, portability, accessibility, and platform behavior;
- large architectural redesign requires exceptional justification;
- data-loss and security defects block promotion.

### Release candidate

RC means the build is a candidate for the exact stable version named in the version number.

For `1.0.0-rc.N`:

- v1 features are frozen;
- only bug fixes, security fixes, documentation corrections, packaging corrections, and release blockers should land;
- every change must be evaluated for whether it requires another RC;
- the release candidate must be tested with real upgrade, backup, restore, Linux, and Android scenarios.

There is no automatic time-based promotion from RC to stable.

### Stable

`1.0.0` is published only after deliberate approval that the RC line has been tested sufficiently.

Stable releases require release notes, a version tag, a GitHub Release, reproducible source state, and documented compatibility expectations.

## Release checklist

For every tagged prerelease or stable release:

1. `main` or the explicit release branch is clean and CI-green;
2. `PROJECT.md` release gate is satisfied for the target stage;
3. version and build number are correct;
4. `CHANGELOG.md` is updated;
5. database migration tests pass against all supported predecessor fixtures;
6. encrypted backup/restore compatibility is verified for supported predecessors;
7. Linux release build is produced and smoke-tested;
8. Android release build is produced and smoke-tested on physical hardware;
9. dependency/security review is complete;
10. source tree contains no secrets or local-only files;
11. an annotated `vX.Y.Z...` tag is created from the exact approved commit;
12. GitHub Release is created from that tag and marked prerelease when applicable;
13. release artifacts are checksummed when artifacts are distributed directly;
14. `PROJECT.md` records the released version and next development state.

## Changelog policy

`CHANGELOG.md` records release-facing changes, not every development action.

Use `PROJECT.md` for implementation continuity and session handoff.

The `Unreleased` section should contain changes meaningful to users, data compatibility, security, packaging, or contributors. Internal scratch work does not need changelog entries.

## Dependency updates

Dependency updates use normal PRs and must not be merged merely because a bot opened them.

For runtime dependencies, review:

- release notes;
- breaking changes;
- security advisories;
- transitive dependency changes;
- license changes;
- platform support;
- persistence/backup compatibility when relevant.

The committed lockfile is authoritative for resolved package versions.

## Emergency fixes after 1.0

After stable releases exist, a critical security or data-loss fix may use a `hotfix/` branch from the affected stable line when fixing `main` alone cannot protect released users quickly enough.

Any hotfix must also be reconciled back into `main`. Do not let stable and main silently diverge.
