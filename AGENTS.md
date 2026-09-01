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
3. record any new durable architectural, security, product, or domain decision in its authoritative document;
4. ensure the branch contains no accidental generated files, secrets, binaries, or unrelated changes;
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

The current long-lived foundation PR is an intentional temporary exception while the pre-development contract is being assembled. After it is merged, normal short-lived task branches apply.

## Dependency discipline

Use the current architecture baseline in `docs/ARCHITECTURE.md`.

Before adding any new dependency:

1. prove that the standard library, Flutter SDK, or an existing dependency is insufficient;
2. check current maintenance status and known security advisories;
3. prefer stable published packages over mutable Git dependencies;
4. document why the dependency is required;
5. update the lockfile and validation as one change.

Do not add code generation merely to avoid straightforward Dart code. The baseline intentionally limits generated code.

## When uncertain

Do not fill architectural gaps with guesses that become accidental standards.

If the missing decision is not necessary to finish the current work, record it under `Open questions` in `PROJECT.md` and continue with what is known.

If it is necessary, make the smallest reversible choice, document it, and mark it for review.
