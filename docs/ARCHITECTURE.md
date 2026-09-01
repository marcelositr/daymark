# Architecture

## Status

This document defines Daymark's architectural constraints. Concrete package versions may evolve through reviewed dependency updates, but the boundaries and technology choices below are intentional.

The first Flutter scaffold is being established in PR #3. The exact resolved dependency set becomes authoritative through the committed `pubspec.lock` once that scaffold bootstrap completes successfully.

## Current toolchain baseline

Daymark is a Flutter application.

Current baseline after the 2026-09-01 technology and scaffold review:

- Flutter stable 3.47.2;
- Dart 3.13.2 supplied by Flutter;
- Linux and Android as initial runtime targets.

Flutter 3.47.2 is pinned in `.flutter-version` and `pubspec.yaml`. Future toolchain changes require a reviewed update rather than silently following the stable channel.

Android should target Flutter's currently supported Android baseline rather than deliberately supporting versions the framework itself no longer supports. At the current review point, API 24 is the minimum supported Flutter deployment level.

Future architectural targets may include Windows, macOS, and iOS. Web is not an initial target.

## Application structure

Daymark should remain a single Flutter application until a concrete reason exists to split it into multiple packages.

Do not create a speculative monorepo, plugin system, shared-server package, or independent domain package merely because those structures might someday be useful.

The codebase should use a domain-centric modular structure. A likely initial shape is:

```text
lib/
├── app/
│   ├── routing/
│   ├── theme/
│   └── localization/
├── core/
│   ├── crypto/
│   ├── database/
│   ├── platform/
│   └── errors/
└── features/
    ├── journal/
    │   ├── domain/
    │   ├── application/
    │   ├── data/
    │   └── presentation/
    ├── security/
    ├── backup/
    └── settings/
```

Daily Log, Monthly Log, Future Log, Migration, Collections, and Index belong to one coherent journal domain rather than pretending they are unrelated products.

Framework and platform details remain at the edges. Domain logic must not depend on Flutter widgets, Android APIs, Linux desktop APIs, filesystem paths, windowing systems, keyrings, or routing libraries.

## Domain concepts

The authoritative semantic rules are defined in `docs/DOMAIN.md`.

The initial model revolves around:

- Journal
- Entry
- EntryType
- TaskState
- Signifier
- DailyLog
- MonthlyLog
- FutureLog
- Collection
- Migration
- Reflection

Entry type, task state, signifiers, storage location, Collection references, and migration lineage are separate concerns.

The schema must follow domain behavior rather than mirror screens or rendered Bullet symbols.

## UI foundation

Daymark uses Flutter's Material 3 widgets and theming as a technical foundation, not as a visual requirement to look like a stock Material application.

The product visual identity is a minimal dotted-notebook page with light, dark, and system theme modes. It is not a freeform canvas, page-layout editor, or drawing application.

The same product identity is shared across Linux and Android, but the layouts are adaptive:

- compact layouts optimize for fast mobile capture;
- expanded layouts may use wider navigation and keyboard-oriented workflows;
- a desktop layout must not be squeezed unchanged into a phone.

Avoid external UI/theme frameworks until a specific unmet requirement proves they are necessary.

## State management and dependency wiring

Use Riverpod 3.x for application/presentation state, dependency wiring, and asynchronous state where Flutter's local widget state is insufficient.

Initial rules:

- use Riverpod without code generation;
- do not put domain behavior inside providers merely because providers are convenient;
- keep transient widget-only state local to widgets when appropriate;
- use explicit repositories and application services for business operations;
- prefer fakes/in-memory implementations in tests over heavy mocking frameworks.

Riverpod is infrastructure. It must not become the domain model.

## Routing

Use `go_router` 18.x for application-level routing and navigation state.

The primary navigation model is:

```text
Today
Monthly
Future
Collections
Search
```

Index remains a distinct method structure even when its entry point differs between compact and expanded layouts.

Settings and contextual reflection flows are secondary navigation rather than permanent top-level destinations.

Route names and persisted domain values must remain language-neutral.

## Persistence

Drift 2.34.x is the typed relational persistence layer.

`package:sqlite3` 3.x provides the native SQLite interface and build-hook integration.

Encrypted native storage uses SQLite3MultipleCiphers selected through the `sqlite3` build hook rather than the earlier SQLCipher-first assumption:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

This direction supersedes the earlier plan to depend on `sqlcipher_flutter_libs`, which is obsolete in the current Drift/sqlite3 ecosystem.

The application must verify at runtime during database setup that the encrypted SQLite variant is actually loaded before opening journal data. Failure to provide the expected cipher support is a startup security failure, not a reason to silently open plaintext SQLite.

SQLite3MultipleCiphers currently uses ChaCha20-Poly1305 as its recommended/default authenticated cipher. Daymark should begin with that non-legacy cipher unless the focused security prototype produces a concrete, documented reason to select another supported authenticated scheme.

The database receives random raw journal key material. The master password must never be passed directly to SQLite3MultipleCiphers as the database passphrase.

Database migrations must be:

- explicit;
- versioned;
- forward-only in normal operation;
- fixture-tested;
- safe against partial failure.

Destructive schema changes require an explicit data migration strategy.

Stable identifiers must be used for persisted entries and relationships. UUID v7 is the current identifier direction because it is globally unique and time-orderable without making database row numbers part of the domain contract.

Attachments, if introduced, should normally remain encrypted files rather than opaque database blobs. They must not create a plaintext side channel around the encrypted journal.

## Cryptographic application layer

Database encryption is only one layer of the security model.

Use the published `cryptography` package 2.9.x for application-level cryptographic operations that belong outside the database engine, including Argon2id password-based key derivation and authenticated encryption needed for wrapped keys, recovery material, or portable backup containers.

Do not implement cryptographic primitives manually.

The exact authenticated-encryption envelope, nonce handling, metadata layout, and Argon2id parameters must be frozen only after the security spike described in `PROJECT.md` is implemented and benchmarked.

The journal data-encryption key is generated from cryptographically secure random material and is distinct from the user's master password.

The master password protects access to the journal key through a versioned password-based key-derivation and key-wrapping layer.

Device-local assisted unlock requires a platform secure-storage abstraction, but that integration is intentionally deferred to the focused security spike rather than being forced into the general scaffold.

`flutter_secure_storage` remains a candidate, not a baseline scaffold dependency. Version 11.0.0 raised Android `compileSdk` to 37, while the Flutter 3.47.2 generated Android project currently uses API 36 with Android Gradle Plugin 9.1.0, whose own build diagnostics recommend API 36 as its maximum compile SDK. Daymark will not distort the Android toolchain or pin a compatibility bridge merely for an unused convenience layer. Re-evaluate the maintained secure-storage option when device-assisted unlock is implemented.

Whatever integration is selected, device-local storage is a convenience layer only and must not become the sole portable recovery mechanism.

## Backup architecture

Manual full encrypted backup and restore are initial product requirements.

Backups must be:

- encrypted by default;
- portable between supported platforms;
- independent of device-bound key stores;
- versioned;
- authenticated/integrity-checked before restore;
- recoverable without the original device when the user has the required portable credentials;
- capable of evolving to include attachments without changing the security boundary.

Automatic backup scheduling, retention rotation, remote synchronization, and cloud-specific integrations are later concerns.

Human-readable Markdown or JSON export is a separate portability feature and may intentionally produce plaintext after explicit user action.

## Localization

Internationalization is part of the initial architecture.

Use Flutter's built-in localization tooling with ARB resources and generated localization accessors. Do not add a competing localization framework without a concrete reason.

English is the canonical source locale and product fallback locale. Portuguese (Brazil) is the first additional product locale.

The scaffold resources are:

```text
lib/l10n/
├── app_en.arb
├── app_pt.arb
└── app_pt_BR.arb
```

`app_pt.arb` exists because Flutter 3.47.2's localization generator requires a parent locale when `pt_BR` is present. It is a technical generation fallback, not a third initial product language.

On first run, exact `pt_BR` system locales select Brazilian Portuguese, English locales select English, and unsupported locales fall back to English. A future explicit user override takes precedence over automatic system resolution.

User-facing strings must not be scattered as hardcoded presentation literals when they belong in localization resources.

Domain values, enum-like states, database records, migration logic, export schema identifiers, and application decisions use stable language-neutral identifiers. Translated strings are presentation only.

Layouts should use directional concepts such as start/end instead of assuming left/right wherever practical, keeping future RTL support possible without requiring a UI rewrite.

## File and platform integration

Prefer official Flutter-maintained plugins for routine platform integration when they satisfy the requirement.

Expected examples include:

- `path_provider` for application-owned filesystem locations;
- `file_selector` for explicit user-selected import/export/backup locations.

Platform-specific security behavior belongs behind interfaces under the platform/core boundary rather than leaking into journal domain objects.

## Code generation policy

Generated code increases coordination cost for agents and can obscure changes. Keep it limited.

Initial baseline:

- Drift code generation is allowed and expected;
- Flutter `gen_l10n` generation is allowed and expected;
- Riverpod code generation is not used initially;
- Freezed is not a baseline dependency;
- `json_serializable` is not a baseline dependency.

Use normal Dart classes, sealed classes, records, patterns, and explicit serializers where the amount of code remains reasonable. Add further generation only when repeated real code demonstrates a benefit greater than its tooling cost.

## Quality and analysis

Use Flutter's standard formatting and analysis tools.

The scaffold should enable strict analyzer behavior including strong treatment of casts, inference, and raw types where compatible with the chosen package set.

Use `flutter_lints` as the baseline rather than installing a large third-party lint profile before the team has evidence it improves this codebase.

The canonical quality gate, once implemented, should cover at minimum:

1. dependency resolution from the committed lockfile;
2. formatting check;
3. static analysis;
4. unit/widget tests;
5. database migration tests;
6. Linux build;
7. Android build;
8. dependency/security review.

## Testing strategy

Use Flutter/Dart's standard test infrastructure first:

- `flutter_test` for unit and widget tests;
- `integration_test` for end-to-end platform flows;
- Drift migration/schema tests with real fixtures;
- in-memory or temporary encrypted databases for repository tests where appropriate.

Security-sensitive flows require tests for failure as well as success, including wrong password, corrupted backup, unavailable secure storage, incompatible schema, and missing encrypted-database support.

Do not treat screenshot/golden testing as a substitute for behavioral tests. Add golden tests selectively when the visual contract becomes stable enough to justify their maintenance cost.

## Dependency and supply-chain policy

Applications commit `pubspec.lock`.

CI should use lockfile enforcement when practical so dependency resolution cannot silently change beneath an unchanged commit.

Dependencies must come from stable published packages unless an explicit temporary exception is documented. Mutable Git dependencies are not acceptable production defaults.

GitHub Actions should be pinned to immutable commit SHAs when workflows are introduced. Dependency review should reject newly introduced known-vulnerable dependencies according to repository policy.

## Foundation-first development order

Daymark establishes correctness and safety before product polish. A minimal toolchain scaffold is allowed early because it validates the selected Flutter, localization, native SQLite, Linux, and Android build assumptions without implementing journal behavior or persistence semantics.

The current dependency sequence is:

1. define the Bullet Journal domain semantics and product/security constraints;
2. establish the minimal pinned Flutter scaffold and repeatable CI/build baseline;
3. finalize the relational schema, identifiers, and migration strategy;
4. implement and benchmark the encryption/key-management and backup security prototype;
5. wire application, data, and presentation layers around those established contracts;
6. build the minimal end-to-end journal workflow;
7. refine UI and convenience features only after the core path is correct, testable, and secure.

The scaffold must not be used as an excuse to implement journal persistence, key handling, or product features ahead of the focused foundation work that governs them.

## Non-goals for the initial architecture

The first implementation does not require:

- a backend server;
- user accounts;
- cloud synchronization;
- collaboration;
- distributed conflict resolution;
- plugin infrastructure;
- AI services inside the product;
- a freeform canvas/page-layout editor;
- a multi-package workspace;
- a parallel planner/task-management subsystem;
- Rust/Tauri integration without a measured need.

These must not leak into the core model as speculative abstractions.
