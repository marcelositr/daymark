# Development workflow

This document defines Daymark's common Git, pull-request, validation, versioning, and release process.

The purpose is consistency across human and AI contributors. Do not invent a different branch model, validation sequence, or release numbering scheme for each task.

## Branch model

Daymark uses a simple GitHub-flow-style model.

`main` is the only permanent integration branch. Do not introduce a permanent `develop` branch.

Normal work starts from an up-to-date `main` on a short-lived branch.

Branch prefixes:

- `feat/<short-description>` for user-visible functionality;
- `fix/<short-description>` for defects;
- `docs/<short-description>` for documentation-only work;
- `refactor/<short-description>` for internal restructuring without intended behavior change;
- `test/<short-description>` for test-only work;
- `chore/<short-description>` for tooling/maintenance/repository work;
- `release/<version>` only when a dedicated release-stabilization branch is explicitly needed;
- `hotfix/<short-description>` only after stable releases exist and an urgent stable fix cannot follow the normal cadence.

Use lowercase ASCII and hyphens. Do not name branches after agents, chats, dates, or vague buckets such as `changes` or `misc`.

A completed release branch is not a second integration line. After its release is merged/published and evidence is recorded, remove it when no longer needed for reference and return new work to current `main`.

## Pull requests

Every change to `main` goes through a pull request.

A PR should have one coherent responsibility. Supporting refactors/docs required by that responsibility may be included; unrelated cleanup should not be bundled merely because it was noticed.

Draft PRs are useful when visible CI feedback reduces risk, but they are not required as the primary development runner when the user has explicitly agreed to pinned local validation and that path is faster/more representative.

PR titles use Conventional Commit style so squash commits remain useful, for example:

```text
feat(journal): add daily rapid logging
fix(storage): preserve migration lineage
docs: align release handoff
build(release): prepare 1.0.0-alpha.3
```

Preferred types include `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, `ci`, `perf`, and `revert`.

### Merge method

Squash merge is the default.

Do not create routine merge commits into `main`. Rebase merge is exceptional and needs a concrete reason to preserve individually reviewed commits.

AI agents must never merge a PR unless the user explicitly requests that merge.

Delete a completed task/release branch after successful merge when it is no longer needed for a deliberate reference purpose.

## Validation ladder

Daymark uses staged validation so cheap/high-signal checks happen before expensive builds and failures are diagnosed instead of patched blindly.

### 1. Establish a trustworthy baseline

Before editing:

1. start from current `main` unless an explicit current task branch is already the source of truth;
2. verify branch, PR state, exact head SHA, and working-tree state;
3. read `PROJECT.md` plus authoritative documents for the affected area;
4. inspect implementation/tests before assuming behavior;
5. establish what is already green and what requirement/failure is actually being addressed.

Do not treat a branch name, PR number, old chat, or old CI run as sufficient evidence of current state.

### 2. Choose the fastest trustworthy feedback path

Two development-feedback paths are valid:

1. **Local-first**: use the user's pinned local toolchain when explicitly agreed and appropriate. This is often fastest for Flutter tests/builds and real hardware validation.
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

### 4. Test at the correct layer

- widget/presentation tests use controlled in-memory/fake boundaries and should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to render a screen;
- repository/session/security tests may use real temporary filesystem, cryptography, and encrypted persistence when those are the behavior under test;
- integration tests cover transitions across layers when the interaction itself is the risk;
- manual platform tests cover behavior dependent on real Linux/Android/file-provider/device environments.

For retained `StatefulShellRoute.indexedStack` navigation, regression coverage must exercise reactivation when freshness depends on it. A remount-only test can hide the real bug.

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

Backup/restore, migration, clean-install, upgrade, or destructive tests use controlled/disposable data unless the user explicitly chooses otherwise after understanding the risk.

If the user acts as an execution bridge, commands follow `docs/LOCAL_EXECUTION.md`. The agent owns command design and diagnosis.

### 7. Documentation alignment

Before Ready:

- update `PROJECT.md` with actual state/evidence/next decision;
- update authoritative product/domain/architecture/security/workflow documents for durable changes;
- update `CHANGELOG.md` for release-facing behavior;
- remove temporary diagnostics and unrelated artifacts.

Documentation commits create a new head. Evidence from an earlier implementation head must be identified as such; do not silently call older SHA-specific validation the final head.

### 8. Ready CI and merge gate

A non-Draft PR runs the full merge tier:

- `quality` including generation, formatting, analysis, and complete Flutter tests;
- Linux build;
- Android build;
- dependency review;
- `merge-gate`, which requires the configured merge-tier jobs.

The exact live repository ruleset is authoritative. Local green evidence cannot replace a required status.

CI evidence is exact-head-specific. A superseded green run does not validate a newer documentation/code head.

### 9. Explicit merge decision

Green local checks and green required CI make a PR eligible for merge. They do not authorize merge.

The user makes the final merge decision. AI agents must not enable auto-merge or merge implicitly.

## Before merge

Before a PR is eligible for merge:

1. branch relationship with current `main` is understood;
2. `PROJECT.md` reflects the work/next step;
3. relevant authoritative docs are updated;
4. formatting, analysis, tests, and required builds pass on the appropriate exact head;
5. schema changes include migrations/fixtures/tests;
6. security-sensitive changes document threat/compatibility impact;
7. dependency changes include rationale/security/license review;
8. no secrets, generated junk, accidental binaries, temporary diagnostics, or probe workflows are committed;
9. review conversations are resolved;
10. required `merge-gate` is green for current head;
11. user explicitly approves merge.

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

Example:

```text
version: 1.0.0-alpha.2+2
```

The prerelease train targets stable `1.0.0` directly:

```text
1.0.0-alpha.2
< 1.0.0-alpha.3
< 1.0.0-beta.1
< 1.0.0-rc.1
< 1.0.0
```

Compatibility guarantees are intentionally weaker before stable, but published prerelease data compatibility still must be handled explicitly for every predecessor a new release claims to support.

No published release version is retagged or rewritten. A changed artifact requires a new version/build number.

## Release stages

### Alpha

Alpha is for incomplete but end-to-end usable builds.

Alpha may include missing v1 features, schema/UI changes, breaking prerelease behavior, and security-model refinement when compatibility/migration is explicitly handled.

Alpha is not permission to store sensitive data in plaintext, skip backup/migration safety, or overwrite an already-published release artifact.

### Beta

Beta begins when intended v1 core scope is feature-complete. Focus shifts to correctness, usability, migrations, portability, accessibility, and platform behavior. Large redesigns require exceptional justification; data-loss/security defects block promotion.

### Release candidate

`1.0.0-rc.N` is a candidate for exact stable `1.0.0`.

Features are frozen. Only bug/security/documentation/packaging corrections and release blockers should land. Every change is evaluated for whether another RC is required.

There is no automatic time-based RC-to-stable promotion.

### Stable

`1.0.0` is published only after deliberate approval that the RC line has been tested sufficiently.

Stable requires release notes, version tag, GitHub Release, reproducible/traceable source state, and documented compatibility expectations.

## Time-bounded stabilization cycles

A concrete time-bounded prerelease target may be recorded in `PROJECT.md`.

A date target never weakens gates. Instead:

- freeze/narrow scope;
- favor small vertically complete branches;
- use local-first validation to remove avoidable latency;
- defer nonessential roadmap work;
- reserve the final period for blockers, recovery, upgrade, packaging, and release verification;
- do not promote merely because the calendar target arrived.

The vacation-ready alpha.2 stabilization cycle is complete. Its existence is historical evidence, not a reason to keep a permanent release branch or assume the next alpha scope.

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
9. install-over upgrade is tested for every predecessor lineage claimed as supported, or an explicitly documented portable migration path is used when signature lineage makes direct install-over impossible;
10. dependency/security review is complete;
11. source tree contains no secrets/local-only files;
12. annotated `vX.Y.Z...` tag is created from the approved commit;
13. GitHub Release is created from that tag and marked prerelease when applicable;
14. directly distributed artifacts have recorded SHA-256 checksums;
15. uploaded asset identity/checksums are verified;
16. `PROJECT.md` records the published release checkpoint and next development state;
17. completed release branch is removed when no longer needed.

## Changelog policy

`CHANGELOG.md` records release-facing changes, not every development action.

Use `PROJECT.md` for implementation continuity/session handoff.

`Unreleased` contains changes meaningful to users, data compatibility, security, packaging, or contributors since the latest published release. When publishing, freeze those entries under the exact version/date and start a fresh `Unreleased` section.

## Dependency updates

Dependency updates use normal PRs and are never merged merely because a bot opened them.

For runtime/tooling dependencies as applicable, review:

- release notes/maintenance activity;
- known advisories;
- license compatibility;
- Flutter/Dart/Android/Linux compatibility;
- lockfile changes;
- relevant tests/builds.

Do not add a dependency solely to reserve a future design choice.

## Post-release rule

After publication:

1. verify tag, release metadata, and distributed assets;
2. keep the published tag/assets immutable;
3. record exact release source and artifact identity in `PROJECT.md` / release docs;
4. return normal development to current `main`;
5. do not infer the next release's feature scope from the just-completed stabilization branch.
