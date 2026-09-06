# Security Policy

## Supported versions

Daymark is prerelease software.

The currently supported public line is the latest published prerelease, `1.0.0-beta.1+4` / `v1.0.0-beta.1`, published on 2026-09-06, plus current `main` for maintenance validation. Older prereleases and development builds are unsupported unless a release note explicitly says otherwise.

`1.0.0-beta.2+5` is the active maintenance release candidate for stabilization validation. Until it is explicitly published, `v1.0.0-beta.1` remains the latest supported public prerelease.

Beta.2 must preserve the Android signing lineage shared by alpha.3 and beta.1 and the existing supported journal/security/data formats. Promotion does not change Daymark's frozen security product boundary.

Because `v1.0.0-alpha.2` has been published for real user journals, its persisted security/data formats are compatibility-sensitive. A later supported build must not silently make an alpha.2 journal, key envelope, encrypted backup, or documented migration path unreadable. Android install-over from alpha.2 to alpha.3 is not claimed because the alpha.2 private signing key is unavailable; the supported transition is explicit encrypted Backup / clean install / Restore as documented in `docs/RELEASE.md`.

## Frozen security product boundary

Daymark's functional product scope was frozen on 2026-09-05.

Security maintenance remains mandatory, but the freeze means security work is aimed at **protecting the product that already exists**, not adding convenience features or new trust models.

The following are not planned Daymark capabilities under the freeze:

- device-assisted or biometric unlock;
- Android Keystore/Linux keyring convenience unlock layers;
- recovery-secret UX;
- account-based password reset, maintainer recovery, or backdoors;
- cloud/network/account features;
- automatic remote synchronization;
- attachments;
- plaintext/full-text shadow indexes;
- automatic backup scheduling/retention systems.

If a concrete vulnerability requires a change to cryptographic parameters, dependencies, storage handling, platform integration, or formats, that is permitted maintenance only when it uses an explicit reviewed compatibility/migration path and preserves supported user data.

Historical security-foundation documents may describe some of the capabilities above as future/deferred. Those references are historical context, not an active roadmap.

## Reporting a vulnerability

Please do not disclose exploitable vulnerabilities in a public issue before a fix is available.

If private vulnerability reporting is enabled for this repository, use GitHub's private vulnerability reporting flow. Otherwise, contact the maintainer privately through the contact information associated with the repository owner.

Public GitHub Issues are for bugs and must not contain passwords, journal contents, backups/exports, key material, recovery material, or other sensitive/personal data.

## Dependency and supply-chain policy

Daymark must not knowingly introduce or retain a dependency with an unresolved known vulnerability unless there is no reasonable maintenance alternative and the exception is explicitly documented.

Security exceptions must record:

- advisory identifier;
- why the dependency cannot currently be removed/upgraded;
- practical exposure in Daymark;
- upstream tracking reference;
- review/removal condition.

Permanent blanket ignores are not acceptable.

Supply-chain rules:

- lockfiles are versioned;
- dependency updates are reviewed through pull requests;
- stable published packages are preferred over mutable Git dependencies;
- GitHub Actions are pinned to immutable commit SHAs;
- CI includes static analysis, tests, native builds, and dependency/security review at the applicable merge boundary;
- secrets must never be committed;
- production code must not rely on dependencies fetched from mutable Git branches.

Dependency maintenance must not be used to smuggle in new product capabilities under the frozen scope.

## Local-first data model and threat baseline

Daymark is local-first and offline-first. Core journal data is not transmitted to remote services as part of normal operation.

No network product feature is planned under the frozen scope.

Daymark assumes that a phone, computer, removable storage device, or backup medium containing journal data may be lost, stolen, sold, transferred, or accessed by a curious third party.

The at-rest protection goal is that possession of the storage medium alone must not reveal journal contents.

User-requested plaintext Open Export is outside this guarantee because exporting is an explicit decision to create an unencrypted copy. Daymark requires the current master password to be reauthenticated against the authenticated key envelope before it creates that plaintext representation.

Daymark does not claim to protect an already-unlocked device against a fully privileged attacker executing arbitrary code in the user's session. Runtime compromise and at-rest protection are different threat classes.

## Data-at-rest baseline

Journal entries may contain highly sensitive information, so encryption at rest is a baseline requirement rather than an optional feature.

The implemented persistence baseline is Drift with `package:sqlite3` 3.x configured to bundle SQLite3MultipleCiphers through native build hooks.

Daymark verifies during database initialization that the encrypted SQLite implementation is present. If cipher support is missing or misconfigured, the application fails safely rather than opening or creating a plaintext journal database.

The database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode). Changing the database cipher is not normal product work; it requires a concrete security/compatibility reason plus documented migration/testing.

The database receives 48 bytes of raw journal key material in SQLite3MultipleCiphers' ChaCha20 raw-key-plus-salt form:

- 32 bytes of cryptographically random journal data-encryption key;
- 16 bytes of random cipher salt.

The master password is never passed directly to SQLite3MultipleCiphers.

`PRAGMA key` does not prove that a supplied key is correct. Daymark performs a real database read after applying cipher/key. An existing journal that cannot be authenticated/read with the supplied key fails with the generic journal-unlock error.

Tests cover correct-key reopen, incorrect-key rejection, unreadability through ordinary unkeyed SQLite, absence of representative sensitive plaintext in the database file, and preservation of normal schema constraints through encrypted persistence.

## Master password and key hierarchy

A master password is required when a journal is created.

The master password is not used directly as the database encryption key. Daymark generates random journal key material and protects access to it using a password-derived key-encryption key.

The application cryptography baseline is `cryptography` 2.9.0:

- Argon2id derives the password-based key-encryption key;
- XChaCha20-Poly1305 authenticated encryption protects serialized journal key material.

The version-1 key envelope is a strict JSON object outside the encrypted Drift database. It records only metadata required before the database can be opened:

- Daymark key-envelope format identifier/version;
- Argon2id identifier and explicit parameters;
- random 16-byte KDF salt;
- XChaCha20-Poly1305 algorithm identifier;
- nonce;
- wrapped journal-key ciphertext;
- authentication tag.

Interpretation-sensitive metadata is authenticated as additional authenticated data. Wrong passwords and modified ciphertext, nonce, authentication tag, or authenticated KDF metadata fail closed. Malformed/truncated envelopes and unsupported envelope/KDF identifiers fail explicitly before journal data is opened.

The master password itself is never stored.

Any maintenance change that alters key-envelope interpretation or password/KDF behavior must preserve explicit compatibility for supported journals. No release may solve a password/key-envelope compatibility issue by silently recreating the journal.

### Argon2id production parameters

The production baseline was frozen on 2026-09-02 after profile-mode measurements on physical Linux and Android hardware:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- derived-key length: 32 bytes;
- random KDF salt: 16 bytes per envelope.

The benchmark record/rationale are defined in `docs/ARGON2_BENCHMARK.md`.

Envelope metadata is untrusted until authentication succeeds, so Daymark validates Argon2id parameters before allocation/derivation. Parser safety ceilings remain 64 MiB memory, 5 iterations, parallelism 4, and exactly 32 bytes of derived output. These ceilings are defensive input bounds, not production targets.

Published envelope metadata remains explicit so a security maintenance release can strengthen new defaults if a concrete security need justifies it without reinterpreting existing journals.

`v1.0.0-alpha.2` publishes version-1 envelopes with this interpretation. Any change to KDF interpretation/default migration for supported journals requires an explicit tested compatibility path.

## Sensitive-memory limits

Dart and Flutter do not provide a universal guarantee that every runtime copy of sensitive data can be securely zeroized.

Daymark follows practical ownership rules rather than claiming perfect memory erasure:

- secret byte buffers are narrowly scoped;
- owned mutable serialized key buffers are overwritten after use where practical;
- `SecretKeyData` uses overwrite-on-destroy and journal key holders expose explicit `destroy()` lifecycle;
- the owned SQLite cipher salt buffer is overwritten when its journal-key holder is destroyed;
- unnecessary temporary plaintext key copies are avoided;
- secrets, passwords, keys, decrypted entries, and recovery material are never logged.

SQLite3MultipleCiphers' SQL `PRAGMA key` interface requires raw key material to be encoded as a hexadecimal Dart `String`. Dart strings are immutable and cannot be reliably zeroized by application code. The mutable byte buffer used to construct that string is overwritten immediately, but Daymark does not claim that the runtime's immutable string copy can be erased on demand.

A maintenance change may replace this path only when evidence shows a safer supported API/implementation and the replacement does not introduce unsafe FFI or compatibility regressions merely to claim stronger zeroization.

## Unlock model

Daymark's unlock model is the portable master-password model described above.

Device-assisted/biometric unlock is **not planned** under the frozen product scope. Daymark does not store/replay the master password behind a biometric prompt, does not create a device-bound-only recovery dependency, and does not expose a cosmetic biometric gate.

The absence of biometric/device-assisted unlock is an intentional product/security boundary, not unfinished release work.

## Recovery model

Daymark provides recovery/migration through portable authenticated encrypted Backup / Restore plus the user's master password.

A separate recovery-secret feature, account-based password reset, server recovery, or maintainer backdoor is **not planned** under the frozen product scope.

If the master password required for a journal/backup is lost, the encrypted data may be permanently unrecoverable. Daymark must not imply that the maintainer can bypass the cryptographic boundary.

## Locking policy

Daymark provides explicit manual lock and automatically locks after five minutes without journal interaction.

Daymark additionally requests immediate journal lock when the supported host exposes the implemented protected-state signal:

- Android system `ACTION_SCREEN_OFF`;
- Linux systemd-logind per-session `Lock` signal.

These hooks call the same serialized session-controller lock path used by manual/inactivity locking. If a Linux environment does not expose the logind signal, normal inactivity policy remains the fallback rather than treating generic window-focus changes as device locks.

Moving the app to the background starts/continues the lock timeout rather than implicitly exposing decrypted content indefinitely.

The inactivity guard records real journal interaction and delegates expiration to the same session-controller lock path. Pointer/touch, hardware-keyboard interaction, and mobile IME text edits renew the deadline; widget rebuilds do not.

Background time does not reset the deadline. On resume, Daymark evaluates elapsed wall-clock time immediately. If the wall clock moved backwards relative to the last recorded interaction, the guard fails closed and requests lock.

An operation already inside the serialized session completes before persistence closes; then the database closes before journal-key material is destroyed.

The current locking behavior is part of the frozen product. Policy changes require a concrete bug/security reason rather than preference-driven expansion.

## Plaintext boundaries

Sensitive journal content must not be persistently duplicated outside the encrypted store without explicit user action.

This applies to:

- caches;
- search indexes;
- temporary plaintext files;
- logs/crash diagnostics;
- internal backups;
- removable storage.

Attachments are not a supported product feature.

Internal backups created by Daymark remain encrypted by default, including backups stored on removable media.

User-requested Open Export is an explicit security boundary. Before any plaintext representation is created, Daymark reauthenticates the current master password against the authenticated key envelope without replacing the live session. JSON and Markdown may then be deliberately saved or copied to clipboard.

Both destinations are outside Daymark's encryption boundary. Clipboard content may be readable by other applications or retained by a clipboard manager. Open Export is not a recovery/restore format.

## Search security

Search must not create an unencrypted shadow index of journal content.

The frozen Search implementation searches inside the encrypted journal boundary using its existing literal matching behavior. A new full-text/ranking/indexing product feature is not planned.

If maintenance ever requires an internal indexing change for correctness/performance compatibility, the index must remain inside the same encrypted database/security boundary or use equivalent protection and must not expand user-visible Search scope without an explicit product-freeze reversal.

## Backup security

Daymark provides manual full encrypted Backup / Restore.

Automatic scheduling and retention policies are not planned under the frozen product scope.

A Daymark backup is portable across supported Linux/Android devices and does not depend solely on a device-bound Keystore/keyring/filesystem path/machine identity.

The backup format is versioned and self-describing enough to identify format, application/schema compatibility, cryptographic parameters, and integrity information before destructive restore work begins.

Backup payloads remain encrypted and authenticated.

Restore validates authentication/integrity, format compatibility, schema compatibility, encrypted database readability, database integrity, and foreign-key integrity before replacing existing journal data. Replacement uses staged/rollback-safe application-level recovery so a failed/interrupted restore does not silently destroy a working journal.

Restore is exposed only while the destination journal is locked or absent; the application must not replace files beneath an active encrypted database session.

Plaintext Markdown/JSON Open Export is not a backup mechanism and remains clearly distinct from encrypted Daymark Backup.

The authoritative container contract is documented in `docs/BACKUP_FORMAT.md`.

### Android operating-system backup boundary

Daymark does not use Android automatic application-data backup or device-to-device migration as its journal-backup mechanism.

The Android manifest sets `android:allowBackup="false"` and supplies explicit backup/data-extraction rules. Android 11-and-earlier full-backup rules exclude every Daymark application-data domain, and Android 12+ extraction rules exclude every domain from cloud backup/device transfer.

This is defense in depth. Platform/OEM behavior can evolve, so Daymark does not claim that a manifest flag alone is a universal cryptographic guarantee. The journal remains encrypted independently of Android backup mechanisms.

Portable migration between supported devices uses Daymark's explicit encrypted Backup / Restore design.

## Release-signing boundary

Android release signing material is local-only and must never be committed or printed into logs.

Release Gradle tasks fail closed if dedicated release signing configuration/keystore is absent. Daymark must never silently publish an artifact signed with the debug key.

Published `v1.0.0-alpha.2` uses certificate SHA-256:

```text
44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88
```

The corresponding alpha.2 private signing key could not be recovered during alpha.3 release preparation. Android therefore cannot authenticate alpha.3 as an install-over update of alpha.2. This is a package-signing boundary, not a failure of Daymark's encrypted journal or backup formats.

The supported alpha.2 -> alpha.3 transition is encrypted Backup / uninstall alpha.2 / clean-install alpha.3 / Restore with the existing journal master password. That path was validated on physical Android hardware with a retained alpha.2 encrypted backup and persisted successfully across force-stop/relaunch.

Alpha.3 establishes the maintained Android release lineage with certificate SHA-256:

```text
77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311
```

The alpha.3 candidate was verified with `apksigner` as one RSA-4096 signer. Its private keystore remains local-only and is backed up outside the repository. Every later Android release intended to install over alpha.3 must preserve this signing identity unless Android provides an explicit supported signing-migration mechanism that is deliberately adopted, tested, and documented for a concrete maintenance need.

Loss of a release private signing key is operationally significant because the public certificate embedded in a published APK cannot reconstruct the private key. Signing-key backups are therefore part of release security even though they are never repository content.

## Data disposal

Encryption is designed so destruction of relevant encryption key material renders residual encrypted database material unusable. This supports cryptographic-erasure scenarios, including device retirement/storage replacement.

Cryptographic erasure is not a replacement for appropriate full-device sanitization when transferring/discarding storage media.

## Cryptographic implementation rule

Daymark must not implement custom cryptographic primitives or casually invent unauthenticated encryption formats when established reviewed libraries/constructions are available.

Application-level cryptography uses the selected published `cryptography` package and encrypted database engine. New cryptographic formats or algorithm changes require a concrete security/compatibility reason, explicit threat-model review, and compatibility testing.

Security-sensitive code requires negative-path tests, including wrong password, corrupted key envelope, corrupted backup, missing encrypted-database support, incompatible schema, and interrupted restore behavior.

## Published compatibility boundary

Because `v1.0.0-alpha.2` has been published with real journal-data support, changes to any of the following require an explicit tested compatibility/migration path for every predecessor version the new build claims to support:

- key-envelope format or interpretation;
- Argon2id parameter semantics;
- 48-byte journal-key serialization;
- database cipher/key representation;
- published database schema versions;
- encrypted backup format/cryptography;
- Open Export format interpretation where backward machine readability is claimed;
- Android signing identity for install-over upgrades.

For alpha.2 -> alpha.3 specifically, install-over is not a supported claim because the alpha.2 private signing key is unavailable; encrypted Backup / Restore is the validated compatibility path. From alpha.3 onward, the alpha.3 signing certificate is the install-over compatibility identity.

Failure to unlock, upgrade, or restore old supported data is data loss even when encrypted bytes remain intact. No release may solve compatibility by silently deleting/recreating a user's journal.
