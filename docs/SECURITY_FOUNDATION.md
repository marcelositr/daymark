# Security foundation validation

## Status

This document is the historical validation record for security-foundation PR #7. It preserves the scope, evidence, and decisions established by that cycle and is not the canonical source for Daymark's current feature/implementation status.

For the current project state, read `PROJECT.md`. For the current security contract, read `SECURITY.md`. Later work has implemented capabilities that this historical record correctly lists as outside PR #7, including automatic inactivity locking and the encrypted portable backup/restore container.

## Purpose

This document defines the focused implementation and validation cycle that turns Daymark's security architecture into tested engineering constraints.

`SECURITY.md` remains the authoritative threat model and product security contract. This document is narrower: it records what PR #7 proves before Daymark treats master-password unlock, encrypted journal persistence, recovery compatibility, portable key handling, and the initial password-KDF baseline as established engineering constraints.

The goal is not to invent cryptography. The goal is to compose mature primitives correctly, make failure explicit, and keep portable recovery independent from device-local convenience mechanisms.

## Scope of this cycle

PR #7 validates, with executable tests where practical:

1. cryptographically secure generation of random journal data-encryption key material;
2. master-password key derivation using Argon2id;
3. a versioned authenticated key-envelope format outside the encrypted Drift database;
4. wrapping and unwrapping the journal key without storing the master password;
5. opening a SQLite3MultipleCiphers-backed journal only after successful key recovery;
6. proving that the on-disk journal database is not readable as plaintext SQLite;
7. wrong-password and corrupted-envelope failure behavior;
8. explicit key-material lifecycle boundaries in application code;
9. an independent offline-recovery architecture at the same portable trust layer as the master password;
10. profile-mode KDF benchmarking on representative Linux and physical Android hardware;
11. deliberate exclusion of Daymark app-private state from Android OS-managed cloud backup and device transfer.

## Explicitly not in this cycle

This security-foundation PR does not implement:

- biometric UI;
- Android Keystore integration;
- Linux Secret Service integration;
- automatic locking timers or lifecycle UI;
- the final encrypted backup archive/container format;
- cloud storage;
- synchronization;
- journal product screens.

These bullets describe the boundary of PR #7, not the current repository feature set. Automatic inactivity locking and the encrypted backup/restore container were implemented in later work; device-assisted unlock remains deferred.

Device-assisted unlock remains a convenience layer and will be connected only after the portable master-password/recovery path works independently.

The encrypted Daymark backup container was the next focused security task after this cycle. Its current authoritative format/safety contract lives in `docs/BACKUP_FORMAT.md`.

## Validated implementation baseline

PR #7 uses the published Dart `cryptography` package 2.9.0 for application-level cryptography and `package:sqlite3` with SQLite3MultipleCiphers for encrypted persistence.

The implemented hierarchy is:

```text
master password
      |
      v
Argon2id + random 16-byte salt + explicit parameters
      |
      v
32-byte password-derived key-encryption key
      |
      v
XChaCha20-Poly1305 authenticated key envelope
      |
      v
32-byte random journal data-encryption key
+ 16-byte random SQLite3MC cipher salt
      |
      v
SQLite3MultipleCiphers ChaCha20-Poly1305 journal database
```

The master password is never stored and is never passed directly to SQLite3MultipleCiphers.

Changing the master password re-protects the random journal key material rather than requiring semantic journal data to be rewritten.

## Key-envelope v1

Unlock metadata must exist before the encrypted database can be opened, so the key envelope remains outside the Drift journal schema.

Version 1 is a strict JSON object whose interpretation-sensitive metadata is authenticated by XChaCha20-Poly1305 additional authenticated data.

Top-level fields:

- `format`: `daymark-key-envelope`;
- `version`: `1`;
- `kdf`;
- `wrap`.

`kdf` fields:

- `name`: `argon2id`;
- `memoryKiB`;
- `iterations`;
- `parallelism`;
- `hashLength`;
- `salt`: base64url-encoded random 16-byte salt.

`wrap` fields:

- `name`: `xchacha20-poly1305`;
- `nonce`;
- `ciphertext`;
- `mac`.

The encrypted payload is the 48-byte serialized journal-key material used by SQLite3MultipleCiphers: 32 bytes of random journal key followed by 16 bytes of random cipher salt.

Unknown or extra envelope fields are not silently ignored. Unsupported envelope versions or KDF/AEAD identifiers fail explicitly.

No envelope field contains journal content, the master password, or plaintext journal-key material.

## Password derivation

Argon2id is implemented through `cryptography` 2.9.0.

Tests prove that:

- same password + same salt + same parameters derives the same key material;
- changing salt changes derived key material;
- changing password fails authenticated unwrap;
- unsupported/malformed KDF metadata fails closed before journal data is opened.

### Frozen initial production parameters

Frozen on 2026-09-02 after representative profile-mode review:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- hash length: 32 bytes;
- KDF salt: random 16 bytes per envelope.

The reproducible procedure, raw matrix evidence, and decision rationale are in `docs/ARGON2_BENCHMARK.md` and `docs/argon2-results/`.

The review used:

- Debian 13 on an Intel Core i5-2400;
- Samsung SM-A015M / Galaxy A01-class Android hardware;
- M7 3G PLUS Android 8.1 ARM32 hardware as an intentionally conservative old-device point.

The OWASP-listed lower-memory/higher-iteration tradeoffs were also measured. They produced no meaningful Linux improvement and only modest Android reductions. Daymark therefore retains 19 MiB / 2 rather than lowering memory hardness simply to make the oldest tested device somewhat faster.

The selected values remain explicit envelope metadata. Future Daymark releases may strengthen new envelopes, but published journal compatibility must be handled deliberately.

### Untrusted metadata bounds

Argon2 parameters are parsed from unauthenticated envelope metadata before authenticated unwrap can occur. They cannot be allowed to request arbitrary memory/work costs.

The defensive ceilings are:

- memory: 64 MiB;
- iterations: 5;
- parallelism: 4;
- hash length: exactly 32 bytes.

These are parser safety ceilings, not production targets.

## Authenticated key wrapping

The key envelope uses `Xchacha20.poly1305Aead()` from the published `cryptography` package.

Tests cover:

- successful wrap/unwrap;
- wrong password;
- modified ciphertext;
- modified nonce;
- modified authentication tag;
- modified authenticated KDF metadata;
- truncated ciphertext payload;
- unsupported envelope version;
- unsupported KDF identifier;
- unreasonable Argon2 parameters rejected before allocation/derivation.

Authentication failures map to the generic `JournalUnlockException`; failure reporting does not reveal password-quality hints.

The application does not attempt recovery by opening the journal with guessed/default parameters.

## Encrypted SQLite validation

The build selects SQLite3MultipleCiphers through the `sqlite3` build hook:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

Runtime initialization checks that `PRAGMA cipher` is available before opening journal data. Missing encrypted-SQLite support is a security failure, not permission to create a plaintext fallback.

Daymark selects the SQLite3MultipleCiphers ChaCha20 cipher and supplies raw material using the documented 48-byte ChaCha20 raw-key-plus-salt form:

```text
32-byte journal key || 16-byte cipher salt
```

`PRAGMA key` does not prove that a key is correct. Daymark therefore performs an actual read from `sqlite_master` after keying the connection before it returns an opened journal.

Executable tests prove that:

- a newly created Drift journal is fully initialized before `createNew()` returns;
- reopening with the correct journal key succeeds;
- reopening with an incorrect journal key fails;
- ordinary unkeyed SQLite cannot read the journal schema/content;
- representative sensitive content does not appear verbatim in the database file;
- normal Drift schema constraints remain active through encrypted persistence.

The negative path for a build that genuinely lacks SQLite3MultipleCiphers remains enforced by implementation code. Producing that exact missing-library environment inside the normal CI matrix is not required if doing so would introduce a test-only native-library architecture; the runtime check itself remains mandatory.

## Android OS-backup boundary

Android's default application backup behavior is not an acceptable implicit migration path for Daymark journal state.

The main manifest explicitly sets:

```text
android:allowBackup="false"
android:fullBackupContent="@xml/backup_rules"
android:dataExtractionRules="@xml/data_extraction_rules"
```

The Android 11-and-earlier backup rules exclude all supported app-data domains. The Android 12+ extraction rules exclude all supported domains from both cloud backup and device transfer.

This has two purposes:

1. keep app-private journal/security state out of opaque OS-managed backup and migration flows;
2. make Daymark's explicit encrypted portable backup/restore mechanism the intended cross-device path.

The journal remains independently encrypted, so Daymark does not treat these platform flags as a substitute for cryptography.

This boundary was made explicit after physical-device benchmarking exposed Android's default backup behavior: an OS full-backup job included Daymark and terminated the running benchmark process. The interruption was traced to platform backup rather than an Argon2 crash or out-of-memory condition.

## Recovery direction

Recovery remains optional, offline, and account-independent.

A recovery secret independently protects the same random journal key material that the master password protects. It must not depend on the original device, Android Keystore, Linux keyring state, a server account, or a maintainer-controlled secret.

The final human representation and recovery UX are deliberately deferred. PR #7 establishes that the random journal key is independent from the password and can therefore be wrapped by more than one authorized portable credential without changing the encrypted database key.

No server reset, maintainer backdoor, or hidden universal recovery mechanism is permitted.

## Sensitive-memory discipline

Dart and Flutter do not provide a universal guarantee that secret bytes can be securely zeroized from all runtime copies. The implementation therefore avoids pretending stronger guarantees than the runtime provides.

Current practical boundaries:

- journal key bytes are held in overwrite-on-destroy `SecretKeyData`;
- owned mutable serialized key buffers are overwritten after use where practical;
- journal-key material has an explicit `destroy()` lifecycle;
- its owned cipher-salt buffer is overwritten on destroy;
- unnecessary temporary key copies are avoided;
- passwords, keys, decrypted content, and recovery material are never logged or persisted as diagnostics.

SQLite3MultipleCiphers currently receives the raw key through SQL `PRAGMA key`, which requires hexadecimal representation as a Dart `String`. Dart strings are immutable and cannot be reliably zeroized by application code. The mutable raw byte buffer is overwritten after conversion, but Daymark explicitly does not claim guaranteed erasure of the runtime string copy.

This limitation must not be "fixed" by introducing unsafe FFI without a measured need and a separately reviewed safety case.

## Key/session boundary established for later lifecycle work

`JournalKeyMaterial` is the narrow owner of unlocked journal key material and exposes an explicit destroy lifecycle.

PR #7 established that later manual/automatic lock work must own that object through a session-level abstraction rather than global/static state. Subsequent work implemented `JournalSession`, manual locking, and automatic inactivity locking under that constraint. Current lifecycle details therefore live in `PROJECT.md`, `docs/ARCHITECTURE.md`, and `SECURITY.md` rather than being redefined here.

## Test boundary

Security tests use synthetic secrets and disposable databases only.

CI must never require real user credentials or committed secret material.

Tests distinguish:

- expected authentication/unlock failure;
- unsupported-format failure;
- corrupted-data failure;
- missing cipher support;
- programming/configuration errors.

## PR #7 completion gates

This section records the historical completion gate for PR #7 and is retained as validation history rather than current work.

The implementation and physical benchmark evidence were established before merge. The reviewed cycle required:

1. keeping `SECURITY.md`, `docs/ARCHITECTURE.md`, `docs/ARGON2_BENCHMARK.md`, `PROJECT.md`, README status, and the PR checklist aligned with the frozen initial KDF decision and Android backup boundary;
2. final green CI on the reviewed head;
3. user review;
4. merge only after explicit user request.

## Review rule

A security-format decision is a compatibility decision.

Once a prerelease containing real user journals is published, changing the key-envelope format, KDF interpretation, database-key representation, recovery wrapping, or backup cryptography requires an explicit tested compatibility/migration path. Failure to unlock old data is data loss even when the encrypted database itself remains intact.
