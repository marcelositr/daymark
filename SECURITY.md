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

## Data-at-rest baseline

Daymark must assume that journal entries may contain highly sensitive information, including credentials, access instructions, recovery material, private notes, and references to physical keys or locations.

Encryption at rest is therefore a baseline requirement rather than an optional feature.

The persistence design must use a mature, reviewed full-database encryption solution compatible with the application's SQLite architecture. SQLCipher is the expected implementation direction unless technical review identifies a better maintained equivalent before the persistence layer is finalized.

The database encryption key must be generated from cryptographically secure random material. User authentication material must protect access to that key rather than being stored or used as an unprotected database secret.

Platform keystores or secret services may be used to improve unlocking convenience, but the security model must not silently reduce journal protection to the security of a desktop keyring alone.

## Plaintext boundaries

Sensitive journal content must not be persistently duplicated outside the encrypted data store without an explicit user action.

This applies to:

- caches;
- search indexes;
- temporary files;
- logs and crash diagnostics;
- internal backups;
- attachments when attachment support is introduced.

User-requested exports are an explicit security boundary. Human-readable exports such as Markdown or JSON may be plaintext and must clearly communicate that the exported file is no longer protected by the journal's encrypted store unless an encrypted export mode is explicitly selected.

## Locking and device exposure

The application architecture must support explicit lock and automatic lock behavior.

Platform-specific presentation layers should prevent sensitive journal contents from being unnecessarily exposed through operating-system surfaces such as recent-app previews or notification text when the platform allows this protection.

## Data disposal

Encryption must be designed so that destruction of the relevant encryption key renders residual encrypted database material unusable. This supports cryptographic erasure scenarios, including device retirement or storage replacement.

Cryptographic erasure is not a replacement for appropriate full-device sanitization when transferring or disposing of storage media.

## Cryptographic implementation rule

Daymark must not implement custom cryptographic primitives or invent its own encryption format when established, reviewed libraries and formats are available.

The final key derivation, key wrapping, unlock, recovery, and platform key-storage design must be documented and threat-modeled before implementation is considered stable.
