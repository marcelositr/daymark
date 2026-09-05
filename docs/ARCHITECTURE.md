# Architecture

## Status

This document defines Daymark's current architectural constraints.

Daymark's functional product scope is frozen. Architecture maintenance exists to preserve the current Linux/Android product safely and correctly, not to reserve or scaffold future product capabilities.

Concrete package/toolchain versions may change through reviewed maintenance updates when required for compatibility, security, or supported-platform operation. The committed `pubspec.lock` is authoritative for the exact resolved dependency set.

Published schema/security/backup/export/signing boundaries are compatibility-sensitive and must not be reset or silently reinterpreted.

## Toolchain and supported platforms

Daymark is a Flutter application.

Current baseline:

- Flutter stable 3.47.2;
- Dart 3.13.2 supplied by Flutter;
- Linux and Android as the supported product runtime targets;
- Android minimum deployment API 24 in the current architecture.

Flutter is pinned through `.flutter-version` / `pubspec.yaml`. Toolchain changes require a reviewed maintenance reason rather than silently following a channel.

Windows, macOS, iOS, web, and other additional product platforms are not planned under the product freeze. Platform-independent domain/application boundaries remain valuable for code quality and maintainability, but they are not a promise of future ports.

## Application structure

Daymark remains one Flutter application.

Do not introduce a speculative monorepo, plugin system, server package, independent backend, or extra product architecture.

Current responsibilities are organized around:

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

Durable boundaries:

- journal domain semantics stay independent of Flutter/platform APIs;
- cryptography/encrypted persistence stay below presentation code;
- Backup / Restore and Open Export remain separate portability/security boundaries;
- non-secret application/device preferences such as Appearance remain outside journal-domain rows;
- platform file selection remains an edge integration;
- widgets/providers do not own cross-table persistence semantics.

Today/Daily, Monthly, Future, Collections, Index, Search, Migration, Reflection, and Trackers are parts of one coherent frozen journal product.

## Domain concepts

The authoritative semantic rules live in `docs/DOMAIN.md`; relational persistence rules live in `docs/DATA_MODEL.md`; product scope lives in `docs/PRODUCT.md`.

Entry type, Task state, signifiers, storage location, Collection references, Tracker state, and migration lineage remain separate concerns.

Do not add new domain concepts in maintenance work unless a schema/security/compatibility repair strictly requires a representation change that preserves existing user behavior.

## UI foundation

Daymark uses Flutter Material 3 as a technical foundation, not as a stock visual identity.

The implemented visual system includes:

- System / Light / Dark appearance;
- shared Daymark design tokens/controls;
- compact Android and bounded desktop page framing;
- adaptive navigation;
- restrained notices/empty states;
- Linux keyboard/focus behavior;
- accessibility semantics;
- Daymark branding and About/support surface.

The notebook/sketchbook metaphor is visual, not structural. Daymark is not a freeform canvas, drawing application, page-layout editor, dashboard, or generic planner.

Do not add external UI/theme frameworks unless a concrete maintenance defect cannot reasonably be solved with the existing Flutter/Daymark layer.

## State management and dependency wiring

Use Riverpod 3.x for application/presentation state, dependency wiring, and asynchronous state where local widget state is insufficient.

Rules:

- Riverpod without code generation;
- domain behavior does not live inside providers merely for convenience;
- transient widget-only state stays local when appropriate;
- repositories/application services own business operations;
- tests prefer fakes/in-memory implementations over heavy mocking frameworks.

Riverpod is infrastructure, not the domain model.

## Routing and retained navigation

Use `go_router` 18.x.

Primary journal navigation concepts are fixed:

```text
Today
Monthly
Future
Collections
Search
Index
```

Expanded layouts expose all six directly. Compact layouts keep Today, Monthly, Future, and Collections directly visible and expose Search/Index through More.

The top-level shell uses `StatefulShellRoute.indexedStack`, so branch widgets may remain mounted while inactive. A destination cannot assume `initState()` runs when the user returns.

`AppSectionScope` publishes active section state. Existing retained sections reload on reactivation where cross-surface writes can make their presentation stale, including Future, Collections, Search, and Tracker-related Today/Monthly state.

Do not solve retained-tab freshness by destroying all branches, polling continuously, or moving persistence semantics into routing.

Historical Daily/Monthly/Future retrieval uses the existing real routes/read-only product boundaries and never creates missing chronology merely through viewing.

## Persistence

Drift 2.34.x is the typed relational layer. Schema snapshots are versioned under `drift_schemas/`.

`package:sqlite3` 3.x provides the native SQLite interface/build-hook integration.

One encrypted database file represents one journal. Multi-journal product support is not planned under the freeze.

Encrypted storage uses SQLite3MultipleCiphers selected through the sqlite3 build hook:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

The application verifies encrypted SQLite support before opening journal data. Missing cipher support fails safely and never permits plaintext fallback.

The database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode).

Each journal uses:

```text
32-byte random journal key || 16-byte random cipher salt
```

The master password is never passed directly to SQLite3MultipleCiphers.

Applying `PRAGMA key` is not considered successful unlock by itself. A real database read verifies the keyed database before an opened Drift database is returned.

### Schema compatibility

Schema v1 was published in `v1.0.0-alpha.2`.

Current schema v2 adds Trackers/Tracker marks through an explicit tested additive migration. Published data is never reset/regenerated to avoid migration work.

Stable persisted identities use UUID v7.

`journal_metadata` is a singleton journal identity. New journals initialize it; older development journals with zero rows are repaired idempotently on unlock; more than one row is corruption and fails closed.

Any schema maintenance change must have a concrete compatibility/bug/security reason plus migration fixtures/tests for every supported predecessor it affects.

### Chronological mapping

- Daily: one `daily` Log per method date.
- Monthly: one `monthly` Log per month plus Calendar/Tasks placement fields.
- Future: one `future` Log per represented month, month-addressed rather than day-addressed.
- Trackers: separate finite entities/marks, not Entry ownership.

The rolling six-month Future screen is presentation behavior and does not delete persisted buckets outside the visible horizon.

## Journal session/application boundary

`JournalSession` owns objects valid only while one journal is unlocked:

- encrypted `DaymarkDatabase` connection;
- mutable `JournalKeyMaterial`;
- journal repositories/services;
- focused presentation data-source boundaries.

Session operations are serialized. Once closing begins, no new operation enters encrypted persistence. Lock waits for queued/in-flight work, closes persistence, then destroys owned key material.

`JournalSessionManager` owns create/unlock/lock lifecycle and fails closed on incomplete database/envelope file sets. Failed create/unlock must not overwrite existing journal material.

Focused repositories validate the semantic owner/location they represent instead of relying only on caller correctness.

### Movement and references

Scheduling and migration use the frozen method-native destinations:

- scheduling (`<`) selects a real Future month;
- forward migration (`>`) selects an existing Collection;
- source Task history/state and destination lineage are written transactionally;
- Collection references are distinct from migration and retain source Entry ownership/identity/state.

Do not add migration/reference destinations or duplicate semantics in widgets/providers under maintenance work.

### Index and Search

Index uses encrypted `index_items` and is a deliberate persisted catalog.

Search is read-only over the encrypted schema, performs the existing Unicode-aware case-insensitive literal matching, and creates no plaintext side index, query history, reference, or Index item.

Richer Search/indexing/ranking/filtering is not planned under the frozen product scope.

## Cryptographic application layer

Daymark uses `cryptography` 2.9.0:

- Argon2id for master-password key derivation;
- XChaCha20-Poly1305 for authenticated wrapping of portable journal key material.

Do not implement cryptographic primitives manually.

### Journal key material and key envelope

`JournalKeyMaterial` owns:

- 32-byte random journal data-encryption key in overwrite-on-destroy `SecretKeyData`;
- 16-byte random SQLite3MultipleCiphers salt in a private mutable buffer.

Serialized representation is exactly 48 bytes and is compatibility-sensitive.

Version-1 key envelope contains only pre-unlock metadata: format/version, Argon2id parameters/salt, XChaCha20-Poly1305 identifier, nonce, ciphertext, and authentication tag. Interpretation-sensitive metadata is authenticated as AAD.

Wrong password, modified ciphertext/nonce/tag/KDF metadata, malformed/truncated data, and unsupported identifiers fail closed.

### Argon2id baseline

Production baseline frozen 2026-09-02:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- output: 32 bytes;
- random KDF salt: 16 bytes per envelope.

`docs/ARGON2_BENCHMARK.md` preserves evidence.

Parser ceilings for untrusted KDF metadata remain 64 MiB memory, 5 iterations, parallelism 4, and exactly 32-byte output. They are defensive limits, not production targets.

A security maintenance release may strengthen new material only when a concrete security need justifies it, while existing published envelopes remain interpretable through explicit compatibility handling.

### Memory limitations

SQLite3MultipleCiphers' SQL `PRAGMA key` path requires a hexadecimal Dart `String`. Mutable source buffers are overwritten after conversion where practical, but immutable Dart strings cannot be reliably zeroized.

This limitation is documented rather than hidden or "fixed" through speculative unsafe FFI.

Device-assisted/biometric unlock is not planned under the frozen scope. The portable master-password model is the Daymark unlock architecture.

## Backup / Restore architecture

Manual full encrypted Backup / Restore is implemented and user-facing.

Backups are encrypted, authenticated, versioned, portable across supported Linux/Android targets, and independent of device-bound key stores. Restore validates before replacement and is exposed only while the destination journal is locked or absent.

`docs/BACKUP_FORMAT.md` is authoritative for container/rollback safety.

The backup service streams encrypted database payload during container creation/validation; the current native file-save gateway may buffer the completed **encrypted container** before platform save.

Automatic backup scheduling/retention, remote synchronization, and cloud integration are not planned under the frozen scope.

## Open Export architecture

Open Export is a separate plaintext portability boundary.

- JSON is deterministic, versioned, machine-readable, and preserves stable IDs/relationships.
- Markdown is human-readable.
- both represent one transactionally consistent journal snapshot;
- both require explicit user action and master-password reauthentication before plaintext creation;
- both may be saved or copied to clipboard;
- neither is encrypted;
- neither is a restore/import contract.

`docs/OPEN_EXPORT_FORMAT.md` is authoritative.

## Device/application settings

Appearance System / Light / Dark is non-secret application/device state outside the encrypted journal schema. It applies while locked and persists independently of journal content.

Do not move preferences into journal tables merely to simplify state wiring.

No new settings/convenience surfaces are planned under the product freeze.

## Localization

Use Flutter ARB/generated localization accessors.

Supported product languages are fixed:

- English canonical/fallback;
- Portuguese (Brazil).

Resources:

```text
lib/l10n/
├── app_en.arb
├── app_pt.arb
└── app_pt_BR.arb
```

`app_pt.arb` is a technical parent-locale fallback required by Flutter generation and does not expand the supported language promise.

When ARB resources change, run `flutter gen-l10n` before analyzer/tests that compile presentation code.

Domain values, persistence codes, migration logic, export identifiers, and application decisions remain language-neutral.

Additional language support/RTL product work is not planned under the freeze.

## File and platform integration

Prefer maintained Flutter/platform packages for routine integration when they satisfy a concrete maintenance requirement.

Platform-specific behavior stays behind edge/core interfaces rather than leaking into journal domain objects.

New external integrations are not introduced as speculative capability.

## Code generation policy

Generated code is intentionally limited:

- Drift generation is expected;
- Flutter `gen_l10n` is expected;
- Riverpod code generation is not used;
- Freezed is not baseline;
- `json_serializable` is not baseline.

Use normal Dart classes/sealed classes/records/patterns/explicit serializers when reasonable. Add generation only when a maintenance need demonstrates benefit greater than tooling cost.

## Quality and CI

Permanent CI validates the applicable tier of:

1. dependency resolution from committed lockfile;
2. localization generation;
3. Drift generation;
4. schema-snapshot freshness / generated-artifact cleanliness;
5. formatting;
6. static analysis;
7. tests;
8. Linux build;
9. Android build;
10. pull-request dependency/security review;
11. `merge-gate` for Ready PRs.

Draft PRs may use lightweight checks. Agreed local-first validation may be the implementation loop, but final required Ready CI remains an independent exact-head merge gate.

Widget tests use controlled presentation boundaries. Real filesystem, Argon2, encrypted SQLite, Backup/Restore, and lock/unlock persistence belong in appropriate lower-layer/integration tests.

## Dependency and supply-chain policy

Applications commit `pubspec.lock`; CI enforces the lockfile.

Dependencies come from stable published packages unless an explicit temporary maintenance exception is documented. Mutable Git dependencies are not acceptable production defaults.

GitHub Actions are pinned to immutable commit SHAs.

Dependency changes require compatibility/security/license review and must not introduce a new product capability under the freeze.

## Frozen architecture non-goals

Daymark does not plan architectural expansion for:

- backend server or mandatory accounts;
- cloud synchronization;
- collaboration/distributed conflict resolution;
- plugin infrastructure;
- AI services;
- freeform canvas/page layout;
- multi-package workspace;
- parallel generic planner/task subsystem;
- additional platforms/languages;
- biometric/device-assisted unlock;
- recovery-secret subsystem;
- automatic backup scheduling;
- richer Search/indexing product systems;
- Rust/Tauri integration without a concrete maintenance necessity.

Do not leak these concepts into the codebase as speculative abstractions.

## Maintenance architecture rule

A post-freeze architectural change must answer all of the following:

1. What existing defect, vulnerability, compatibility failure, platform/toolchain breakage, or release problem requires it?
2. Why is a smaller correction insufficient?
3. How does the change preserve the frozen product behavior?
4. What compatibility/security boundaries are affected and tested?

Without a concrete maintenance reason, the architecture should remain stable.
