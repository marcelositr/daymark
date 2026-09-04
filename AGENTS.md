# Daymark agent operating contract

Daymark is intentionally developed with AI assistance across chat sessions, CLI tools, APIs, and potentially different agents. Repository state must therefore be sufficient to resume work safely without relying on conversation memory.

These rules apply to every coding or documentation agent working in this repository.

## Mandatory start sequence

Before planning or changing anything:

1. read `PROJECT.md`;
2. verify the current Git branch and open pull request, if any;
3. read the documents relevant to the area being changed;
4. inspect existing code and tests before assuming behavior;
5. check `PROJECT.md` for open questions, blockers, previously rejected directions, and the next intended PR boundary.

For foundational work, also read:

- `docs/PRODUCT.md`;
- `docs/DOMAIN.md`;
- `docs/DATA_MODEL.md` when persistence or migration is involved;
- `docs/ARCHITECTURE.md`;
- `SECURITY.md`;
- `docs/WORKFLOW.md`;
- `CONTRIBUTING.md`.

Conversation context is useful, but it is not the project source of truth. If a conversation and the repository disagree, stop and reconcile the difference explicitly instead of silently choosing one.

Do not infer current state from PR number alone. Check whether the PR is Draft, Ready, merged, closed, superseded, or still open, and compare its exact head SHA with `PROJECT.md` before acting.

## Mandatory end sequence

Before ending a meaningful work session, handing work to another agent, or stopping because of a tool/API limit:

1. update the relevant tests and documentation;
2. update `PROJECT.md` with what was completed, what remains, blockers, validation evidence, exact important SHAs, and the next concrete step;
3. record any new durable architectural, security, product, domain, or workflow decision in its authoritative document;
4. ensure the branch contains no accidental generated files, secrets, binaries, temporary diagnostic files, probe workflows, or unrelated changes;
5. leave the repository in a state another agent can understand without the previous chat.

A task is not considered properly handed off until `PROJECT.md` reflects reality.

## Project-state discipline

`PROJECT.md` is the canonical living checkpoint for ongoing development.

It is intentionally organic. Agents may:

- add newly discovered work;
- split tasks that proved too large;
- reopen completed tasks when evidence shows rework is necessary;
- mark a previous direction as superseded;
- record blockers and experiments;
- reorder upcoming work when dependencies become clearer.

Do not rewrite history to make the project appear linear. Record the change of direction and why it happened.

Release history belongs in `CHANGELOG.md`; day-to-day implementation continuity belongs in `PROJECT.md`.

## Preferred engineering loop

For substantive feature, repair, lifecycle, persistence, security, or architecture work, use the validation ladder below unless the task is too small to justify every stage.

1. **Establish a trustworthy baseline.** Confirm the intended base branch, current PR state, relevant CI, clean working state, pinned toolchain, and existing tests before editing.
2. **Audit before repairing when evidence is contradictory.** If a branch has repeated fix commits, CI/manual behavior disagree, or the architecture is suspect, diagnose first. Prefer an isolated worktree or equivalent read-only inspection. Do not mix diagnosis and speculative fixes.
3. **Choose the smallest healthy branch boundary.** Normal work starts from current `main`. If inherited work is structurally unsound, preserve it as reference and rebuild only the affected slice from a healthy base rather than stacking patches indefinitely.
4. **Choose the fastest trustworthy feedback path.** A Draft PR remains useful when remote CI feedback is reliable or when a GitHub-only check is needed. When the user has explicitly agreed to local execution, pinned local formatter/analyzer/tests/builds may be the primary development loop instead of repeated Draft-CI pushes. This does not remove the final Ready CI or repository `merge-gate` requirement.
5. **Implement and test at the correct layer.** Presentation/widget tests should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to reach the UI. Use controlled in-memory boundaries for presentation behavior and separate real persistence/session/integration tests for filesystem, cryptography, database, and lifecycle behavior.
6. **Treat failures as evidence.** Capture the exact failing command, exit code, last completed step, and diagnostic output. Reduce the problem with the smallest useful probe. Never weaken security, invariants, tests, or CI just to turn a check green.
7. **Validate progressively.** Prefer this order: required generation/reproducibility -> pinned formatter -> static analysis -> focused tests -> complete test suite -> native builds -> manual product flow where platform behavior matters. Run the formatter early so mechanical reflow does not waste a later test/build cycle. A later green stage does not erase an unexplained earlier failure.
8. **Remove diagnostic scaffolding.** Temporary workflows, probes, logging, and experiments used to locate a problem must be removed or deliberately promoted into maintainable tests before the PR is considered ready.
9. **Align documentation before final review.** Update `PROJECT.md` and any authoritative product/domain/architecture/security/workflow document while the implementation context is still fresh.
10. **Run full merge validation only from a reviewable state.** Mark the PR ready after the implementation, documentation, and applicable local/manual validation are coherent. Then require the repository's full non-Draft CI and `merge-gate` before asking for merge approval.
11. **Merge only on explicit user approval.** Green local checks and green CI mean eligible for review/merge, not automatically merged.

This ladder is a default, not bureaucracy. Tiny documentation or mechanical changes can use a proportionate subset, but skipping a layer must never hide uncertainty about persistence, lifecycle, security, migration, or user-data behavior.

## Failure-prevention rules from real project incidents

These rules exist because the project has already lost time to these exact classes of mistakes.

### Generated localization comes before analysis and tests

When any ARB resource changes, run `flutter gen-l10n` before `flutter analyze` or tests that compile presentation code.

If generated localization accessors are stale locally, missing getters can look like production compile defects even when CI is correct. Do not modify UI code merely to accommodate stale generated localization output.

The informational message saying that `l10n.yaml` options are being used is expected and is not a failure.

### Use the pinned formatter, do not guess its reflow

Formatting is defined by the Dart version supplied by the pinned Flutter toolchain. Apply that formatter before expensive validation whenever Dart source/tests changed.

Do not hand-edit formatting repeatedly based on visual guesses. If the agent cannot execute the pinned formatter itself and the user has agreed to local execution, provide a complete safe command block and treat the user's returned formatter diff/output as authoritative local evidence. A temporary CI formatter probe is a fallback, not the preferred routine path, and must be removed before the PR is reviewable.

### Distinguish a test-harness defect from a production defect

A failing widget assertion does not automatically justify changing production behavior. First determine whether the test is wrong, including:

- content exists but is outside the built viewport;
- a finder matches more than one widget;
- a scrolling helper expects a `Scrollable` while the test supplied a `ListView` or another wrapper;
- the fake/test boundary does not model the production transition being asserted.

Fix the test when the test architecture or Flutter test API usage is wrong. Do not distort product behavior to make a brittle test pass.

### Preserve semantic repository boundaries

Focused repositories must validate the owner/location semantics they claim to represent. Do not rely solely on a correct caller.

Example: a Future Log repository must reject a non-Future Log owner even if the UI would never normally pass one. Boundary tests should prove invalid owners cause no partial write.

### Retained navigation must refresh after cross-surface writes

Daymark's top-level `go_router` shell retains branch widgets with `StatefulShellRoute.indexedStack`. A screen can therefore remain mounted while another section changes data that it displays.

Do not assume `initState()` reruns when the user returns to a retained section. For cross-surface operations such as Today/Monthly scheduling into Future:

- identify whether the destination screen keeps an in-memory snapshot;
- publish or observe section activation when a retained screen needs refresh;
- reload the affected presentation state when the section becomes active again;
- do not require lock, restart, or remount merely to observe a successful write;
- add a regression test that mutates the underlying presentation boundary while the destination is inactive, then proves the new data appears when that retained section is reactivated.

Persistence success and immediate presentation freshness are separate correctness requirements.

### User terminal blocks must be safe in an interactive shell

Commands sent to the user are often pasted directly into an existing shell. Therefore:

- never end a pasteable block with a bare `exit`;
- avoid guarded `{ ...; exit 1; }` patterns that can close the user's shell;
- prefer `if ...; then ...; else ...; fi` and printed stop messages;
- capture and print command exit codes when later commands should still report status;
- verify shell syntax before sending a multi-line block;
- prefer one bounded command block at a time when its result determines the next step;
- include the exact expected branch/head when branch-sensitive validation matters.

A malformed or unsafe diagnostic block is an agent defect, not a user mistake.

### Never delete unexplained local files blindly

Git's normal fetch metadata lives at `.git/FETCH_HEAD`. A repository-root file named `FETCH_HEAD` is a different path.

If an unexpected untracked file appears, inspect its path, size, type, and relevant content before deleting it. Do not assume a familiar filename is Git metadata when it is outside `.git/`.

### Do not confuse superseded CI with current evidence

A push can cancel or supersede an earlier workflow run. Validation evidence belongs to the exact head SHA being considered.

Before citing a CI run as proof, verify that its `head_sha` matches the PR head. Do not use a green run from an earlier implementation head as final evidence for a later documentation or code head.

### Documentation commits create a new validation boundary

If documentation is committed after local/manual implementation validation, the PR head changes even when production code does not.

Record which evidence belongs to the implementation head, then run the proportionate final checks required by project policy on the final documented head before Ready/full CI. Do not silently describe an older SHA as the final validated head.

## Local/manual validation with the user

When the user has explicitly agreed to act as a local execution bridge, local validation is a first-class development path rather than an exceptional last resort. This is especially appropriate when the user's pinned toolchain/hardware is faster or more representative than delayed GitHub Actions.

The agent remains responsible for deciding what to run and interpreting the evidence. The user must not be required to invent debugging commands or diagnose agent-generated failures.

For local execution:

- provide complete copy-paste command blocks rather than fragments;
- include a clean-worktree or other safety stop when destructive or branch-sensitive commands are involved;
- state the expected success markers and what output should be returned;
- ask the user to stop at the first unexpected result instead of improvising repairs;
- prefer one bounded diagnostic block at a time when the result determines the next step;
- run required generators before compilation checks and the pinned formatter before expensive tests/builds;
- use focused tests during implementation, then complete suite/native builds when the slice is believed complete;
- reserve destructive backup/restore, migration, clean-install, or upgrade checks for controlled/disposable data unless the user explicitly chooses otherwise;
- do not ask the user to expose passwords, key envelopes, journal plaintext, recovery material, signing secrets, or other secrets.

Local green evidence can replace routine remote development iteration, but it cannot be used to bypass a required repository status check. If the `main` ruleset requires `merge-gate`, the exact final PR head still needs that gate before merge.

## Tool and API degradation

GitHub, CI, connectors, and external APIs can be delayed or return incomplete data.

When required evidence is missing, stale, contradictory, or an API operation fails:

- do not guess the unseen CI result or repository state;
- retry only when doing so is safe and likely to resolve a transient read problem;
- continue with independent work that does not depend on the missing fact;
- prefer agreed local validation for development work that does not require GitHub-only evidence;
- when the missing fact blocks a decision, stop at that boundary and ask the user for the smallest concrete reference needed, such as a CI run result, job log, commit SHA, or terminal output;
- never merge, rewrite history, or make a security/data-integrity decision based on assumed tool state.

## Scope and design discipline

Daymark implements a focused digital Bullet Journal. Do not silently expand it into a general productivity platform.

Before introducing a feature or abstraction, verify that it belongs under `docs/PRODUCT.md` and `docs/DOMAIN.md`.

Do not introduce speculative architecture for features outside current scope. Prefer the smallest design that preserves known future portability and security requirements.

Do not create temporary product concepts solely to unblock a UI. In particular, destination-selection UI for migration/scheduling must use real method-native destinations rather than invented placeholder containers.

During a time-bounded stabilization/release cycle recorded in `PROJECT.md`, do not pull deferred roadmap items forward merely because time remains. Prefer stable completion, portability, recovery, packaging, and blocker fixes over speculative breadth.

## Security discipline

Security decisions in `SECURITY.md` are constraints, not suggestions.

Agents must not:

- store journal plaintext outside approved boundaries;
- log secrets, passwords, keys, decrypted entries, or recovery material;
- invent cryptographic primitives or formats;
- downgrade encryption or key handling for implementation convenience;
- add a dependency with a known unresolved vulnerability without the documented exception process;
- weaken release or CI checks merely to make a build pass.

If a security assumption changes, update `SECURITY.md` and `PROJECT.md` before treating the new assumption as established.

## Git discipline

Follow `docs/WORKFLOW.md`.

In particular:

- `main` is the only permanent integration branch;
- normal work uses a short-lived task branch;
- one branch and pull request should have one coherent responsibility;
- pull requests are squash-merged by default;
- PR titles follow Conventional Commit style;
- do not force-push or commit directly to `main`;
- do not create tags or releases casually;
- never merge a pull request, publish a release, or advance a release stage unless the user explicitly requests it.

The earlier long-lived foundation PR was a temporary pre-development exception and is finished. Normal short-lived task branches now apply.

## Dependency discipline

Use the current architecture baseline in `docs/ARCHITECTURE.md`.

Before adding any new dependency:

1. prove that the standard library, Flutter SDK, or an existing dependency is insufficient;
2. check current maintenance status and known security advisories;
3. prefer stable published packages over mutable Git dependencies;
4. document why the dependency is required;
5. update the lockfile and validation as one change.

Do not add code generation merely to avoid straightforward Dart code. The baseline intentionally limits generated code.

A dependency chosen for a future feature should not be forced into an earlier scaffold merely to reserve the choice. If current platform compatibility or threat-model validation is unresolved, defer the dependency to the focused task that actually uses it.

## When uncertain

Do not fill architectural gaps with guesses that become accidental standards.

If the missing decision is not necessary to finish the current work, record it under `Open questions` in `PROJECT.md` and continue with what is known.

If it is necessary, make the smallest reversible choice, document it, and mark it for review.
