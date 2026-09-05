# Contributing

Daymark's functional product scope is frozen. Contributions are welcome when they **preserve and repair the existing product**, not when they expand it.

The repository is intentionally structured for AI-assisted development across multiple sessions and agents. Continuity rules are part of the engineering process, not optional housekeeping.

## Contribution scope

Accepted contribution classes are:

- bug and regression fixes;
- security fixes and necessary hardening;
- compatibility/data-migration fixes;
- Linux/Android platform or toolchain maintenance required to keep the supported product working;
- dependency, build, packaging, signing, CI, and release maintenance;
- accessibility, localization, test, and documentation corrections that preserve existing behavior;
- narrow internal refactors required to make those corrections safely.

**Feature requests and feature contributions are not part of the current project workflow.**

Do not use a maintenance issue/PR to introduce a new workflow, setting, supported platform/language, convenience layer, remote service, planner abstraction, or other capability. A product-scope change requires an explicit maintainer decision to reverse the freeze before implementation begins.

The frozen product boundary is authoritative in `PROJECT.md` and `docs/PRODUCT.md`.

## Before starting work

Read, in this order:

1. `AGENTS.md`
2. `PROJECT.md`
3. `docs/PRODUCT.md`
4. `docs/DOMAIN.md`
5. `docs/DATA_MODEL.md` when persistence or migration is involved
6. `docs/ARCHITECTURE.md`
7. `SECURITY.md`
8. `docs/WORKFLOW.md`

Then inspect the current branch, open pull request, exact head SHA, relevant code, tests, and CI state.

Before coding, confirm that the work is maintenance under the product freeze rather than a new feature proposal.

Do not assume a previous chat, agent summary, branch name, or PR number is newer than the repository. If sources disagree, reconcile them explicitly before changing code.

## Development expectations

Changes should:

- fix or preserve a clearly identified existing behavior;
- use the smallest safe correction;
- keep domain logic independent from Flutter and platform APIs where the existing architecture requires it;
- include tests at the layer that owns the behavior;
- preserve Linux and Android support;
- preserve English and Portuguese (Brazil) localization behavior;
- keep encrypted persistence and plaintext boundaries intact;
- avoid unnecessary dependencies and code generation;
- keep user data local by default;
- include database migration tests when a maintenance change requires schema evolution;
- update documentation when behavior, architecture, security, compatibility, or workflow changes;
- update `PROJECT.md` before work is handed off.

A maintenance fix must not quietly broaden the product.

## Git and pull requests

Follow `docs/WORKFLOW.md`.

Normal work starts from current `main` on a short-lived maintenance branch.

Preferred branch types are `fix/*`, `docs/*`, `refactor/*`, `test/*`, `chore/*`, `ci/*`, `hotfix/*`, or an explicitly approved `release/*` branch. Do not open normal `feat/*` branches while the product freeze is active.

Pull requests should be small enough to review and have one coherent responsibility.

Pull request titles use Conventional Commit style, for example:

```text
fix(storage): preserve migration lineage
fix(ui): restore search focus
docs: correct release checkpoint
chore(deps): update compatible tooling
```

AI agents must not merge pull requests unless the maintainer explicitly requests it.

Pull requests should explain:

- the defect/maintenance problem being addressed;
- why the change fits the frozen product scope;
- how it was validated and on which exact head;
- whether persistence, migration, export, backup, security, localization, or platform behavior is affected;
- whether `PROJECT.md` and other authoritative documents were updated.

Do not mix broad refactoring with unrelated repairs.

## Testing and validation

Prefer behavior-focused tests and real fakes over excessive mocking.

Widget/presentation tests should not perform expensive KDF/crypto, real filesystem, or encrypted SQLite work merely to render UI. Prove those boundaries separately in repository/session/security tests.

Security-sensitive behavior must test failure paths as well as success paths.

Schema changes require migration fixtures representing supported predecessor schemas.

A build compiling is not sufficient validation for persistence, backup, recovery, migration, or security work.

When ARB resources change, run `flutter gen-l10n` before analyzer/tests that compile localized presentation code.

Use the Dart formatter supplied by the pinned Flutter toolchain rather than guessing formatting changes manually.

When Drift migration validation is involved, temporary generated migration sources must remain present until analyzer/full tests that import them have completed.

A failing test must be classified before changing production code. Test-harness problems are not production defects.

When a maintenance fix writes data that another retained top-level section displays, remember that Daymark's `StatefulShellRoute.indexedStack` retains branch widgets. Regression coverage must prove the destination refreshes when it becomes active again when that is part of the defect.

The detailed incident-derived failure-prevention rules are mandatory and live in `AGENTS.md`.

## Local validation through the maintainer

When the maintainer has explicitly agreed to execute Daymark validation locally, that path may be the primary feedback loop, especially when the pinned local toolchain/hardware is faster or more representative than delayed GitHub Actions.

The AI agent remains responsible for diagnostic design, command construction, expected results, and interpretation of returned evidence. Local execution must not turn the maintainer into the debugger for agent-generated changes.

Pasteable command blocks must be safe for an interactive shell:

- never use `set -e` in a block intended to be pasted into the maintainer's interactive terminal;
- no bare final `exit`;
- no accidental shell-closing guard patterns;
- use syntactically complete conditional flow when needed;
- print exit codes/expected success markers where useful;
- include exact branch/head checks when validation is SHA-sensitive;
- run required generators before compilation-dependent checks;
- run the pinned formatter before expensive tests/builds when applicable.

Use focused tests during diagnosis, then the complete suite and applicable native builds when the repair is believed complete. Destructive backup/restore, migration, clean-install, or upgrade checks should use controlled/disposable data unless the maintainer explicitly chooses otherwise.

Local green evidence can replace routine Draft-CI iteration, but it does not bypass required repository checks. The exact final PR head must still pass required CI/`merge-gate` before merge.

Do not ask the maintainer to expose passwords, journal plaintext, keys, envelopes, recovery material, signing secrets, or other sensitive data.

## Dependencies

Dependency changes are maintenance work only when they have a concrete reason such as compatibility, support, security, or toolchain requirements.

Before changing a dependency:

- verify the update is actually necessary;
- check current maintenance activity and published stable versions;
- check known security advisories;
- review license compatibility;
- verify Flutter/Dart/Android/Linux compatibility;
- avoid mutable Git dependencies;
- document the reason in the pull request.

Do not add a package to create a new product capability under the frozen scope.

Generated-code tooling has a maintenance cost. The architecture baseline permits Drift and Flutter localization generation and intentionally avoids additional generators without a maintenance requirement.

## Documentation and handoff

`PROJECT.md` is the canonical live handoff document.

Before stopping meaningful work, update it with:

- completed maintenance/release steps;
- discovered defects;
- blockers;
- exact important SHAs and validation evidence;
- the next concrete maintenance/release action.

Do not invent or preserve a feature backlog. If old documentation contains roadmap language that conflicts with the current freeze, update the authoritative document while preserving historical evidence where appropriate.

A documentation commit changes the PR head. Validation evidence from an older implementation head must be identified as such, and the final documented head must still pass the proportionate final validation required by project policy before Ready/merge.
