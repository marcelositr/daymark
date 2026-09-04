# Architecture

## Status

This document defines Daymark's current architectural constraints. Concrete package versions may evolve through reviewed dependency updates, but the boundaries and technology choices below are intentional.

The committed `pubspec.lock` is authoritative for the exact resolved dependency set on the current development line.

`v1.0.0-alpha.2` is the first controlled distributable prerelease. Its persisted schema/security/backup formats are now compatibility-sensitive boundaries rather than unreleased implementation details.

## Current toolchain baseline

Daymark is a Flutter application.

Current baseline:

- Flutter stable 3.47.2;
- Dart 3.13.2 supplied by Flutter;
- Linux and Android as initial runtime targets.

Flutter 3.47.2 is pinned in `.flutter-version` and `pubspec.yaml`. Future toolchain changes require a reviewed update rather than silently following the stable channel.

Android should target Flutter's supported Android baseline rather than deliberately supporting versions the framework itself no longer supports. API 24 is the minimum deployment level in the current architecture.

Future architectural targets may include Windows, macOS, and iOS. Web is not an initial target.

## Application structure

Daymark remains a single Flutter application until a concrete reason exists to split it into multiple packages.

Do not create a speculative monorepo, plugin system, server package, or independent domain package merely because those structures might someday be useful.

The codebase is domain-centric. Current core responsibilities include:

```text
lib/
├── app/
├── core/
│   ├── backup/
│   ├── crypto/
│   ├── database/
│   ├── export/
│   ├── session/
│   └── settings/
└── features/
    └── journal/
        ├── domain/
        ├── application/
        ├── data/
        └── presentation/
```

Exact subdirectory names may evolve, but these boundaries matter:

- journal domain semantics stay independent of Flutter/platform APIs;
- cryptography and encrypted persistence stay below presentation code;
- Backup / Restore and Open Export are separate portability boundaries;
- non-secret device/application preferences such as Appearance do not become journal-domain rows merely for convenience;
- platform file selection remains an edge integration, not a domain service.

Daily Log, Monthly Log, Future Log, Migration, Collections, Index, and Search belong to one coherent journal domain rather than pretending they are unrelated products.

## Domain concepts

The authoritative semantic rules are defined in `docs/DOMAIN.md`; the relational contract is `docs/DATA_MODEL.md`.

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

## UI foundation

Daymark uses Flutter Material 3 widgets/theming as a technical foundation, not as a requirement to look like a stock Material application.

The visual identity is a minimal dotted-notebook page with System / Light / Dark appearance. It is not a freeform canvas, page-layout editor, or drawing application.

Layouts are adaptive:

- compact layouts optimize for fast mobile capture;
- expanded layouts may use wider navigation and keyboard-oriented workflows;
- a desktop layout must not be squeezed unchanged into a phone.

Avoid external UI/theme frameworks until a specific unmet requirement proves they are necessary.

## State management and dependency wiring

Use Riverpod 3.x for application/presentation state, dependency wiring, and asynchronous state where local widget state is insufficient.

Rules:

- use Riverpod without code generation;
- do not put domain behavior inside providers merely because providers are convenient;
- keep transient widget-only state local when appropriate;
- use explicit repositories and application services for business operations;
- prefer fakes/in-memory implementations in tests over heavy mocking frameworks.

Riverpod is infrastructure, not the domain model.

## Routing and retained navigation

Use `go_router` 18.x for application routing/navigation state.

Primary concepts:

```text
Today
Monthly
Future
Collections
Search
Index
```

Expanded layouts expose all six directly. Compact layouts keep Today, Monthly, Future, and Collections directly visible and expose Search/Index through a minimal More entry. Grouping those controls never merges Search and Index semantically.

The top-level journal shell uses `StatefulShellRoute.indexedStack`; branch widgets may remain mounted while another section is active. A destination therefore must not assume `initState()` runs when the user returns.

`AppShell` publishes active top-level section state through `AppSectionScope`. A retained screen whose cached snapshot can be changed elsewhere reloads on reactivation. This currently protects:

- Future after scheduling from Today/Monthly;
- Collections after migration/reference actions elsewhere;
- Search after Task-state changes elsewhere.

Do not solve retained-tab freshness by destroying all branches, polling continuously, or moving persistence semantics into the router.

Historical Daily retrieval is contextual under Today. `/daily/:date` resolves a genuine method date through a non-creating repository/session read. Missing historical dates remain absent rather than creating persisted Logs. Historical Daily is read-only; `/` remains the interactive current Daily Log.

## Persistence

Drift 2.34.x is the typed relational persistence layer. Schema snapshots are versioned under `drift_schemas/`.

`package:sqlite3` 3.x provides the native SQLite interface and build-hook integration.

One encrypted database file represents one journal. Future multi-journal support should normally use separate encrypted files and independent journal keys rather than tenant IDs inside one database.

Encrypted storage uses SQLite3MultipleCiphers selected through the sqlite3 build hook:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

The application verifies at runtime that encrypted SQLite support is present before opening journal data. Missing cipher support is a security failure, never permission to open plaintext SQLite.

The implemented database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode).

Each journal has 48 bytes of raw SQLite cipher material:

```text
32-byte random journal key || 16-byte random cipher salt
```

The master password is never passed directly to SQLite3MultipleCiphers.

Applying `PRAGMA key` alone is not treated as successful unlock. The database-opening layer performs a real read after keying so an incorrect key fails before an opened Drift database is returned.

The initial schema is version 1 and is published in `v1.0.0-alpha.2`. The earlier pre-publication freedom to regenerate schema v1 no longer applies to supported releases. Future supported builds must use explicit forward migrations/compatibility code and fixture tests rather than resetting published user data.

Stable persisted identities use UUID v7.

`journal_metadata` is a singleton journal identity. New journals initialize it; alpha.2 also repairs older development journals with zero rows transactionally on unlock. More than one row remains corruption and fails closed.

### Chronological mapping

- Daily uses one `daily` Log per method date.
- Monthly uses one `monthly` Log per month plus explicit Calendar/Tasks placement fields.
- Future uses one `future` Log per represented month and is month-addressed, not day-addressed.

The rolling six-month Future screen is presentation/product behavior. It does not change persistence ownership or delete buckets outside the visible horizon.

## Journal session/application boundary

`JournalSession` owns objects valid only while one journal is unlocked:

- encrypted `DaymarkDatabase` connection;
- mutable `JournalKeyMaterial`;
- journal repositories/services;
- focused Daily, Monthly, Future, Collection, Index, and Search boundaries.

All operations exposed through the session are serialized. Once closing begins, no new operation enters encrypted persistence; lock waits for queued/in-flight work, closes persistence, then destroys owned key material.

`JournalSessionManager` owns create/unlock/lock lifecycle and fails closed on incomplete database/envelope file sets. A failed create/unlock must not silently overwrite existing journal material.

Presentation reaches journal behavior through focused boundaries backed by the unlocked session. Widgets do not coordinate multi-table persistence themselves.

Focused repositories validate the semantic owner/location they claim to represent rather than trusting every caller.

### Movement and references

Task scheduling is exposed through the session. Presentation chooses a real Future month; the session validates an open source Task and resolves the destination; journal service/repository code performs the transactional source-state, destination-entry, placement, and lineage write.

Forward migration to a Collection follows the same boundary. Presentation chooses an existing Collection; service/repository code owns lineage and transactional state changes.

Collection references are separate from migration. A referenced Entry keeps its identity, owner, content, and Task state; the Collection read model exposes references separately and read-only.

Do not duplicate movement/reference semantics in widgets/providers.

### Index and Search

Index uses the encrypted `index_items` schema and is a deliberate persisted structure. The repository owns target existence, duplicate prevention, and ordering.

Search is a focused read-only repository over the encrypted schema. It joins Entries to their owning placement/context and performs Unicode-aware case-insensitive literal matching without creating a plaintext side index, query history, references, or Index items.

Search currently retains only the last submitted query as presentation state and reruns it on section reactivation so results do not show stale Task state.

## Cryptographic application layer

Database encryption is only one layer of the security model.

Daymark uses the published `cryptography` package 2.9.0:

- Argon2id for master-password key derivation;
- XChaCha20-Poly1305 for authenticated wrapping of portable journal-key material.

Do not implement cryptographic primitives manually.

### Journal key material and key envelope

`JournalKeyMaterial` owns:

- a 32-byte random journal data-encryption key in overwrite-on-destroy `SecretKeyData`;
- a 16-byte random SQLite3MultipleCiphers salt in a private mutable buffer.

Its serialized representation is exactly 48 bytes. Because alpha.2 is published, this representation is now compatibility-sensitive.

The version-1 key envelope remains outside the encrypted database and contains only pre-unlock metadata: format/version, Argon2id parameters/salt, XChaCha20-Poly1305 identifier, nonce, ciphertext, and authentication tag. Interpretation-sensitive metadata is authenticated as AAD.

Wrong password, modified ciphertext/nonce/tag/KDF metadata, malformed/truncated data, and unsupported identifiers fail closed.

### Argon2id baseline

Initial production baseline frozen 2026-09-02:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- output: 32 bytes;
- random KDF salt: 16 bytes per key envelope.

`docs/ARGON2_BENCHMARK.md` and `docs/argon2-results/` preserve the evidence.

Parser ceilings for untrusted pre-authentication KDF metadata remain 64 MiB memory, 5 iterations, parallelism 4, and exactly 32-byte output. Those are defensive limits, not production targets.

A future KDF-default change may strengthen newly protected material, but existing published envelopes must remain interpretable through an explicit compatibility path.

### Memory limitations

SQLite3MultipleCiphers' SQL `PRAGMA key` path requires a hexadecimal Dart `String`. Mutable source buffers are overwritten after conversion where practical, but immutable Dart strings cannot be reliably zeroized. This limitation is documented rather than hidden or "fixed" through speculative unsafe FFI.

Device-local assisted unlock remains deferred and is a convenience layer only. It must never become the sole portable recovery mechanism.

## Backup / Restore architecture

Manual full encrypted Backup / Restore is implemented and user-facing.

Backups are encrypted, authenticated, versioned, portable across supported platforms, and independent of device-bound key stores. Restore validates before replacement and is exposed only while the destination journal is locked or absent.

`docs/BACKUP_FORMAT.md` is authoritative for the container and rollback-safety contract.

Important memory-boundary precision: the backup service streams the encrypted database payload while creating/validating the container, but the current native file-save gateway may buffer the completed **encrypted container** before handing it to the platform save API. Do not describe the UI save path as streaming end-to-end.

Automatic backup scheduling, retention rotation, remote synchronization, and cloud integrations remain later concerns.

## Open Export architecture

Open Export is implemented as a separate plaintext portability boundary.

- JSON is deterministic, versioned, machine-readable, and preserves stable IDs/relationships.
- Markdown is human-readable.
- both represent one transactionally consistent journal snapshot;
- both are explicit user actions;
- neither is encrypted;
- neither is a restore/import contract.

`docs/OPEN_EXPORT_FORMAT.md` is authoritative for format version 1, which shipped in alpha.2.

## Device/application settings

Appearance System / Light / Dark is non-secret application/device state outside the encrypted journal schema. It applies while the journal is locked and persists independently of journal content.

Do not move application preferences into journal relational tables merely to simplify state wiring. Security-sensitive future settings must still follow `SECURITY.md`.

## Localization

Use Flutter ARB / generated localization accessors. English is canonical/fallback; Portuguese (Brazil) is the first additional product locale.

Resources:

```text
lib/l10n/
├── app_en.arb
├── app_pt.arb
└── app_pt_BR.arb
```

`app_pt.arb` exists because Flutter's generator requires a parent locale when `pt_BR` exists; it is a technical fallback, not another product-language promise.

When ARB resources change, run `flutter gen-l10n` before analyzer/tests that compile presentation code.

Domain values, persistence codes, migration logic, export identifiers, and application decisions remain language-neutral. Layouts should use directional start/end concepts where practical to preserve future RTL support.

## File and platform integration

Prefer maintained Flutter/platform packages for routine integration when they satisfy the requirement. Current file-provider behavior is an edge responsibility and must preserve the security/session boundary defined by Backup / Restore and Open Export.

Platform-specific security behavior belongs behind core/platform interfaces rather than leaking into journal domain objects.

## Code generation policy

Generated code is intentionally limited:

- Drift generation is allowed/expected;
- Flutter `gen_l10n` is allowed/expected;
- Riverpod code generation is not used;
- Freezed is not a baseline dependency;
- `json_serializable` is not a baseline dependency.

Use normal Dart classes/sealed classes/records/patterns/explicit serializers when reasonable. Add more generation only when repeated real code demonstrates a benefit greater than tooling cost.

## Quality and CI

The permanent CI validates the applicable tier of:

1. dependency resolution from committed lockfile;
2. localization generation;
3. Drift code generation;
4. schema-snapshot freshness / clean generated-artifact diff;
5. formatting;
6. static analysis;
7. tests;
8. Linux build;
9. Android build;
10. pull-request dependency/security review;
11. `merge-gate` for Ready PRs.

Draft PRs may run lightweight `dev-check`. Agreed local-first validation may be the fast implementation loop, but final Ready/non-Draft CI remains the independent merge gate where required. Evidence is exact-head-specific.

Widget tests use controlled presentation boundaries. Real filesystem, Argon2, encrypted SQLite, backup/restore, and lock/unlock persistence belong in repository/session/security/integration tests when those are the behavior under test.

Performance/security parameters are not selected from shared CI timing. KDF retuning follows physical-device/profile evidence.

## Dependency and supply-chain policy

Applications commit `pubspec.lock`; CI enforces the lockfile.

Dependencies must come from stable published packages unless an explicit temporary exception is documented. Mutable Git dependencies are not acceptable production defaults.

GitHub Actions are pinned to immutable commit SHAs. Pull-request dependency review rejects introduced dependencies at the configured severity threshold according to repository policy.

## Current development order

The product foundation through public alpha.2 is complete:

1. product/domain/security constraints and pinned Flutter scaffold;
2. schema v1 and encrypted persistence/key management;
3. Argon2id baseline and authenticated key envelope;
4. journal session/lifecycle and inactivity lock;
5. Today/Daily, Monthly, Future, scheduling, Collections, migration/references, Index, Search, and history retrieval;
6. user-facing encrypted Backup / Restore;
7. explicit plaintext Open Export;
8. System / Light / Dark Appearance;
9. release packaging/signing hardening and physical Linux/Android validation;
10. public `v1.0.0-alpha.2` prerelease.

The vacation-ready stabilization sequence is finished. Do not keep implementing from that release branch or pull multiple deferred features forward as one follow-up.

No next alpha feature slice is selected yet. Candidate later focused slices include direct retrieval navigation from Index/Search, richer Reflection, OS-level immediate-lock integration, device-assisted unlock, reference removal, Index reorder/remove, accessibility/keyboard refinements, and eventually broader platform/portability work.

## Non-goals for the initial architecture

The initial v1 architecture does not require:

- backend server or mandatory accounts;
- cloud synchronization;
- collaboration/distributed conflict resolution;
- plugin infrastructure;
- AI services inside the product;
- freeform canvas/page-layout editing;
- multi-package workspace;
- parallel generic planner/task-management subsystem;
- Rust/Tauri integration without measured need.

These must not leak into the core model as speculative abstractions.
