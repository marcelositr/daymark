# Development workflow

This document defines the common Git, pull request, validation, versioning, and release process for Daymark.

The purpose is consistency across human and AI contributors. Agents must not invent a different branch model, validation sequence, or release numbering scheme for each task.

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

Open a Draft PR early when visible CI feedback will reduce risk. Draft does not mean low quality; it means the branch is still inside the implementation/diagnostic loop and is not yet asking for full merge validation.

A Draft PR is useful, but it is not required as the primary development runner when the user has explicitly agreed to execute the pinned local validation ladder and that path is faster or more reliable. The final Ready/non-Draft CI remains mandatory whenever repository rules require it.

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

## Staged implementation and validation

Daymark uses a staged validation flow so cheap, high-signal checks happen before expensive builds and so failures are diagnosed rather than patched blindly.

Local validation and GitHub CI are complementary. Local validation is the preferred fast feedback path when it is available and agreed with the user. GitHub Ready CI is the independent final merge gate where required by repository rules.

### 1. Baseline before edits

Before implementation:

1. start from an up-to-date `main` unless a current task branch is already the explicit source of truth;
2. verify the current branch, PR, exact head SHA, and working-tree state;
3. read `PROJECT.md` plus the authoritative documents for the affected area;
4. inspect the existing implementation and tests;
5. establish what is already green and what failure or requirement is actually being addressed.

If inherited work has repeated corrective commits, contradictory CI/manual results, or unclear architecture, audit it before editing. An isolated worktree is preferred when it helps keep diagnosis non-mutating.

Do not treat a PR number or branch name as sufficient evidence of current state. Verify whether the PR is Draft, Ready, merged, closed, superseded, or still open.

### 2. Development feedback path

Keep implementation inside a short-lived branch while it is changing materially.

There are two valid development-feedback paths:

1. **Local-first**: use the user's pinned local toolchain as the primary implementation loop when explicitly agreed. This is preferred during the current stabilization cycle and whenever GitHub Actions/API latency would add delay without adding signal.
2. **Draft-CI-assisted**: open/keep a Draft PR early when remote feedback is useful, local execution is unavailable, or a GitHub-only condition needs evidence.

The repository's Draft `dev-check` validates:

- locked dependency resolution;
- localization generation;
- Drift/code generation;
- migration snapshot generation;
- absence of stale generated Drift artifacts;
- formatting;
- static analysis.

Do not weaken these checks to accommodate a branch. Fix the underlying source, generated-state, or toolchain problem.

If ARB localization resources changed, local validation must run `flutter gen-l10n` before analyzer/tests that compile presentation code. Missing generated getters are not evidence that production UI should be rewritten.

Focused tests should be run during development whenever they are useful to prove behavior or diagnose a failure. The complete suite and native builds are finalization gates, not substitutes for targeted reasoning.

### 3. Test at the correct layer

Tests should match the boundary they claim to validate.

- widget/presentation tests use controlled in-memory or fake boundaries and should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to render a screen;
- repository/session/security tests may use real temporary filesystem, cryptography, and encrypted persistence where those behaviors are the subject under test;
- integration tests cover transitions across layers when the interaction itself is the risk;
- manual platform tests cover behavior that depends on the real Linux/Android application environment.

A test that bypasses the production transition responsible for a bug is not a sufficient regression test for that bug.

For retained top-level navigation, a regression test must exercise the **activation transition** when freshness depends on it. `StatefulShellRoute.indexedStack` can keep a destination widget mounted while another section writes data that it displays, so remounting the destination in a test can accidentally hide the real bug.

A widget-test failure must be classified before production changes are made. Off-screen content, ambiguous finders, incorrect scrolling APIs, and invalid fake boundaries are test-harness defects when production behavior is otherwise correct.

### 4. Diagnose failures before changing behavior

When a command, test, build, or CI job fails:

1. preserve the exact failure output and exit code;
2. identify the last operation that definitely completed;
3. reduce the failure with the smallest useful probe when necessary;
4. distinguish the original failure from shutdown/cancellation noise;
5. change production code only after evidence identifies a production defect;
6. change tests when the test architecture itself is invalid;
7. remove temporary probes/workflows after diagnosis.

Repeated speculative fixes are a signal to stop and re-audit the affected slice.

Formatter-only failures are mechanical. Reproduce them with the Dart version supplied by the pinned Flutter toolchain rather than guessing reflow by eye. During local-first work, run the formatter before expensive tests/builds so formatter reflow cannot become a late CI round trip. Temporary CI formatter probes are a fallback only and must be removed before the PR is reviewable.

### 5. Local validation ladder

Before requesting full merge validation, run the applicable local checks in this order:

1. locked dependency resolution and required generators;
2. generated-artifact/reproducibility checks;
3. pinned formatter;
4. analyzer;
5. focused tests for changed behavior;
6. complete test suite;
7. native build for the locally available target(s);
8. manual application flow when lifecycle, persistence, input, rendering, import/export, backup/restore, or platform behavior is involved.

For risky lifecycle/persistence work, manual validation should exercise the full user path rather than only the happy-path screen. Examples include create -> capture -> lock -> wrong unlock -> correct unlock -> restart -> persistence verification.

For cross-surface writes, manual validation must also verify **immediate visibility before lock/restart**. A successful database write is not enough if a retained destination section still shows a stale in-memory snapshot until the session is rebuilt.

Backup/restore, migration, clean-install, upgrade, or other destructive tests must use disposable/controlled data unless the user explicitly chooses otherwise after understanding the risk.

When an AI agent cannot execute a required local step, it should provide the user a complete copy-paste block with stop conditions, expected success markers, and a clear request for the resulting output. Do not require the user to invent debugging commands.

Commands intended to be pasted into an existing interactive shell must be safe in that shell:

- do not end with a bare `exit`;
- avoid nested guard patterns that call `exit 1` and can close the user's shell;
- prefer `if ...; then ...; else ...; fi` with printed stop messages;
- capture and print exit codes when the whole block should continue reporting status;
- verify shell syntax before sending the block;
- when branch-sensitive, print and compare the exact expected HEAD;
- prefer one bounded block at a time when the result determines the next action.

The user is an execution bridge for local evidence, not the debugger responsible for repairing agent-generated commands.

### 6. Documentation alignment

Before the PR becomes ready for review:

- update `PROJECT.md` with actual implementation and validation state;
- update authoritative product/domain/architecture/security/workflow documents for durable changes;
- update `CHANGELOG.md` only for release-facing behavior;
- remove temporary diagnostic scaffolding and unrelated artifacts.

The repository must be sufficient for a different agent to continue without the previous chat.

Documentation commits create a new PR head. When implementation/manual validation belongs to an earlier implementation head, record that fact explicitly and perform the proportionate final validation required by policy on the final documented head before Ready.

### 7. Ready for review and full CI

Mark the PR ready only when its implementation and documentation are coherent and applicable local/manual validation has passed or is explicitly recorded as the remaining review gate.

A non-Draft PR runs the full validation tier:

- `quality`, including generation, formatting, analysis, and the complete Flutter test suite;
- Linux build;
- Android build;
- dependency review;
- `merge-gate`, which requires the merge-tier jobs to succeed.

The live `main` ruleset requires the exact `merge-gate` status. Local green evidence cannot replace that required status. A PR is not merge-eligible until the required check succeeds on the exact final head.

CI evidence is head-SHA-specific. A green run from a superseded implementation head does not validate a later documentation or code head.

If GitHub Actions or an API is delayed or returns incomplete data, do not infer success. Continue independent work that does not depend on the missing evidence. When the missing fact blocks merge, ask the user for the smallest concrete CI/job reference needed to continue.

### 8. Explicit merge decision

Green local checks and green `merge-gate` make a PR eligible for merge. They do not authorize it.

The user makes the final merge decision. AI agents must not enable auto-merge or merge implicitly.

## Before merge

Before a PR is eligible for merge:

1. the branch is based on a current enough `main` that conflicts and migration interactions are understood;
2. `PROJECT.md` reflects the work and next step;
3. relevant product/domain/security/architecture/workflow documentation is updated;
4. formatting, analysis, tests, and required builds pass on the exact final head;
5. schema changes include migrations and migration tests;
6. security-sensitive changes include their threat-model impact;
7. dependency changes include a concrete rationale and security/license review;
8. no secrets, generated junk, temporary diagnostics, build artifacts, accidental binaries, or probe workflows are committed;
9. review conversations are resolved;
10. the required `merge-gate` check is green for the current head;
11. the user has explicitly approved the merge.

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

## Time-bounded stabilization cycles

A time-bounded stabilization target may be recorded in `PROJECT.md` when there is a concrete operational reason to produce a trustworthy prerelease by a specific date.

A date target does not weaken engineering gates. Instead:

- freeze or narrow scope;
- favor small, vertically complete branches;
- use local-first validation to remove avoidable remote latency;
- defer nonessential roadmap work rather than landing risky breadth;
- reserve the final day for blockers, release checks, controlled backup/restore, clean-install/upgrade, and packaging verification;
- do not promote to stable merely because the calendar target arrived.

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
