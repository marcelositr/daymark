# Architecture

## Status

This document defines Daymark's architectural constraints. Concrete package versions may evolve through reviewed dependency updates, but the boundaries and technology choices below are intentional.

The first Flutter scaffold is established in PR #3. The committed `pubspec.lock` is authoritative for the exact resolved dependency set on this development line.

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

The schema must follow domain behavior rather than mirror screens or rendered Bullet symbols. The authoritative relational contract is defined in `docs/DATA_MODEL.md`.

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

Drift 2.34.x is the typed relational persistence layer. The schema is declared under `lib/core/database/`, with exported schema snapshots versioned under `drift_schemas/`.

`package:sqlite3` 3.x provides the native SQLite interface and build-hook integration.

One encrypted database file represents one journal. Daymark does not multiplex independent journals inside a shared SQLite database. Future multiple-journal support should normally use separate encrypted files and independent journal keys so backup, deletion, transfer, and cryptographic isolation remain naturally journal-scoped.

Encrypted native storage uses SQLite3MultipleCiphers selected through the `sqlite3` build hook rather than the earlier SQLCipher-first assumption:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

This direction supersedes the earlier plan to depend on `sqlcipher_flutter_libs`, which is obsolete in the current Drift/sqlite3 ecosystem.

The application verifies at runtime during database setup that the encrypted SQLite variant is loaded before opening journal data. Failure to provide the expected cipher support is a startup security failure, not a reason to silently open plaintext SQLite.

The implemented database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode).

Each journal has 48 bytes of raw SQLite cipher material:

```text
32-byte random journal key || 16-byte random cipher salt
```

This is passed using SQLite3MultipleCiphers' documented ChaCha20 raw-key-plus-salt representation. The master password is never passed directly to SQLite3MultipleCiphers as a database passphrase.

Applying `PRAGMA key` alone is not treated as successful unlock. The database-opening layer performs a real `sqlite_master` read after configuring the cipher/key so an incorrect key fails before an opened Drift database is returned.

The Drift open lifecycle is also forced before `createNew()` returns. This ensures schema creation, built-in seed data, and connection initialization have actually occurred rather than leaking Drift's lazy-open behavior into the journal-creation contract.

Password KDF parameters, salts, wrapped journal-key material, recovery metadata, and device-assisted unlock handles remain outside the encrypted Drift schema. They are required before the database can be opened and therefore belong to the security layer's versioned portable envelope design.

Database migrations must be:

- explicit;
- versioned;
- forward-only in normal operation;
- fixture-tested;
- safe against partial failure.

Destructive schema changes require an explicit data migration strategy.

The initial schema starts at version 1. Drift's exported-schema and `make-migrations` tooling are the normal migration path. Unreleased schema v1 may be regenerated while the project remains pre-release; once a prerelease containing user data is published, later supported builds must provide tested upgrade paths for published schemas rather than silently resetting data.

Stable identifiers must be used for persisted entries and relationships. UUID v7 is the current identifier direction because it is globally unique and time-orderable without making database row numbers part of the domain contract.

Attachments, if introduced, should normally remain encrypted files rather than opaque database blobs. They must not create a plaintext side channel around the encrypted journal.

## Cryptographic application layer

Database encryption is only one layer of the security model.

Daymark uses the published `cryptography` package 2.9.0 for the PR #7 application-level security baseline:

- Argon2id for master-password key derivation;
- XChaCha20-Poly1305 for authenticated wrapping of portable journal-key material.

Do not implement cryptographic primitives manually.

### Journal key material

`JournalKeyMaterial` owns:

- a 32-byte cryptographically random journal data-encryption key in overwrite-on-destroy `SecretKeyData`;
- a 16-byte random SQLite3MultipleCiphers salt in a private mutable buffer.

Its serialized representation is exactly 48 bytes and is a compatibility-sensitive boundary once prerelease journals exist.

The holder exposes an explicit `destroy()` lifecycle. Owned mutable buffers are overwritten where practical, while `SECURITY.md` documents the limits of guaranteed zeroization under Dart/Flutter.

### Key envelope

The current key-envelope format is version 1 and remains outside the encrypted database.

It contains only pre-unlock metadata:

- format/version;
- Argon2id identifier, parameters, and random 16-byte KDF salt;
- XChaCha20-Poly1305 identifier;
- nonce;
- ciphertext containing the 48-byte serialized journal-key material;
- authentication tag.

Interpretation-sensitive metadata is authenticated as AAD. The parser is strict about expected fields and rejects unsupported format/KDF/AEAD identifiers rather than silently reinterpreting them.

Wrong password, modified ciphertext, modified nonce, modified authentication tag, modified authenticated KDF metadata, malformed/truncated data, and unsupported identifiers are covered by negative-path tests.

Authentication failures use a generic journal-unlock error rather than exposing password-quality hints.

### Argon2id parameters

The initial production baseline was frozen on 2026-09-02:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- output: 32 bytes;
- random KDF salt: 16 bytes per key envelope.

The decision followed profile-mode measurements on an Intel Core i5-2400 Linux system, Samsung SM-A015M Android hardware, and a deliberately conservative M7 3G PLUS Android 8.1 ARM32 device.

The review also measured the lower-memory/higher-iteration OWASP tradeoffs. They offered negligible desktop benefit and only modest Android latency reductions, so Daymark retained the 19 MiB / 2 baseline rather than lowering memory hardness to optimize for the slowest tested hardware.

`tool/argon2_benchmark.dart` provides the selected-profile harness. `tool/argon2_profile_matrix.dart` provides the comparison harness. `docs/ARGON2_BENCHMARK.md` records the procedure, raw evidence paths, and retuning rule.

Because envelope KDF metadata is untrusted before authentication, parser limits remain bounded to 64 MiB memory, 5 iterations, parallelism 4, and a fixed 32-byte output. Those limits are defensive input ceilings, not production work factors.

KDF parameters are explicit versioned envelope data. Future defaults may be strengthened, but existing envelopes must remain interpretable through an explicit compatibility path once real prerelease journals exist.

### Recovery relationship

Recovery remains a portable credential over the same random journal key rather than a separate database-key hierarchy.

A future recovery secret may independently wrap/protect the existing serialized journal-key material. The final human representation and UX remain deferred, but recovery must never depend solely on Android Keystore, Linux keyring state, an account server, or the original device.

### Session and memory boundary

Secret material must not live in global/static application state.

The current explicit journal-key holder is the basis for a later unlocked-session abstraction. Manual/automatic lock work must close/invalidate the encrypted persistence session and deterministically drop application references to key material as far as the runtime permits.

SQLite3MultipleCiphers' SQL `PRAGMA key` interface currently requires a hexadecimal Dart `String`. The mutable source buffer is overwritten after conversion, but immutable Dart strings cannot be reliably zeroized. This limitation is documented rather than hidden or "fixed" through speculative unsafe FFI.

Device-local assisted unlock requires a platform secure-storage abstraction, but that integration is intentionally deferred until the portable security baseline is complete.

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

Android OS-managed app-data backup is not the Daymark portable-backup mechanism. The Android manifest disables platform backup and references explicit rules that exclude all app-data domains from Android 11-and-earlier full backup and from Android 12+ cloud backup and device transfer. This is defense in depth around the independently encrypted journal and ensures cross-device portability is designed through Daymark's own authenticated backup/restore boundary rather than opaque platform migration state.

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

The scaffold enables strict analyzer behavior for casts, inference, and raw types, with `flutter_lints` as the baseline rather than a large third-party lint profile.

The permanent CI workflow in `.github/workflows/ci.yml` gates:

1. dependency resolution from the committed lockfile with lockfile enforcement;
2. localization generation;
3. Drift code generation;
4. Drift schema-snapshot freshness through `make-migrations` plus a clean generated-artifact diff;
5. formatting;
6. static analysis;
7. unit, widget, schema-invariant, encrypted-persistence, and security tests;
8. Linux debug build;
9. Android debug APK build;
10. dependency/security review for pull requests.

Future schema versions must add representative migration/data-preservation tests while keeping the existing `quality` check name stable for branch protection.

## Testing strategy

Use Flutter/Dart's standard test infrastructure first:

- `flutter_test` for unit and widget tests;
- `integration_test` for end-to-end platform flows;
- Drift migration/schema tests with real fixtures;
- temporary encrypted databases for persistence/security tests where appropriate.

The initial schema has direct invariant tests against an in-memory SQLite database. Future versions must test both target schema shape and representative data preservation across supported upgrades.

Security-sensitive flows require tests for failure as well as success, including wrong password, corrupted key envelope, corrupted backup, unavailable secure storage, incompatible schema, and missing encrypted-database support.

Performance/security parameters are not selected from shared CI runner timing. The initial Argon2id baseline was frozen from dedicated profile-mode measurements on representative Linux and physical Android hardware. Future retuning must follow the same evidence-first rule.

Do not treat screenshot/golden testing as a substitute for behavioral tests. Add golden tests selectively when the visual contract becomes stable enough to justify their maintenance cost.

## Dependency and supply-chain policy

Applications commit `pubspec.lock`.

CI uses lockfile enforcement so dependency resolution cannot silently change beneath an unchanged commit.

Dependencies must come from stable published packages unless an explicit temporary exception is documented. Mutable Git dependencies are not acceptable production defaults.

GitHub Actions are pinned to immutable commit SHAs. Pull-request dependency review rejects introduced dependencies at the configured severity threshold according to repository policy.

## Foundation-first development order

Daymark establishes correctness and safety before product polish. A minimal toolchain scaffold is allowed early because it validates the selected Flutter, localization, native SQLite, Linux, and Android build assumptions without implementing journal behavior or persistence semantics.

The current dependency sequence is:

1. define the Bullet Journal domain semantics and product/security constraints;
2. establish the minimal pinned Flutter scaffold and repeatable CI/build baseline;
3. finalize the relational schema, identifiers, and migration strategy;
4. implement and validate encryption/key management, including representative KDF benchmarking;
5. specify and validate the encrypted portable backup/restore security boundary;
6. wire application, data, and presentation layers around those established contracts;
7. build the minimal end-to-end journal workflow;
8. refine UI and convenience features only after the core path is correct, testable, and secure.

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
