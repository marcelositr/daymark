# Architecture

## Status

This document defines Daymark's architectural constraints. Concrete package versions may evolve through reviewed dependency updates, but the boundaries and technology choices below are intentional.

The committed `pubspec.lock` is authoritative for the exact resolved dependency set on the current development line.

## Current toolchain baseline

Daymark is a Flutter application.

Current baseline:

- Flutter stable 3.47.2;
- Dart 3.13.2 supplied by Flutter;
- Linux and Android as initial runtime targets.

Flutter 3.47.2 is pinned in `.flutter-version` and `pubspec.yaml`. Future toolchain changes require a reviewed update rather than silently following the stable channel.

Android should target Flutter's supported Android baseline rather than deliberately supporting versions the framework itself no longer supports. At the current review point, API 24 is the minimum supported Flutter deployment level.

Future architectural targets may include Windows, macOS, and iOS. Web is not an initial target.

## Application structure

Daymark remains a single Flutter application until a concrete reason exists to split it into multiple packages.

Do not create a speculative monorepo, plugin system, shared-server package, or independent domain package merely because those structures might someday be useful.

The codebase is domain-centric:

```text
lib/
├── app/
├── core/
│   ├── crypto/
│   ├── database/
│   └── session/
└── features/
    └── journal/
        ├── domain/
        ├── application/
        ├── data/
        └── presentation/
```

Daily Log, Monthly Log, Future Log, Migration, Collections, Index, and Search belong to one coherent journal domain rather than pretending they are unrelated products.

Framework and platform details remain at the edges. Domain logic must not depend on Flutter widgets, Android APIs, Linux desktop APIs, filesystem paths, windowing systems, keyrings, or routing libraries.

## Domain concepts

The authoritative semantic rules are defined in `docs/DOMAIN.md`.

The model revolves around:

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

The schema follows domain behavior rather than screens or rendered Bullet symbols. The authoritative relational contract is `docs/DATA_MODEL.md`.

## UI foundation

Daymark uses Flutter's Material 3 widgets and theming as a technical foundation, not as a requirement to look like a stock Material application.

The product visual identity is a minimal dotted-notebook page with light, dark, and system theme modes. It is not a freeform canvas, page-layout editor, or drawing application.

The same product identity is shared across Linux and Android, but layouts are adaptive:

- compact layouts optimize for fast mobile capture;
- expanded layouts may use wider navigation and keyboard-oriented workflows;
- a desktop layout must not be squeezed unchanged into a phone.

Avoid external UI/theme frameworks until a specific unmet requirement proves they are necessary.

## State management and dependency wiring

Use Riverpod 3.x for application/presentation state, dependency wiring, and asynchronous state where Flutter's local widget state is insufficient.

Rules:

- use Riverpod without code generation;
- do not put domain behavior inside providers merely because providers are convenient;
- keep transient widget-only state local to widgets when appropriate;
- use explicit repositories and application services for business operations;
- prefer fakes/in-memory implementations in tests over heavy mocking frameworks.

Riverpod is infrastructure. It must not become the domain model.

## Routing

Use `go_router` 18.x for application-level routing and navigation state.

Primary navigation:

```text
Today
Monthly
Future
Collections
Search
Index
```

Index remains a distinct method structure even when its entry point differs between compact and expanded layouts. Expanded layouts expose Search and Index directly in the navigation rail. Compact layouts keep Today, Monthly, Future, and Collections as direct bottom destinations and expose Search and Index through a minimal More sheet rather than crowding six bottom items.

Settings and contextual reflection flows are secondary navigation rather than permanent top-level destinations.

Route names and persisted domain values remain language-neutral.

The top-level journal shell uses `StatefulShellRoute.indexedStack`, so branch widgets may remain mounted while another section is active. This retained state is intentional for navigation continuity, but it creates a lifecycle requirement: a destination screen must not assume `initState()` runs again when the user returns.

`AppShell` publishes the active top-level section through the presentation-level `AppSectionScope`. Screens that cache journal snapshots and can be changed by another section must observe reactivation and reload the affected presentation state. Cross-surface writes must become visible when the destination section is re-entered without requiring lock, application restart, or widget remount.

Do not solve retained-tab freshness by destroying all branches, polling continuously, or moving journal semantics into the router. Section activation is presentation lifecycle; persistence and movement semantics remain below the UI boundary.

## Persistence

Drift 2.34.x is the typed relational persistence layer. The schema is declared under `lib/core/database/`, with exported schema snapshots versioned under `drift_schemas/`.

`package:sqlite3` 3.x provides the native SQLite interface and build-hook integration.

One encrypted database file represents one journal. Daymark does not multiplex independent journals inside a shared SQLite database. Future multiple-journal support should normally use separate encrypted files and independent journal keys so backup, deletion, transfer, and cryptographic isolation remain naturally journal-scoped.

Encrypted native storage uses SQLite3MultipleCiphers selected through the `sqlite3` build hook:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

This supersedes the earlier SQLCipher-first assumption and obsolete `sqlcipher_flutter_libs` direction.

The application verifies at runtime during database setup that the encrypted SQLite variant is loaded before opening journal data. Failure to provide expected cipher support is a startup security failure, not a reason to silently open plaintext SQLite.

The implemented database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode).

Each journal has 48 bytes of raw SQLite cipher material:

```text
32-byte random journal key || 16-byte random cipher salt
```

This is passed using SQLite3MultipleCiphers' ChaCha20 raw-key-plus-salt representation. The master password is never passed directly to SQLite3MultipleCiphers as a database passphrase.

Applying `PRAGMA key` alone is not treated as successful unlock. The database-opening layer performs a real `sqlite_master` read after configuring cipher/key so an incorrect key fails before an opened Drift database is returned.

The Drift open lifecycle is forced before `createNew()` returns so schema creation, built-in seed data, and connection initialization have actually occurred rather than leaking lazy-open behavior into the creation contract.

Password KDF parameters, salts, wrapped journal-key material, recovery metadata, and device-assisted unlock handles remain outside the encrypted Drift schema because they are needed before the database can be opened.

Database migrations must be explicit, versioned, forward-only in normal operation, fixture-tested, and safe against partial failure. Destructive schema changes require an explicit data migration strategy.

The initial schema is version 1. Drift exported-schema and `make-migrations` tooling are the normal migration path. While the project has no published prerelease user-data compatibility line, unreleased schema v1 may still be regenerated deliberately; once a prerelease is published, later supported builds must provide tested upgrade paths instead of silently resetting data.

Stable persisted identities use UUID v7.

### Chronological journal mapping

The schema already models Daily, Monthly, and Future Logs without parallel planner tables.

- Daily uses one `daily` log per method date.
- Monthly uses one `monthly` log per month plus explicit `monthly_section` and, for Calendar entries, `monthly_calendar_date`.
- Future uses one `future` log per represented month. Future placements do **not** use Monthly fields and are month-addressed rather than day-addressed.

The current Future screen's rolling six-month horizon is presentation/product behavior. It does not change persistence ownership or delete buckets outside the visible horizon.

Do not add a separate calendar schema merely to support Future UI.

## Journal application/session boundary

The unlocked-session abstraction is implemented and is no longer future architecture.

`JournalSession` owns the objects that are valid only while one journal is unlocked:

- the encrypted `DaymarkDatabase` connection;
- mutable `JournalKeyMaterial`;
- `JournalRepository` and `JournalService`;
- Task action services/repositories;
- focused Daily, Monthly, Future, Collection, Index, and Search repository/session boundaries.

All journal operations exposed through `JournalSession` are serialized. Once closing begins, new operations cannot enter the encrypted database; lock waits for queued/in-flight work, closes persistence, then destroys key material.

`JournalSessionManager` owns create/unlock/lock lifecycle and fails closed on incomplete database/envelope file sets. A failed create/unlock must not silently overwrite existing journal material.

Presentation code reaches journal behavior through focused data-source/provider boundaries backed by the unlocked session. Widgets do not coordinate multi-table persistence themselves.

Focused repositories are responsible for the semantic location they claim to represent. A repository must reject an owner of the wrong log kind rather than assuming every caller is correct. This is especially important when source and destination owners cross product surfaces.

The Collection boundary follows the same split: `CollectionRepository` owns focused Collection reads for both owned entries and references, and delegates semantic create/capture/reference writes to `JournalService`, while `JournalSession` serializes list/create/load/capture/reference operations with the rest of the unlocked journal lifecycle. Collection ownership, Collection references, and migration remain distinct domain operations rather than being collapsed into presentation helpers.

The Index uses a focused `IndexRepository` over the existing encrypted `index_items` schema. Presentation reaches it through `JournalIndexSession` extension methods, which serialize list/candidate/add operations with `JournalSession.run(...)` so Index I/O cannot escape the unlocked session lifetime. The repository owns target existence, duplicate prevention, and global ordinal allocation; the widget only presents existing candidates and the user's deliberate choice.

Search uses a focused read-only `JournalSearchRepository` against the existing encrypted schema. It joins Entries to their one owning placement and to the corresponding Log or Collection so results retain method-native context. The first implementation deliberately scans Entries in bounded ordered pages and performs Unicode-aware case-insensitive literal substring matching in Dart rather than relying on SQLite's ASCII-oriented `lower()` behavior or introducing an FTS table, Search cache, or schema v2; a submitted query returns at most 100 Entries ordered by most recent update. Presentation reaches Search through `JournalSearchSession`, so query I/O remains serialized inside `JournalSession.run(...)`.

Because Search is retained by `StatefulShellRoute.indexedStack`, `SearchScreen` keeps only its last submitted query as presentation state and observes `AppSectionScope` reactivation. Returning to Search reruns that query silently so a Task changed elsewhere does not keep a stale symbol/state. This is presentation freshness, not polling or persisted Search history. Search results remain read-only and do not reproduce Task/movement/reference semantics.

Forward Task migration to a Collection is exposed through `JournalSession.migrateTaskToCollection(...)`. The session first validates the persisted source as an open Task, then delegates to `JournalService.migrate(...)` with a `JournalCollectionOwner`. The presentation layer only lists existing Collections and records the user's deliberate choice; it does not create a destination or reproduce lineage rules.

Collection references are exposed through `JournalSession.referenceEntryInCollection(...)`. The serialized session delegates to the existing `JournalService.referenceInCollection(...)` transaction, so presentation only chooses an existing Collection and never changes source ownership, Entry identity, or Task state. `CollectionSnapshot` keeps owned entries and reference entries in separate read-model lists so the Collection UI cannot accidentally treat a reference as owned content or expose Task mutations through it.

Because Today, Monthly, or Future can now change a retained Collection while Collections is inactive, `CollectionsScreen` observes `AppSectionScope` reactivation and reloads both the Collection list and any selected Collection snapshot, including references. This is the same presentation-lifecycle rule already used by Future scheduling, not a new persistence cache.

Task scheduling is exposed through the serialized session rather than implemented inside Today/Monthly widgets. `JournalSession.scheduleTaskToFuture(...)` validates that the persisted source is an open Task before resolving/creating the Future destination, then delegates the actual movement and lineage semantics to the existing journal service/repository boundary. Invalid Task-only scheduling must fail before it creates a destination container or partial write.

Scheduling therefore has three distinct responsibilities:

1. presentation chooses a real visible Future month;
2. the session validates/unifies the unlocked serialized operation and resolves the real destination;
3. `JournalService` / `JournalRepository` perform the transactional source-state, destination-entry, placement, and lineage write.

Do not duplicate lineage rules in widgets/providers or invent a second movement service merely for UI convenience.

Widget tests use controlled in-memory presentation boundaries. Real filesystem, Argon2, encrypted SQLite, and lock/unlock persistence belong in repository/session/security tests when those boundaries are the subject being validated.

## Cryptographic application layer

Database encryption is only one layer of the security model.

Daymark uses the published `cryptography` package 2.9.0 for the application security baseline:

- Argon2id for master-password key derivation;
- XChaCha20-Poly1305 for authenticated wrapping of portable journal-key material.

Do not implement cryptographic primitives manually.

### Journal key material

`JournalKeyMaterial` owns:

- a 32-byte cryptographically random journal data-encryption key in overwrite-on-destroy `SecretKeyData`;
- a 16-byte random SQLite3MultipleCiphers salt in a private mutable buffer.

Its serialized representation is exactly 48 bytes and is compatibility-sensitive once prerelease journals exist.

The holder exposes explicit `destroy()` lifecycle. Owned mutable buffers are overwritten where practical, while `SECURITY.md` documents the limits of guaranteed zeroization under Dart/Flutter.

### Key envelope

The current key-envelope format is version 1 and remains outside the encrypted database.

It contains only pre-unlock metadata:

- format/version;
- Argon2id identifier, parameters, and random 16-byte KDF salt;
- XChaCha20-Poly1305 identifier;
- nonce;
- ciphertext containing the 48-byte serialized journal-key material;
- authentication tag.

Interpretation-sensitive metadata is authenticated as AAD. Parsing is strict and rejects unsupported format/KDF/AEAD identifiers.

Wrong password, modified ciphertext/nonce/tag, modified authenticated KDF metadata, malformed/truncated data, and unsupported identifiers are covered by negative-path tests.

Authentication failures use a generic journal-unlock error rather than password-quality hints.

### Argon2id parameters

The initial production baseline was frozen on 2026-09-02:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- output: 32 bytes;
- random KDF salt: 16 bytes per key envelope.

The decision followed profile-mode measurements on representative Linux and physical Android hardware. `tool/argon2_benchmark.dart`, `tool/argon2_profile_matrix.dart`, and `docs/ARGON2_BENCHMARK.md` preserve the evidence and retuning process.

Because envelope KDF metadata is untrusted before authentication, parser limits remain bounded to 64 MiB memory, 5 iterations, parallelism 4, and fixed 32-byte output. Those are defensive input ceilings, not production work factors.

KDF parameters are explicit versioned envelope data. Future defaults may be strengthened, but existing envelopes must remain interpretable through explicit compatibility paths once real prerelease journals exist.

### Recovery relationship

Recovery remains a portable credential over the same random journal key rather than a separate database-key hierarchy.

A future recovery secret may independently wrap/protect the existing serialized journal-key material. The final human representation and UX remain deferred, but recovery must never depend solely on Android Keystore, Linux keyring state, an account server, or the original device.

### Memory limitations

SQLite3MultipleCiphers' SQL `PRAGMA key` interface currently requires a hexadecimal Dart `String`. Mutable source buffers are overwritten after conversion, but immutable Dart strings cannot be reliably zeroized. This limitation is documented rather than hidden or "fixed" through speculative unsafe FFI.

Device-local assisted unlock requires a platform secure-storage abstraction but remains deferred. Whatever integration is eventually selected is a convenience layer only and must not become the sole portable recovery mechanism.

## Backup architecture

Manual full encrypted backup and restore are initial product requirements.

Backups must be encrypted by default, portable between supported platforms, independent of device-bound key stores, versioned, authenticated before restore, recoverable without the original device when portable credentials are available, and capable of evolving to include attachments without moving outside the security boundary.

Automatic backup scheduling, retention rotation, remote synchronization, and cloud-specific integrations are later concerns.

Human-readable Markdown or JSON export is a separate portability feature and may intentionally produce plaintext after explicit user action.

Android OS-managed app-data backup is not Daymark's portable-backup mechanism. Android backup/device-transfer domains are explicitly excluded; cross-device portability is designed through Daymark's own authenticated backup/restore boundary.

Authoritative backup details live in `docs/BACKUP_FORMAT.md` and security documents.

## Localization

Internationalization is part of the initial architecture.

Use Flutter's built-in localization tooling with ARB resources and generated localization accessors. Do not add a competing localization framework without concrete need.

English is the canonical source and fallback locale. Portuguese (Brazil) is the first additional product locale.

Resources:

```text
lib/l10n/
├── app_en.arb
├── app_pt.arb
└── app_pt_BR.arb
```

`app_pt.arb` exists because Flutter's localization generator requires a parent locale when `pt_BR` exists. It is a technical fallback, not a third product-language promise.

When ARB resources change, run `flutter gen-l10n` before analyzer/tests that compile presentation code. Generated localization accessors are build artifacts, not domain APIs to patch manually.

User-facing strings belong in localization resources. Domain values, persistence codes, migration logic, export identifiers, and application decisions remain language-neutral.

Layouts should use directional start/end concepts where practical to preserve future RTL support.

## File and platform integration

Prefer official Flutter-maintained plugins for routine platform integration when they satisfy the requirement.

Examples include:

- `path_provider` for application-owned filesystem locations;
- `file_selector` for explicit user-selected import/export/backup locations.

Platform-specific security behavior belongs behind interfaces under the platform/core boundary rather than leaking into journal domain objects.

## Code generation policy

Generated code increases coordination cost for agents and can obscure changes. Keep it limited.

Baseline:

- Drift generation is allowed and expected;
- Flutter `gen_l10n` generation is allowed and expected;
- Riverpod code generation is not used;
- Freezed is not a baseline dependency;
- `json_serializable` is not a baseline dependency.

Use normal Dart classes, sealed classes, records, patterns, and explicit serializers where the amount of code remains reasonable. Add more generation only when repeated real code demonstrates a benefit greater than tooling cost.

## Quality and analysis

Use Flutter's standard formatting and analysis tools.

The scaffold enables strict analyzer behavior for casts, inference, and raw types, with `flutter_lints` as the baseline.

The permanent `.github/workflows/ci.yml` gates:

1. dependency resolution from the committed lockfile;
2. localization generation;
3. Drift code generation;
4. Drift schema-snapshot freshness plus clean generated-artifact diff;
5. formatting;
6. static analysis;
7. unit, widget, schema-invariant, encrypted-persistence, and security tests;
8. Linux debug build;
9. Android debug APK build;
10. dependency/security review for pull requests.

Draft PRs run the lightweight `dev-check`. Ready/non-Draft PRs run full merge-tier jobs and `merge-gate`. Validation evidence is exact-head-specific.

## Testing strategy

Use Flutter/Dart's standard test infrastructure first:

- `flutter_test` for unit and widget tests;
- `integration_test` when a true end-to-end platform boundary is needed;
- Drift migration/schema tests with real fixtures;
- temporary encrypted databases for persistence/security tests where appropriate.

The initial schema has direct invariant tests against in-memory SQLite. Future versions must test target schema shape and representative data preservation across supported upgrades.

Security-sensitive flows require failure tests as well as success tests, including wrong password, corrupted key envelope, corrupted backup, incompatible schema, and missing encrypted-database support.

Cross-surface presentation behavior must test the actual navigation lifecycle when it is part of the bug. If a retained destination branch can be changed while inactive, a regression test should mutate the relevant data source while that section is inactive and prove it refreshes on reactivation without relying on remount, lock, or restart.

Performance/security parameters are not selected from shared CI runner timing. Future KDF retuning must follow the evidence-first physical-device/profile process.

Do not treat screenshot/golden testing as a substitute for behavioral tests. Add goldens selectively when the visual contract becomes stable enough to justify maintenance cost.

## Dependency and supply-chain policy

Applications commit `pubspec.lock`.

CI uses lockfile enforcement so dependency resolution cannot silently change beneath an unchanged commit.

Dependencies must come from stable published packages unless an explicit temporary exception is documented. Mutable Git dependencies are not acceptable production defaults.

GitHub Actions are pinned to immutable commit SHAs. Pull-request dependency review rejects introduced dependencies at the configured severity threshold according to repository policy.

## Development order

Daymark establishes correctness and safety before product polish.

The current dependency sequence is:

1. define Bullet Journal domain semantics and product/security constraints;
2. establish pinned Flutter scaffold and repeatable CI/build baseline;
3. establish relational schema, identifiers, and migration strategy;
4. implement and validate encryption/key management;
5. specify and validate encrypted portable backup/restore;
6. wire application/data/presentation boundaries;
7. build end-to-end Today/Daily flow;
8. add deliberate Task actions and lifecycle protection;
9. build real Monthly and Future destinations;
10. expose deliberate scheduling (`<`) from Today/Monthly Tasks into real Future destinations;
11. build a real minimal Collections surface as a non-Future method-native owning structure;
12. expose deliberate forward migration (`>`) from Today/Monthly open Tasks into an existing Collection, with retained-Collections refresh coverage;
13. continue Collection references, next-Monthly accessibility, Index, Search, backup UI, exports, platform hooks, accessibility, and packaging as separate focused slices.

Do not implement convenience features ahead of the contracts that govern their persistence and security.

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
- Rust/Tauri integration without measured need.

These must not leak into the core model as speculative abstractions.
