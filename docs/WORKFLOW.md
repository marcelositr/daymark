# Development workflow

This document defines Daymark's Git, pull-request, validation, versioning, maintenance, and release process.

The purpose is consistency across human and AI contributors. Do not invent a different branch model, validation sequence, release numbering scheme, or product scope for each task.

## Product-maintenance mode

Daymark's functional product scope was frozen on 2026-09-05.

Normal development is no longer feature development. Work must be tied to preserving the existing product through:

- bug/regression fixes;
- security fixes/hardening required by a concrete risk;
- compatibility/data-migration fixes;
- dependency/toolchain/platform maintenance required for Linux/Android support;
- build/packaging/signing/CI/release fixes;
- accessibility/localization/documentation corrections that preserve existing behavior;
- narrow internal refactors necessary to make those maintenance corrections safely.

A change that introduces a new user capability or expands product scope is out of bounds unless the maintainer explicitly reverses the freeze before the work starts.

Release-stage progression does not reopen feature scope. Alpha, beta, RC, stable, and maintenance releases are validation/stability milestones.

## Branch model

Daymark uses a simple GitHub-flow-style model.

`main` is the only permanent integration branch. Do not introduce a permanent `develop` branch.

Normal work starts from an up-to-date `main` on a short-lived branch.

Branch prefixes while the product freeze is active:

- `fix/<short-description>` for defects/regressions;
- `docs/<short-description>` for documentation-only corrections;
- `refactor/<short-description>` for internal restructuring with no intended behavior expansion;
- `test/<short-description>` for test-only corrections;
- `chore/<short-description>` for tooling/dependency/maintenance/repository work;
- `ci/<short-description>` for CI-only maintenance;
- `release/<version>` only for explicitly approved release stabilization;
- `hotfix/<short-description>` for urgent published-release fixes when normal cadence is inappropriate.

`feat/*` product branches are not part of normal workflow while the product freeze is active.

Use lowercase ASCII and hyphens. Do not name branches after agents, chats, dates, or vague buckets such as `changes` or `misc`.

Completed feature/release branches are retained as historical reference/backup unless the maintainer explicitly requests removal. They are not integration lines and must not be used as the base for new normal work.

## Pull requests

Every change to `main` goes through a pull request.

A PR should have one coherent responsibility. Supporting refactors/docs required by that responsibility may be included; unrelated cleanup should not be bundled merely because it was noticed.

Draft PRs are useful when visible CI feedback reduces risk, but they are not required as the primary development runner when the maintainer has explicitly agreed to pinned local validation and that path is faster or more representative.

PR titles use Conventional Commit style so squash commits remain useful, for example:

```text
fix(storage): preserve migration lineage
fix(ui): restore search focus
docs: correct release checkpoint
chore(deps): update compatible tooling
build(release): prepare 1.0.0-alpha.3
```

### Merge method

Squash merge is the default.

Do not create routine merge commits into `main`. Rebase merge is exceptional and needs a concrete reason.

AI agents must never merge a PR unless the maintainer explicitly requests that merge.

Do not delete completed branches as routine cleanup. Preserve them unless explicit removal is requested.

## Validation ladder

Daymark uses staged validation so cheap/high-signal checks happen before expensive builds and failures are diagnosed instead of patched blindly.

### 1. Establish a trustworthy baseline

Before editing:

1. start from current `main` unless an explicit current maintenance/release branch is already the source of truth;
2. verify branch, PR state, exact head SHA, and working-tree state;
3. read `PROJECT.md` plus authoritative documents for the affected area;
4. inspect implementation/tests before assuming behavior;
5. establish what is already green and what actual defect/maintenance requirement is being addressed;
6. confirm the requested work fits the product freeze.

Do not treat a branch name, PR number, old chat, or old CI run as sufficient evidence of current state.

### 2. Choose the fastest trustworthy feedback path

Two development-feedback paths are valid:

1. **Local-first**: use the maintainer's pinned local toolchain when explicitly agreed and appropriate.
2. **Draft-CI-assisted**: use Draft CI when remote feedback is useful, local execution is unavailable, or a GitHub-only condition needs evidence.

Local-first is a normal engineering path, not a lower-confidence shortcut. It does not remove the final Ready CI/merge gate.

### 3. Generate and format before expensive checks

When applicable:

1. resolve locked dependencies;
2. run localization generation;
3. run Drift/code generation and reproducibility checks;
4. run the Dart formatter supplied by pinned Flutter;
5. run analyzer;
6. run focused tests;
7. run complete tests;
8. run relevant native builds;
9. run manual application flows when platform/lifecycle/persistence/import/export/backup behavior matters.

When ARB resources change, run `flutter gen-l10n` before analyzer/tests that compile presentation code.

Do not hand-edit around stale generated output. Do not guess formatter reflow by eye.

### Drift migration validation ordering

Migration tests depend on temporary generated migration sources. When migration validation is required:

```text
dart run build_runner build
dart run drift_dev make-migrations
flutter analyze
flutter test
```

Do not remove `test/database/migrations/daymark/generated` before analyzer/full tests that reference it. Remove temporary generated migration output only after the checks that require it are complete.

### 4. Test at the correct layer

- widget/presentation tests use controlled in-memory/fake boundaries and should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to render a screen;
- repository/session/security tests may use real temporary filesystem, cryptography, and encrypted persistence when those are the behavior under test;
- integration tests cover transitions across layers when the interaction itself is the risk;
- manual platform tests cover behavior dependent on real Linux/Android/file-provider/device environments.

For retained `StatefulShellRoute.indexedStack` navigation, regression coverage must exercise reactivation when freshness depends on it.

### 5. Treat failures as evidence

When a command/test/build/CI job fails:

1. preserve exact failure output and exit code;
2. identify the last operation definitely completed;
3. reduce with the smallest useful probe when necessary;
4. distinguish primary failure from shutdown/cancellation noise;
5. change production code only after evidence identifies a production defect;
6. fix the test when the harness is wrong;
7. remove temporary probes after diagnosis.

Repeated speculative fixes are a signal to stop and audit the slice.

Do not weaken security, persistence invariants, tests, or CI merely to turn a check green.

### 6. Manual persistence/security flows

A build compiling is not sufficient for user-data work.

When applicable, exercise the complete user path, for example:

```text
create -> capture -> lock -> wrong unlock -> correct unlock -> restart -> persistence
```

For cross-surface writes, verify immediate visibility before lock/restart.

Backup/restore, migration, clean-install, upgrade, or destructive tests use controlled/disposable data unless the maintainer explicitly chooses otherwise after understanding the risk.

If the maintainer acts as an execution bridge, commands follow `docs/LOCAL_EXECUTION.md`. The agent owns command design and diagnosis.

### 7. Documentation alignment

Before Ready:

- update `PROJECT.md` with actual state/evidence/next maintenance or release decision;
- update authoritative product/domain/architecture/security/workflow documents for durable corrections;
- update `CHANGELOG.md` for release-facing behavior;
- remove stale roadmap/feature language if the work touches a document containing it;
- remove temporary diagnostics and unrelated artifacts.

Documentation commits create a new head. Evidence from an earlier implementation head must be identified as such.

### 8. Ready CI and merge gate

A non-Draft PR runs the full merge tier:

- `quality` including generation, formatting, analysis, and complete Flutter tests;
- Linux build;
- Android build;
- dependency review;
- `merge-gate`, which requires the configured merge-tier jobs.

The exact live repository ruleset is authoritative. Local green evidence cannot replace a required status.

CI evidence is exact-head-specific.

### 9. Explicit merge decision

Green local checks and green required CI make a PR eligible for merge. They do not authorize merge.

The maintainer makes the final merge decision. AI agents must not enable auto-merge or merge implicitly.

## Before merge

Before a PR is eligible for merge:

1. branch relationship with current `main` is understood;
2. work fits the product freeze or an explicit freeze reversal is documented;
3. `PROJECT.md` reflects the work/next step;
4. relevant authoritative docs are updated;
5. formatting, analysis, tests, and required builds pass on the appropriate exact head;
6. schema changes include migrations/fixtures/tests and are permitted only when required for maintenance/compatibility;
7. security-sensitive changes document threat/compatibility impact;
8. dependency changes include rationale/security/license review;
9. no secrets, generated junk, accidental binaries, temporary diagnostics, or probe workflows are committed;
10. review conversations are resolved;
11. required `merge-gate` is green for current head;
12. maintainer explicitly approves merge.

## Versioning

Daymark uses Semantic Versioning syntax.

Release tags have a leading `v`; application version omits it:

```text
v1.0.0-alpha.2
v1.0.0-alpha.3
v1.0.0-beta.1
v1.0.0-rc.1
v1.0.0
```

Flutter's build number after `+` is separate from semantic precedence and must increase monotonically for distributable Android artifacts.

Current alpha.3 preparation uses:

```text
version: 1.0.0-alpha.3+3
```

No published release version is retagged or rewritten. A changed artifact requires a new version/build number.

Compatibility guarantees are intentionally weaker before stable, but published prerelease data compatibility remains an explicit maintenance obligation for every predecessor a new release claims to support.

## Release stages under feature freeze

### Alpha

Alpha is an end-to-end usable prerelease whose implementation may still reveal defects, compatibility problems, or release/platform gaps.

Because Daymark's product scope is now frozen, alpha is **not** permission to add missing features. Alpha work is stabilization and maintenance only.

### Beta

Beta begins when the maintainer chooses to promote the feature-complete product line after sufficient alpha validation.

Beta focuses on correctness, usability defects, migrations, portability, accessibility, security, platform behavior, and release quality. Feature expansion remains frozen.

### Release candidate

`1.0.0-rc.N` is a candidate for exact stable `1.0.0`.

Only bug/security/documentation/packaging/release-blocker corrections land. Every change is evaluated for whether another RC is required.

### Stable

`1.0.0` is published only after deliberate approval that the RC/product line has been tested sufficiently.

Stable requires release notes, version tag, GitHub Release, traceable source state, documented compatibility expectations, and the same frozen functional scope unless the maintainer explicitly changes product policy.

### Post-stable maintenance

After stable, release numbers follow actual fixes/maintenance needs. Product feature expansion remains outside normal scope.

## Release checklist

For every tagged prerelease or stable release:

1. exact source/release branch or `main` commit is known, clean, and appropriately CI-green;
2. `PROJECT.md` release gate is satisfied;
3. version/build number are correct;
4. `CHANGELOG.md` is updated/frozen for the release;
5. database migration tests cover every supported predecessor schema;
6. encrypted backup/restore compatibility is verified for supported predecessors;
7. Linux release build is produced and smoke-tested;
8. signed Android release build is produced and smoke-tested on physical hardware;
9. install-over upgrade is tested for every predecessor lineage claimed as supported, or an explicitly documented portable migration path is used when signature lineage prevents direct install-over;
10. dependency/security review is complete;
11. source tree contains no secrets/local-only files;
12. exact Ready PR head passes required CI/`merge-gate`;
13. maintainer explicitly approves merge;
14. annotated `vX.Y.Z...` tag is created only after explicit release-promotion approval;
15. GitHub Release is created from that tag and marked prerelease when applicable;
16. directly distributed artifacts have recorded SHA-256 checksums;
17. uploaded asset identity/checksums are verified;
18. `PROJECT.md` / `docs/RELEASE.md` record the published release checkpoint;
19. historical release branch is retained unless explicit removal is requested.

## Alpha.3 compatibility gate

`1.0.0-alpha.3+3` is the first public release candidate containing schema v2 and the completed post-alpha.2 product baseline.

Before publishing alpha.3, specifically prove:

- direct install-over upgrade from the public release-signed alpha.2 lineage using the same Android signing certificate;
- preservation/migration of representative alpha.2 schema-v1 journal data to schema v2;
- unlock/restart persistence after migration;
- Tracker creation/marking after migration;
- alpha.2 encrypted backup restore into alpha.3;
- Backup/Restore and Open Export behavior on alpha.3;
- Linux release bundle smoke test;
- signed Android physical-device smoke test;
- exact artifact SHA-256 checksums.

No feature work belongs in this release branch.

## Changelog policy

`CHANGELOG.md` records release-facing changes, not every development action.

Use `PROJECT.md` for implementation continuity/session handoff.

`Unreleased` contains changes meaningful to users, data compatibility, security, packaging, or contributors since the latest published release. When publishing, freeze those entries under the exact version/date and start a fresh `Unreleased` section.

## Dependency updates

Dependency updates use normal maintenance PRs and are never merged merely because a bot opened them.

For runtime/tooling dependencies as applicable, review:

- release notes/maintenance activity;
- known advisories;
- license compatibility;
- Flutter/Dart/Android/Linux compatibility;
- lockfile changes;
- relevant tests/builds.

Do not add a dependency solely to create a new capability under the frozen product scope.

## Post-release rule

After publication:

1. verify tag, release metadata, and distributed assets;
2. keep the published tag/assets immutable;
3. record exact release source and artifact identity in `PROJECT.md` / `docs/RELEASE.md`;
4. return maintenance work to current `main`;
5. do not infer a feature backlog or next feature scope from release completion.
