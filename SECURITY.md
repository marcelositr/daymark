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
- GitHub Actions should be pinned to immutable commit SHAs when introduced.
- CI must include static analysis and tests once the application scaffold exists.
- Dependency/security review must be part of the merge gate once CI exists.
- Secrets must never be committed to the repository.
- Production code must not rely on dependencies fetched from mutable Git branches.

## Data model

Daymark is local-first. Core journal data must not be transmitted to remote services as part of normal operation.

Any future network feature must be optional, explicit, documented, and isolated from the core local workflow.

## Threat model baseline

Daymark must assume that a phone, computer, removable storage device, or backup medium containing journal data may be lost, stolen, sold, transferred, or accessed by a curious third party.

The expected protection goal is that possession of the storage medium alone must not reveal journal contents.

User-requested plaintext export is outside this guarantee because exporting is an explicit decision to create an unencrypted copy.

Daymark does not claim to protect an already-unlocked device against a fully privileged attacker executing arbitrary code in the user's session. The at-rest threat model remains meaningful even though runtime compromise is a different class of problem.

## Data-at-rest baseline

Daymark must assume that journal entries may contain highly sensitive information, including credentials, access instructions, recovery material, private notes, and references to physical keys or locations.

Encryption at rest is therefore a baseline requirement rather than an optional feature.

The current persistence direction is Drift with `package:sqlite3` 3.x configured to bundle SQLite3MultipleCiphers through native build hooks.

This supersedes the earlier SQLCipher-first assumption because the current Drift ecosystem recommends the native encrypted executor with SQLite3MultipleCiphers for new applications and no longer requires the obsolete `sqlcipher_flutter_libs` path.

Daymark must verify during database initialization that the encrypted SQLite implementation is actually present. If cipher support is missing or misconfigured, the application must fail safely rather than opening or creating a plaintext journal database.

SQLite3MultipleCiphers currently uses authenticated ChaCha20-Poly1305 as its recommended/default cipher. Daymark should begin with the current non-legacy authenticated mode and may change schemes only after a documented security and migration review.

The database encryption key must be generated from cryptographically secure random material. User authentication material protects access to that key rather than serving as an unreviewed raw database password.

## Master password and key hierarchy

A master password is required when a journal is created.

The master password is not used directly as the database encryption key.

Daymark generates cryptographically random journal key material and protects access to it using a password-derived key-encryption key.

Password-based key derivation uses a mature memory-hard KDF. Argon2id is the current baseline through the published Dart `cryptography` package unless implementation benchmarking or security review identifies a stronger practical reason to change.

Salt and KDF parameters are non-secret metadata and must be versioned so parameters can be strengthened over time.

The master password itself is never stored.

Changing the master password should re-protect the journal key rather than require semantic journal data to be rewritten merely because authentication material changed.

The focused security spike in `PROJECT.md` must define and test the exact key-envelope format, authenticated-encryption algorithm, nonce handling, raw database-key/salt handling, and Argon2id parameters before the security layer is considered stable.

## Device-assisted unlock

Device-specific unlock mechanisms are convenience layers, not replacements for the portable master-password security model.

The current cross-platform integration direction is `flutter_secure_storage` for device-local wrapped material.

On supported Android devices, Daymark may protect device-local unlock material using Android secure storage/Keystore mechanisms and require strong biometric or device-credential authentication before that material can be used.

On Linux, a compatible secret service or keyring may be used for optional convenience. A locked, missing, or unavailable keyring must be treated as a recoverable device-assist failure, not as loss of the journal itself.

Device-assisted unlock must never silently store the master password in plaintext.

The master password remains sufficient for portable unlock/restore when device-bound key material is unavailable.

## Recovery

Daymark should offer an optional offline recovery key during initial security setup.

The recovery key must be generated from cryptographically secure random material, shown to the user for external safekeeping, and must not be persisted in plaintext alongside the journal.

Recovery is local and cryptographic. There is no account-based password reset and no maintainer backdoor.

If both the master password and any configured recovery key are lost, encrypted journal data may be permanently unrecoverable. The application must communicate this clearly before setup is completed.

## Locking policy

Daymark must provide an explicit manual lock action.

The security default is automatic lock after five minutes without journal interaction. The lock timeout may be configurable, including a stricter immediate option.

An operating-system session lock, device lock, or equivalent protected state should lock Daymark immediately when the platform exposes a reliable signal.

Moving the app to the background starts or continues the lock timeout rather than implicitly exposing decrypted content indefinitely.

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

Restore must validate authentication/integrity, format compatibility, and schema compatibility before replacing existing journal data. Restore should be designed as an atomic or rollback-safe operation so a failed restore does not destroy a working journal.

If a master password is changed, existing external backups remain protected by the credentials with which they were created; Daymark should recommend creating a fresh backup after a password change.

Plaintext Markdown or JSON export is not a backup mechanism and must remain clearly distinguished from encrypted Daymark backup.

## Data disposal

Encryption must be designed so that destruction of the relevant encryption key renders residual encrypted database material unusable. This supports cryptographic erasure scenarios, including device retirement or storage replacement.

Cryptographic erasure is not a replacement for appropriate full-device sanitization when transferring or disposing of storage media.

## Cryptographic implementation rule

Daymark must not implement custom cryptographic primitives or casually invent its own unauthenticated encryption format when established reviewed libraries and constructions are available.

Application-level cryptography should use reviewed published implementations such as the selected `cryptography` package and the encrypted database engine.

The final key derivation, key wrapping, unlock, recovery, backup encryption, secure-storage integration, and platform handling design must be documented and threat-modeled before implementation is considered stable.

Security-sensitive code requires negative-path tests, including wrong password, corrupted key envelope, corrupted backup, missing encrypted-database support, unavailable keyring/Keystore assistance, incompatible schema, and interrupted restore behavior.
