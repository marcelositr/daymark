# Daymark agent operating contract

Daymark is intentionally developed with AI assistance across chat sessions, CLI tools, APIs, and potentially different agents. Repository state must therefore be sufficient to resume work safely without relying on conversation memory.

These rules apply to every coding or documentation agent working in this repository.

## Mandatory start sequence

Before planning or changing anything:

1. read `PROJECT.md`;
2. verify the current Git branch and open pull request, if any;
3. read the documents relevant to the area being changed;
4. inspect existing code and tests before assuming behavior;
5. check `PROJECT.md` for open questions, blockers, and previously rejected directions.

For foundational work, also read:

- `docs/PRODUCT.md`;
- `docs/DOMAIN.md`;
- `docs/ARCHITECTURE.md`;
- `SECURITY.md`;
- `docs/WORKFLOW.md`;
- `CONTRIBUTING.md`.

Conversation context is useful, but it is not the project source of truth. If a conversation and the repository disagree, stop and reconcile the difference explicitly instead of silently choosing one.

## Mandatory end sequence

Before ending a meaningful work session, handing work to another agent, or stopping because of a tool/API limit:

1. update the relevant tests and documentation;
2. update `PROJECT.md` with what was completed, what remains, blockers, and the next concrete step;
3. record any new durable architectural, security, product, domain, or workflow decision in its authoritative document;
4. ensure the branch contains no accidental generated files, secrets, binaries, temporary diagnostic files, or unrelated changes;
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
4. **Open a Draft PR early when CI feedback is useful.** Draft CI is the cheap feedback loop for dependency resolution, generation, stale generated artifacts, formatting, and static analysis. Keep heavy validation for the ready-for-review stage unless a focused test is needed to diagnose a failure.
5. **Implement and test at the correct layer.** Presentation/widget tests should not perform real filesystem, expensive KDF/crypto, or encrypted SQLite work merely to reach the UI. Use controlled in-memory boundaries for presentation behavior and separate real persistence/session/integration tests for filesystem, cryptography, database, and lifecycle behavior.
6. **Treat failures as evidence.** Capture the exact failing command, exit code, last completed step, and diagnostic output. Reduce the problem with the smallest useful probe. Never weaken security, invariants, tests, or CI just to turn a check green.
7. **Validate progressively.** Prefer this order: generation/reproducibility -> formatting/static analysis -> focused tests -> complete test suite -> native builds -> manual product flow where platform behavior matters. A later green stage does not erase an unexplained earlier failure.
8. **Remove diagnostic scaffolding.** Temporary workflows, probes, logging, and experiments used to locate a problem must be removed or deliberately promoted into maintainable tests before the PR is considered ready.
9. **Align documentation before final review.** Update `PROJECT.md` and any authoritative product/domain/architecture/security/workflow document while the implementation context is still fresh.
10. **Run full merge validation only from a reviewable state.** Mark the PR ready after the implementation, documentation, and applicable local/manual validation are coherent. Then require the repository's full non-Draft CI and `merge-gate` before asking for merge approval.
11. **Merge only on explicit user approval.** Green CI means eligible for review/merge, not automatically merged.

This ladder is a default, not bureaucracy. Tiny documentation or mechanical changes can use a proportionate subset, but skipping a layer must never hide uncertainty about persistence, lifecycle, security, migration, or user-data behavior.

### Local/manual validation with the user

When a required validation can only be performed in the user's environment or on hardware the agent cannot access:

- provide complete copy-paste command blocks rather than fragments;
- include a clean-worktree or other safety stop when destructive or branch-sensitive commands are involved;
- state the expected success markers and what output should be returned;
- ask the user to stop at the first unexpected result instead of improvising repairs;
- prefer one bounded diagnostic block at a time when the result determines the next step;
- do not ask the user to expose passwords, key envelopes, journal plaintext, recovery material, or other secrets.

The user is an execution bridge for local evidence, not a substitute debugger. The agent remains responsible for interpreting the result and deciding the next safe step.

### Tool and API degradation

GitHub, CI, connectors, and external APIs can be delayed or return incomplete data.

When required evidence is missing, stale, contradictory, or an API operation fails:

- do not guess the unseen CI result or repository state;
- retry only when doing so is safe and likely to resolve a transient read problem;
- continue with independent work that does not depend on the missing fact;
- when the missing fact blocks a decision, stop at that boundary and ask the user for the smallest concrete reference needed, such as a CI run result, job log, commit SHA, or terminal output;
- never merge, rewrite history, or make a security/data-integrity decision based on assumed tool state.

## Scope and design discipline

Daymark implements a focused digital Bullet Journal. Do not silently expand it into a general productivity platform.

Before introducing a feature or abstraction, verify that it belongs under `docs/PRODUCT.md` and `docs/DOMAIN.md`.

Do not introduce speculative architecture for features outside current scope. Prefer the smallest design that preserves known future portability and security requirements.

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
