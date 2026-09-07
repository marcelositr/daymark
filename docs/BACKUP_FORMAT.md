# Encrypted backup format

## Purpose

Daymark Backup / Restore is the protected recovery and migration format for a complete journal.

It is distinct from Open Export. Backups remain encrypted; Open Export is plaintext.

## Current format

Format name: `daymark-backup`

Version: **1**

A backup contains:

1. fixed binary header
2. JSON manifest
3. encoded Daymark key envelope
4. encrypted SQLite snapshot
5. trailing HMAC-SHA256 authentication tag

The authenticated region covers the entire container except the trailing MAC itself.

## Database snapshot

Daymark creates the database payload using SQLite's online backup API through the configured encrypted database connection.

This produces a transactionally consistent encrypted snapshot rather than copying a potentially changing database file byte-for-byte.

The snapshot uses the same journal key material and remains independently encrypted at rest.

## Manifest

The manifest records compatibility and integrity metadata, including:

- creation timestamp
- database schema version
- random integrity salt
- database cipher identity
- integrity KDF/MAC identity

Implementations must reject unsupported or malformed metadata rather than guessing compatibility.

## Integrity key

The backup authentication key is derived from journal key material with:

- HKDF-SHA256
- random per-backup salt
- Daymark-specific context string

Authentication uses HMAC-SHA256.

This keeps the backup-integrity key separate from the database key.

## Creation requirements

Backup creation requires:

- an unlocked journal
- the master password for reauthentication
- matching active key material and key envelope
- a destination path that does not already exist

Daymark refuses to overwrite an existing backup.

Before producing the container, Daymark verifies that the supplied master password can unwrap the current key envelope and that the recovered key material matches the active journal key.

Temporary snapshot/container files are removed on a best-effort basis after success or failure.

## Restore validation

Restore is staged. The active journal is not replaced before the incoming backup passes validation.

Validation includes:

1. parse container metadata and bounds
2. unwrap the embedded key envelope with the supplied master password
3. authenticate the backup container
4. verify supported format/schema compatibility
5. extract encrypted database to staging
6. stage the key envelope
7. open/validate the encrypted database
8. verify expected schema version
9. run SQLite integrity check
10. run foreign-key check

Only after these checks does commit begin.

## Restore commit and recovery

Restore uses staged files plus rollback files and a durable transaction marker.

If a previous journal exists, commit preserves enough rollback material to restore the original pair after an interrupted commit.

If no journal existed before restore, interruption recovery removes any partially installed pair.

`JournalSessionManager.inspect()` asks the backup service to recover interrupted restore state before deciding whether storage is locked, empty, or invalid.

## Fail-closed rules

Daymark must reject, rather than auto-repair:

- invalid authentication
- malformed key envelope
- unsupported backup format
- incompatible database schema
- invalid encrypted database
- incomplete destination journal pair without valid restore transaction state
- unexpected rollback material

## Compatibility

Changing any of the following requires a new compatible parser/version strategy and tests:

- binary header layout
- manifest meaning
- authentication derivation
- key-envelope embedding
- database payload expectations
- restore transaction semantics

Never reinterpret an existing version number with incompatible behavior.
