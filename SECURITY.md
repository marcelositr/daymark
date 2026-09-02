# Security Policy

## Supported versions

Daymark is pre-release software. Until the first public release, security fixes apply to the current development line only.

## Reporting a vulnerability

Please do not disclose exploitable vulnerabilities in a public issue before a fix is available.

If private vulnerability reporting is enabled for this repository, use GitHub's private vulnerability reporting flow. Otherwise, contact the maintainer privately through the contact information associated with the repository owner.

## Dependency policy

Daymark must not knowingly introduce a dependency with an unresolved known vulnerability unless there is no reasonable alternative and the exception is explicitly documented.

Security exceptions must record:

- the advisory identifier;
- why the dependency cannot currently be removed or upgraded;
- the practical exposure in Daymark;
- the upstream tracking reference;
- a review condition or removal plan.

Permanent blanket ignores are not acceptable.

## Supply-chain policy

- Lockfiles are versioned.
- Dependency updates are reviewed through pull requests.
- Stable published packages are preferred over mutable Git dependencies.
- GitHub Actions are pinned to immutable commit SHAs.
- CI includes static analysis, tests, native builds, and dependency/security review.
- Secrets must never be committed to the repository.
- Production code must not rely on dependencies fetched from mutable Git branches.

## Data model

Daymark is local-first. Core journal data must not be transmitted to remote services as part of normal operation.

Any future network feature must be optional, explicit, documented, and isolated from the core local workflow.

## Threat model baseline

Daymark assumes that a phone, computer, removable storage device, or backup medium containing journal data may be lost, stolen, sold, transferred, or accessed by a curious third party.

The expected protection goal is that possession of the storage medium alone must not reveal journal contents.

User-requested plaintext export is outside this guarantee because exporting is an explicit decision to create an unencrypted copy.

Daymark does not claim to protect an already-unlocked device against a fully privileged attacker executing arbitrary code in the user's session. The at-rest threat model remains meaningful even though runtime compromise is a different class of problem.

## Data-at-rest baseline

Journal entries may contain highly sensitive information, so encryption at rest is a baseline requirement rather than an optional feature.

The implemented persistence baseline is Drift with `package:sqlite3` 3.x configured to bundle SQLite3MultipleCiphers through native build hooks.

Daymark verifies during database initialization that the encrypted SQLite implementation is present. If cipher support is missing or misconfigured, the application must fail safely rather than opening or creating a plaintext journal database.

The current database cipher is SQLite3MultipleCiphers ChaCha20-Poly1305 (`chacha20` / sqleet mode). Changing the database cipher requires a documented security and data-migration review.

The database receives 48 bytes of raw journal key material in SQLite3MultipleCiphers' documented ChaCha20 raw-key-plus-salt form:

- 32 bytes of cryptographically random journal data-encryption key;
- 16 bytes of random cipher salt.

The master password is never passed directly to SQLite3MultipleCiphers.

`PRAGMA key` does not prove that a supplied key is correct. Daymark therefore performs a real database read after applying the cipher and raw key. An existing journal that cannot be authenticated/read with the supplied key fails with the generic journal-unlock error.

Tests prove correct-key reopen, incorrect-key rejection, unreadability through ordinary unkeyed SQLite, absence of representative sensitive plaintext in the database file, and preservation of normal schema constraints through encrypted persistence.

## Master password and key hierarchy

A master password is required when a journal is created.

The master password is not used directly as the database encryption key. Daymark generates cryptographically random journal key material and protects access to it using a password-derived key-encryption key.

The application cryptography baseline is the published Dart `cryptography` package 2.9.0:

- Argon2id derives the password-based key-encryption key;
- XChaCha20-Poly1305 authenticated encryption protects the serialized journal key material.

The version-1 key envelope is a small JSON object outside the encrypted Drift database. It records only metadata required before the database can be opened:

- Daymark key-envelope format identifier and version;
- Argon2id identifier and explicit parameters;
- random 16-byte KDF salt;
- XChaCha20-Poly1305 algorithm identifier;
- nonce;
- wrapped journal-key ciphertext;
- authentication tag.

Interpretation-sensitive metadata is included in authenticated additional data. Wrong passwords and modified ciphertext, nonce, authentication tag, or authenticated KDF metadata fail closed. Malformed/truncated envelopes and unsupported envelope/KDF identifiers fail explicitly before journal data is opened.

The master password itself is never stored.

Changing the master password must re-protect the same random journal key rather than require semantic journal data to be rewritten merely because authentication material changed.

### Argon2id production parameters

The initial production baseline was frozen on 2026-09-02 after profile-mode measurements on physical Linux and Android hardware:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- derived-key length: 32 bytes;
- random KDF salt: 16 bytes per envelope.

The benchmark record and rationale are defined in `docs/ARGON2_BENCHMARK.md`.

The review compared the OWASP-listed 19 MiB / 2, 12 MiB / 3, 9 MiB / 4, and 7 MiB / 5 tradeoffs on an Intel Core i5-2400 Linux system, a Samsung SM-A015M Android device, and an intentionally conservative M7 3G PLUS ARM32 Android device.

Lower-memory alternatives produced negligible desktop benefit and only modest Android latency improvements. The selected 19 MiB / 2 baseline therefore retains the higher-memory tradeoff rather than lowering memory hardness merely to reduce the unlock delay on unusually slow hardware.

Old hardware may experience a noticeably slower password derivation. Daymark treats that as a performance characteristic of an intentionally expensive security operation, not as permission to silently weaken the KDF.

Envelope metadata is untrusted until authentication succeeds, so Daymark validates Argon2id parameters before allocation/derivation. The parser safety ceilings remain 64 MiB memory, 5 iterations, parallelism 4, and exactly 32 bytes of derived output. These ceilings are defensive input bounds, not production targets.

KDF parameters remain explicit versioned envelope data so future releases can strengthen defaults without reinterpreting existing journals. Once real prerelease journals exist, any change requires an explicit compatibility/migration review.

## Sensitive-memory limits

Dart and Flutter do not provide a universal guarantee that every runtime copy of sensitive data can be securely zeroized.

Daymark therefore follows practical ownership rules rather than claiming perfect memory erasure:

- secret byte buffers are kept narrowly scoped;
- owned mutable serialized key buffers are overwritten after use where practical;
- `SecretKeyData` is configured for overwrite-on-destroy and journal key holders expose an explicit `destroy()` lifecycle;
- the owned SQLite cipher salt buffer is overwritten when its journal-key holder is destroyed;
- unnecessary temporary plaintext key copies are avoided;
- secrets, passwords, keys, decrypted entries, and recovery material must never be logged.

SQLite3MultipleCiphers' SQL `PRAGMA key` interface currently requires raw key material to be encoded as a hexadecimal Dart `String`. Dart strings are immutable and cannot be reliably zeroized by application code. The byte buffer used to construct that string is overwritten immediately, but Daymark does not claim that the runtime's immutable string copy can be erased on demand.

Future native/database APIs may reduce this exposure, but replacing a reviewed working path requires evidence and must not introduce unsafe FFI merely to claim stronger zeroization than the runtime actually provides.

## Device-assisted unlock

Device-specific unlock mechanisms are convenience layers, not replacements for the portable master-password security model.

The exact secure-storage integration is deliberately deferred to a later focused task. A maintained platform secure-storage package may be used, but it must be compatible with Daymark's pinned Flutter/Android/Linux toolchain and threat model when introduced.

`flutter_secure_storage` remains a candidate rather than a baseline dependency. During the Flutter 3.47.2 scaffold validation, version 11.0.0 required Android `compileSdk` 37 while the generated project used API 36 with Android Gradle Plugin 9.1.0. Daymark chose not to distort the Android toolchain for an unused convenience layer.

On supported Android devices, Daymark may protect device-local unlock material using Android secure-storage/Keystore mechanisms and require strong biometric or device-credential authentication before that material can be used.

On Linux, a compatible secret service or keyring may be used for optional convenience. A locked, missing, or unavailable keyring must be a recoverable device-assist failure, not loss of the journal itself.

Device-assisted unlock must never silently store the master password in plaintext. The master password remains sufficient for portable unlock/restore when device-bound material is unavailable.

## Recovery

Daymark should offer an optional offline recovery secret during initial security setup.

Recovery remains at the same portable trust layer as the master password. A recovery secret must independently protect/recover the same random journal key rather than depend on Android Keystore, Linux keyring state, a server account, or the original device.

The recovery secret must be generated from cryptographically secure random material, shown to the user for external safekeeping, and must not be persisted in plaintext alongside the journal.

The final human representation and recovery UX are not frozen in PR #7. The key-envelope architecture must preserve independent authenticated wrapping of the existing random journal key so adding recovery does not require changing the encrypted database key or creating a maintainer backdoor.

Recovery is local and cryptographic. There is no account-based password reset and no maintainer backdoor.

If both the master password and any configured recovery secret are lost, encrypted journal data may be permanently unrecoverable. The application must communicate this clearly before setup is completed.

## Locking policy

Daymark must provide an explicit manual lock action.

The security default is automatic lock after five minutes without journal interaction. The lock timeout may be configurable, including a stricter immediate option.

An operating-system session lock, device lock, or equivalent protected state should lock Daymark immediately when the platform exposes a reliable signal.

Moving the app to the background starts or continues the lock timeout rather than implicitly exposing decrypted content indefinitely.

The current pre-alpha inactivity-lock implementation keeps timeout/lifecycle policy outside the cryptographic session manager. While the journal is unlocked, a presentation/lifecycle guard records real journal interaction and delegates expiration to the same session-controller lock path used by manual lock.

The five-minute deadline is renewed by pointer/touch interaction and hardware-keyboard interaction. Text controls that may receive input through a mobile IME without emitting Flutter `KeyEvent`s explicitly report edit activity to the guard so active typing is not misclassified as inactivity. Widget rebuilds do not count as user activity.

Background time does not reset the deadline. On resume, Daymark evaluates elapsed wall-clock time immediately so a suspended platform timer cannot leave an inactive journal open indefinitely. If the wall clock moved backwards relative to the last recorded interaction, the inactivity guard fails closed and requests a lock rather than extending the unlocked period.

Automatic timeout does not bypass session safety rules. The existing serialized journal-session boundary remains authoritative: an operation that already entered the session completes before persistence is closed, then the database is closed before journal-key material is destroyed.

Immediate locking from Linux desktop-session lock, Android device-lock, or other operating-system protected-state signals remains a separate platform-integration task. A five-minute inactivity lock is not a substitute for those hooks when a reliable signal is available.

When the journal is locked, application components must release or invalidate decrypted journal-key material as far as the platform/runtime design reasonably permits and must not keep decrypted entry caches merely for convenience.

Platform-specific presentation layers should prevent sensitive journal contents from being unnecessarily exposed through operating-system surfaces such as recent-app previews or notification text when the platform allows this protection.

## Plaintext boundaries

Sensitive journal content must not be persistently duplicated outside the encrypted data store without an explicit user action.

This applies to:

- caches;
- search indexes;
- temporary files;
- logs and crash diagnostics;
- internal backups;
- removable storage;
- attachments when attachment support is introduced.

Internal backups created by Daymark must remain encrypted by default, including backups stored on removable media such as SD cards or external drives.

Copying or relocating Daymark's own database or backup files to removable storage must not silently convert protected data into plaintext.

User-requested exports are an explicit security boundary. Human-readable exports such as Markdown or JSON may be plaintext and must clearly communicate that the exported file is no longer protected by the journal's encrypted store unless an encrypted export mode is explicitly selected.

## Search security

Search must not create an unencrypted shadow index of journal content.

If full-text indexing is used, the index must live within the same encrypted database/security boundary or use an equivalently protected design.

Search convenience is never a justification for persisting plaintext journal terms outside the encrypted store.

## Backup security

The initial product must support manual full encrypted backup and restore. Automatic scheduling and retention policies can be added later.

A Daymark backup must be portable across supported devices and must not depend solely on a device-bound Android Keystore key, Linux keyring entry, filesystem path, or machine identity.

The backup format must be versioned and self-describing enough to identify the Daymark backup format, application/schema compatibility, cryptographic parameters, and integrity information before destructive restore work begins.

Backup payloads remain encrypted and authenticated.

Restore must validate authentication/integrity, format compatibility, and schema compatibility before replacing existing journal data. Restore should be atomic or rollback-safe so a failed restore does not destroy a working journal.

If a master password is changed, existing external backups remain protected by the credentials with which they were created; Daymark should recommend creating a fresh backup after a password change.

Plaintext Markdown or JSON export is not a backup mechanism and must remain clearly distinguished from encrypted Daymark backup.

### Android operating-system backup boundary

Daymark does not use Android's automatic application-data backup or device-to-device migration as its journal-backup mechanism.

The Android application manifest sets `android:allowBackup="false"` and supplies explicit backup/data-extraction rule files. The Android 11-and-earlier full-backup rules exclude every Daymark application-data domain, and the Android 12+ extraction rules exclude every domain from both cloud backup and device transfer.

This is a defense-in-depth privacy boundary. Platform and OEM behavior can evolve, so Daymark does not claim that a manifest flag alone is a universal cryptographic guarantee. The journal remains encrypted independently of the Android backup mechanism.

The explicit exclusion also avoids allowing operating-system backup jobs to copy app-private state or disrupt security/performance validation. During physical-device benchmarking, an Android full-backup job was observed terminating the Daymark benchmark process; the investigation exposed that the default platform backup setting had been unintentionally enabled. Daymark now opts out deliberately rather than relying on the Android default.

Portable migration between devices must use Daymark's explicit encrypted backup/restore design, not an opaque OS-managed copy of app-private state.

## Data disposal

Encryption is designed so destruction of the relevant encryption key renders residual encrypted database material unusable. This supports cryptographic-erasure scenarios, including device retirement or storage replacement.

Cryptographic erasure is not a replacement for appropriate full-device sanitization when transferring or disposing of storage media.

## Cryptographic implementation rule

Daymark must not implement custom cryptographic primitives or casually invent its own unauthenticated encryption format when established reviewed libraries and constructions are available.

Application-level cryptography uses the selected published `cryptography` package and the encrypted database engine. New cryptographic formats or algorithm changes require explicit compatibility and threat-model review.

Security-sensitive code requires negative-path tests, including wrong password, corrupted key envelope, corrupted backup, missing encrypted-database support, unavailable keyring/Keystore assistance, incompatible schema, and interrupted restore behavior.

Once a prerelease containing real user journals is published, changes to key-envelope interpretation, KDF parameters/semantics, journal-key serialization, database cipher/key representation, recovery wrapping, or backup cryptography require an explicit tested compatibility or migration path. Failure to unlock old data is data loss even when encrypted bytes remain intact.
