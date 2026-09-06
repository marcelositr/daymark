# Daymark agent operating contract

Daymark is intentionally developed with AI assistance across chat sessions, CLI tools, APIs, and potentially different agents. Repository state must therefore be sufficient to resume work safely without relying on conversation memory.

These rules apply to every coding or documentation agent working in this repository.

## Product freeze is authoritative

Daymark's functional product scope was frozen by the maintainer on 2026-09-05.

Agents must treat the current product as feature-complete. Normal work is maintenance only:

- bug/regression fixes;
- security fixes/required hardening;
- compatibility and data-migration fixes;
- Linux/Android platform, dependency, toolchain, packaging, signing, CI, and release maintenance;
- accessibility, localization, test, or documentation corrections that preserve existing behavior;
- narrow internal refactors necessary to make those corrections safely.

Agents must **not** propose, design, scaffold, or implement new product features merely because an older document mentions them as future/deferred/later work.

In particular, do not reopen device-assisted/biometric unlock, recovery-secret UX, cloud/accounts/network services, AI features, collaboration, additional platforms/languages, richer Search/Index/Collection/migration/reflection capabilities, automatic backup scheduling, attachments, dashboards, gamification, or freeform editing unless the maintainer explicitly reverses the product freeze first.

The maintainer explicitly reversed the language boundary only far enough to add general Spanish (`es`) on 2026-09-06. English, Portuguese (Brazil), and Spanish are now the complete supported language set; this does not authorize any further language or explicit language-selector work.

`PROJECT.md` and `docs/PRODUCT.md` are authoritative for the current frozen scope. Historical documents may retain contextual references to earlier ideas, but those references are not a roadmap.

## Mandatory start sequence

Before planning or changing anything:

1. read `PROJECT.md`;
2. verify the current Git branch and open pull request, if any;
3. read the documents relevant to the area being changed;
4. inspect existing code and tests before assuming behavior;
5. confirm the requested work is allowed maintenance under the product freeze;
6. check `PROJECT.md` for blockers and the next intended maintenance/release boundary.

For foundational work, also read:

- `docs/PRODUCT.md`;
- `docs/DOMAIN.md`;
- `docs/DATA_MODEL.md` when persistence or migration is involved;
- `docs/ARCHITECTURE.md`;
- `SECURITY.md`;
- `docs/WORKFLOW.md`;
- `CONTRIBUTING.md`.

Conversation context is useful, but it is not the project source of truth. If a conversation and the repository disagree, reconcile the difference explicitly instead of silently choosing one.

Do not infer current state from PR number alone. Check whether the PR is Draft, Ready, merged, closed, superseded, or still open, and compare its exact head SHA with `PROJECT.md` before acting.

## Mandatory end sequence

Before ending a meaningful work session, handing work to another agent, or stopping because of a tool/API limit:

1. update relevant tests and documentation;
2. update `PROJECT.md` with completed work, remaining release/maintenance steps, blockers, validation evidence, exact important SHAs, and the next concrete step;
3. record any durable architectural, security, product, domain, or workflow correction in its authoritative document;
4. ensure the branch contains no accidental generated files, secrets, binaries, temporary diagnostics, probe workflows, or unrelated changes;
5. ensure no stale roadmap/feature language was introduced;
6. leave the repository understandable without the previous chat.

A task is not properly handed off until `PROJECT.md` reflects reality.

## Project-state discipline

`PROJECT.md` is the canonical living checkpoint.

Agents may:

- add newly discovered defects;
- split repairs that proved too large;
- reopen a completed repair when evidence shows regression;
- record blockers and diagnostic experiments;
- reorder maintenance/release work when dependencies become clearer.

Do not create or maintain a feature backlog under the current freeze.

Do not rewrite history to make the project appear linear. Release history belongs in `CHANGELOG.md`; implementation/maintenance continuity belongs in `PROJECT.md`.

## Preferred engineering loop

For substantive repair, lifecycle, persistence, security, compatibility, or architecture-maintenance work, use the validation ladder below unless the task is too small to justify every stage.

1. **Establish a trustworthy baseline.** Confirm intended base branch, current PR state, relevant CI, clean working state, pinned toolchain, existing tests, and freeze compatibility before editing.
2. **Audit before repairing when evidence is contradictory.** If repeated fix commits exist, CI/manual behavior disagree, or architecture is suspect, diagnose first. Do not mix diagnosis and speculative fixes.
3. **Choose the smallest healthy repair boundary.** Normal work starts from current `main`. Preserve structurally unsound inherited branches as reference and rebuild only the affected maintenance slice from a healthy base when necessary.
4. **Choose the fastest trustworthy feedback path.** Draft CI is useful when remote evidence is needed. When local execution is explicitly agreed, pinned local formatter/analyzer/tests/builds may be the primary loop. Final required CI still applies.
5. **Implement and test at the correct layer.** Presentation/widget tests should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to reach UI. Use controlled presentation boundaries and separate real persistence/session/integration tests.
6. **Treat failures as evidence.** Capture failing command, exit code, last completed step, and diagnostic output. Reduce before changing production code. Never weaken security/invariants/tests/CI merely to turn a check green.
7. **Validate progressively.** Required generation/reproducibility -> pinned formatter -> static analysis -> focused tests -> complete suite -> native builds -> manual platform flow where relevant.
8. **Remove diagnostic scaffolding.** Temporary workflows, probes, logging, and experiments must be removed or deliberately promoted into maintainable tests.
9. **Align documentation before final review.** Update `PROJECT.md` and authoritative docs while context is fresh.
10. **Run full merge validation only from a reviewable state.** Final implementation/docs must be coherent before full Ready CI/`merge-gate`.
11. **Merge only on explicit maintainer approval.** Green checks make a PR eligible, not authorized.

This ladder is a default, not bureaucracy. Tiny documentation/mechanical corrections can use a proportionate subset, but skipping a layer must never hide uncertainty about persistence, lifecycle, security, migration, or user-data behavior.

## Failure-prevention rules from real project incidents

These rules exist because the project has already lost time to these exact classes of mistakes.

### Generated localization comes before analysis and tests

When any ARB resource changes, run `flutter gen-l10n` before `flutter analyze` or tests that compile presentation code.

If generated localization accessors are stale locally, missing getters can look like production compile defects even when CI is correct. Do not modify UI code to accommodate stale generated localization output.

The informational message saying that `l10n.yaml` options are being used is expected and is not a failure.

### Use the pinned formatter, do not guess its reflow

Formatting is defined by the Dart version supplied by the pinned Flutter toolchain. Apply that formatter before expensive validation whenever Dart source/tests changed.

Do not hand-edit formatting repeatedly based on visual guesses. If the agent cannot execute the pinned formatter and local execution is agreed, provide a complete safe command block and treat returned formatter output as authoritative evidence.

### Drift migration-generated sources must survive through analyzer/tests

When migration validation is required:

```text
dart run build_runner build
dart run drift_dev make-migrations
flutter analyze
flutter test
```

Do not remove `test/database/migrations/daymark/generated` before analyzer/full tests that import those generated files. Remove temporary migration output only after checks that require it complete.

### Distinguish a test-harness defect from a production defect

A failing widget assertion does not automatically justify changing production behavior. First determine whether the test is wrong, including off-screen content, ambiguous finders, invalid scrolling assumptions, or inaccurate fakes.

Fix the test when the test architecture/API usage is wrong. Do not distort product behavior to make a brittle test pass.

### Preserve semantic repository boundaries

Focused repositories must validate the owner/location semantics they claim to represent. Do not rely solely on a correct caller.

Boundary tests should prove invalid owners cause no partial write.

### Retained navigation must refresh after cross-surface writes

Daymark's top-level `StatefulShellRoute.indexedStack` retains branch widgets. A screen can remain mounted while another section changes data it displays.

Do not assume `initState()` reruns. Where existing product behavior depends on refresh:

- identify whether the destination keeps an in-memory snapshot;
- observe section activation when refresh is required;
- reload presentation state on reactivation;
- do not require lock/restart/remount merely to observe a successful write;
- add regression coverage for the repair.

Persistence success and immediate presentation freshness are separate correctness requirements.

### User terminal blocks must be safe in an interactive shell

Commands sent to the maintainer are often pasted directly into an existing shell. Therefore:

- **never use `set -e` in pasteable interactive-terminal blocks**;
- never end a pasteable block with a bare `exit`;
- avoid `{ ...; exit 1; }` guard patterns that can close the shell;
- prefer complete `if ...; then ...; else ...; fi` flow;
- capture/print exit codes when later commands should still report status;
- verify shell syntax before sending multi-line blocks;
- prefer one bounded command block at a time when its result determines the next step;
- include exact expected branch/head when branch-sensitive validation matters.

A malformed or unsafe diagnostic block is an agent defect, not a maintainer mistake.

### Never delete unexplained local files blindly

Git's normal fetch metadata lives at `.git/FETCH_HEAD`. A repository-root file named `FETCH_HEAD` is different.

If an unexpected untracked file appears, inspect its path, size, type, and relevant content before deleting it.

### Do not confuse superseded CI with current evidence

A push can cancel or supersede an earlier workflow run. Validation evidence belongs to the exact head SHA being considered.

Before citing CI as proof, verify that `head_sha` matches the PR head.

### Documentation commits create a new validation boundary

If documentation is committed after local/manual implementation validation, the PR head changes even when production code does not.

Record which evidence belongs to which head and run proportionate final checks required by policy on the final documented head.

## Local/manual validation with the maintainer

When the maintainer has explicitly agreed to act as a local execution bridge, local validation is a first-class development path.

The agent remains responsible for deciding what to run and interpreting evidence. The maintainer must not be required to invent debugging commands or diagnose agent-generated failures.

For local execution:

- provide complete copy-paste command blocks rather than fragments;
- include clean-worktree/safety stops when destructive or branch-sensitive commands are involved;
- state expected success markers and what output should be returned;
- ask the maintainer to stop at the first unexpected result rather than improvising repairs;
- prefer one bounded diagnostic block at a time when the result determines the next step;
- run required generators before compilation checks and the pinned formatter before expensive tests/builds;
- use focused tests during diagnosis, then complete suite/native builds when the repair is believed complete;
- reserve destructive backup/restore, migration, clean-install, or upgrade checks for controlled/disposable data unless explicitly chosen otherwise;
- do not ask for passwords, key envelopes, journal plaintext, recovery material, signing secrets, or other secrets.

Local green evidence cannot bypass required repository status checks.

## Tool and API degradation

GitHub, CI, connectors, and external APIs can be delayed or incomplete.

When required evidence is missing, stale, contradictory, or an API operation fails:

- do not guess unseen CI/repository state;
- retry only when safe and likely to resolve a transient read problem;
- continue independent work that does not depend on the missing fact;
- prefer agreed local validation for work that does not require GitHub-only evidence;
- when the missing fact blocks a decision, ask for the smallest concrete reference needed;
- never merge, rewrite history, publish, or make a security/data-integrity decision based on assumed state.

## Scope and design discipline

Daymark implements a frozen focused digital Bullet Journal.

Do not introduce speculative architecture for capabilities outside current scope. Prefer the smallest repair that preserves the existing product and known compatibility/security obligations.

Do not create temporary product concepts to unblock a fix. Existing migration/scheduling destinations, ownership rules, navigation concepts, security boundaries, and supported platforms/languages are product constraints.

During release stabilization, only release blockers and maintenance corrections may change the branch. Time remaining is not a reason to broaden scope.

## Security discipline

Security decisions in `SECURITY.md` are constraints, not suggestions.

Agents must not:

- store journal plaintext outside approved boundaries;
- log secrets, passwords, keys, decrypted entries, or recovery material;
- invent cryptographic primitives/formats;
- downgrade encryption/key handling for convenience;
- add a dependency with a known unresolved vulnerability without documented exception handling;
- weaken release/CI checks merely to make a build pass;
- introduce a new security convenience feature under the guise of hardening when no concrete vulnerability requires it.

If a security assumption changes, update `SECURITY.md` and `PROJECT.md` before treating the new assumption as established.

## Git discipline

Follow `docs/WORKFLOW.md`.

In particular:

- `main` is the only permanent integration branch;
- normal work uses a short-lived maintenance branch;
- `feat/*` branches are not normal work while the product freeze is active;
- one branch/PR has one coherent responsibility;
- PRs are squash-merged by default;
- PR titles follow Conventional Commit style;
- do not force-push or commit directly to `main`;
- do not create tags/releases casually;
- never merge, publish, or advance a release stage unless the maintainer explicitly requests it;
- retain historical branches unless the maintainer explicitly requests removal.

## Dependency discipline

Use the current architecture baseline in `docs/ARCHITECTURE.md`.

Before changing dependencies:

1. prove a compatibility/security/toolchain/maintenance reason exists;
2. check current maintenance status and known advisories;
3. prefer stable published packages over mutable Git dependencies;
4. document why the change is required;
5. update lockfile and validation together.

Do not add dependencies to create new capabilities under the frozen scope.

## When uncertain

Do not fill product/architectural gaps with guesses that become accidental standards.

If a proposed change looks like a feature rather than maintenance, stop at that boundary. The default is **do not implement it** while the product freeze remains active.
