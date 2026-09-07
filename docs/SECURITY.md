# Security

## Security goals

Daymark protects persisted journal content against casual and offline access to local storage while keeping the application local-first and usable on Linux and Android.

Security-sensitive behavior should fail closed. Corrupt, partial, or ambiguous encrypted-storage states must not be silently repaired by overwriting user data.

## Journal storage

The journal uses two persistent files in the application-support directory:

- `journal.sqlite3`
- `journal.key-envelope.json`

A temporary `journal.key-envelope.json.creating` file is used during creation.

The encrypted database and key envelope are intentionally separate. An incomplete pair is treated as a storage problem.

Device appearance preferences are stored separately and are not journal secrets.

## Key hierarchy

The master password does not directly become the SQLite encryption key.

```text
master password
  -> Argon2id
  -> key-encryption key
  -> XChaCha20-Poly1305 key envelope
  -> random journal key material
  -> SQLite3MultipleCiphers database key
```

### Current key-envelope baseline

Format: `daymark-key-envelope`, version 1.

Password KDF:

- Argon2id
- memory: 19 MiB
- iterations: 2
- parallelism: 1
- output: 32 bytes

The envelope stores its KDF parameters explicitly so future defaults may change without reinterpreting existing envelopes.

Wrapping algorithm: XChaCha20-Poly1305.

Untrusted envelope parameters are validated against bounded safety limits before expensive KDF work is accepted.

Raw Argon2 benchmark evidence is retained in `docs/argon2-results/`.

## Encrypted database

Daymark requires SQLite with SQLite3MultipleCiphers support.

Current cipher: ChaCha20.

Opening an existing database performs an actual authenticated/decrypted read. Merely applying `PRAGMA key` is not considered proof that the key is correct.

Database validation used by restore also checks:

- expected schema version
- `PRAGMA integrity_check`
- `PRAGMA foreign_key_check`

## Session lifetime

Journal key material exists only while the journal is unlocked.

`JournalSession` serializes journal operations. When locking/closing begins:

1. new operations are rejected
2. queued work is allowed to finish
3. the encrypted database is closed
4. key material is destroyed

## Lock policy

An unlocked journal locks through:

- manual lock
- five minutes of inactivity
- host-system/device lock signal

Pointer, keyboard, and explicitly reported text-input activity reset the inactivity deadline. Background time still counts; the deadline is reevaluated when the application resumes.

Android reports screen-off through the Daymark platform channel. Linux listens for a real `systemd-logind` session `Lock` signal.

## Backup and restore

Encrypted Backup / Restore is a separate protected portability boundary. The container is authenticated and includes an encrypted database snapshot plus the key envelope.

Restore validates staged data completely before replacing the active journal pair and uses durable transaction/rollback state for interrupted restores.

See [`BACKUP_FORMAT.md`](BACKUP_FORMAT.md).

## Open Export

Open Export is intentionally plaintext and must be presented as such to the user. It is not a backup and cannot be treated as encrypted storage.

See [`OPEN_EXPORT_FORMAT.md`](OPEN_EXPORT_FORMAT.md).

## Android

- application ID: `io.github.marcelositr.daymark`
- Android OS backup is disabled
- release signing configuration is local and excluded from Git
- release builds fail if signing is requested without valid signing configuration

Never commit `key.properties`, `.jks`, or `.keystore` files.

## Threat boundaries

Daymark does not claim to protect an unlocked journal from a fully compromised operating system, malicious process with equivalent user privileges, screen capture, hardware compromise, or a user who reveals the master password.

Security documentation must describe implemented guarantees, not aspirational ones.

## Change rule

Changes to cryptography, key formats, database encryption, backup authentication, restore commit behavior, lock policy, Android signing, or secret handling require focused tests and explicit review. Avoid dependency or parameter changes in the same patch unless they are part of the security change being reviewed.
