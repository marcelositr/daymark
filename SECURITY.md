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
- GitHub Actions should be pinned to immutable commit SHAs when introduced.
- CI must include static analysis and tests once the application scaffold exists.
- Secrets must never be committed to the repository.
- Production code must not rely on dependencies fetched from mutable Git branches.

## Data model

Daymark is local-first. Core journal data must not be transmitted to remote services as part of normal operation.

Any future network feature must be optional, explicit, documented, and isolated from the core local workflow.

## Threat model baseline

Daymark must assume that a phone, computer, removable storage device, or backup medium containing journal data may be lost, stolen, sold, transferred, or accessed by a curious third party.

The expected protection goal is that possession of the storage medium alone must not reveal journal contents.

User-requested plaintext export is outside this guarantee because exporting is an explicit decision to create an unencrypted copy.

## Data-at-rest baseline

Daymark must assume that journal entries may contain highly sensitive information, including credentials, access instructions, recovery material, private notes, and references to physical keys or locations.

Encryption at rest is therefore a baseline requirement rather than an optional feature.

The persistence design must use a mature, reviewed full-database encryption solution compatible with the application's SQLite architecture. SQLCipher is the expected implementation direction unless technical review identifies a better maintained equivalent before the persistence layer is finalized.

The database encryption key must be generated from cryptographically secure random material. User authentication material must protect access to that key rather than being stored or used as an unprotected database secret.

Platform keystores or secret services may be used to improve unlocking convenience, but the security model must not silently reduce journal protection to the security of a desktop keyring alone.

## Master password and key hierarchy

A master password is required when a journal is created.

The master password is not used directly as the database encryption key. Daymark generates a cryptographically random journal data-encryption key and protects access to that key using a password-derived key-encryption key.

Password-based key derivation should use a mature memory-hard KDF, with Argon2id as the preferred direction unless platform validation identifies a better established equivalent. Salt and KDF parameters are stored as non-secret metadata and must be versioned so parameters can be strengthened over time.

The master password itself is never stored.

Changing the master password should re-protect the journal key rather than require semantic journal data to be rewritten merely because authentication material changed.

## Device-assisted unlock

Device-specific unlock mechanisms are convenience layers, not replacements for the portable master-password security model.

On supported Android devices, Daymark may protect a device-local wrapped journal key using Android Keystore and require strong biometric or device-credential authentication before that key can be used.

On Linux, a compatible secret service or keyring may be used for optional convenience, but enabling it must not make the journal unrecoverable without that desktop environment or silently store the master password.

The master password remains required for operations such as restoring the journal on a new device when device-bound key material is unavailable.

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

## Backup security

The initial product must support manual full encrypted backup and restore. Automatic scheduling and retention policies can be added later.

A Daymark backup must be portable across supported devices and must not depend solely on a device-bound Android Keystore key, Linux keyring entry, filesystem path, or machine identity.

The backup format must be versioned and self-describing enough to identify the Daymark backup format, application/schema compatibility, and integrity information before destructive restore work begins.

Backup payloads remain encrypted. The current master password may protect a portable backup key for the initial implementation. If a master password is changed, existing external backups remain protected by the credentials with which they were created; Daymark should recommend creating a fresh backup after a password change.

Restore must validate integrity and compatibility before replacing existing journal data.

Plaintext Markdown or JSON export is not a backup mechanism and must remain clearly distinguished from encrypted Daymark backup.

## Data disposal

Encryption must be designed so that destruction of the relevant encryption key renders residual encrypted database material unusable. This supports cryptographic erasure scenarios, including device retirement or storage replacement.

Cryptographic erasure is not a replacement for appropriate full-device sanitization when transferring or disposing of storage media.

## Cryptographic implementation rule

Daymark must not implement custom cryptographic primitives or invent its own encryption format when established, reviewed libraries and formats are available.

The final key derivation, key wrapping, unlock, recovery, backup encryption, and platform key-storage design must be documented and threat-modeled before implementation is considered stable.
