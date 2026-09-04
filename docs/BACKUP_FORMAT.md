# Encrypted backup format

## Status

This document defines Daymark's portable encrypted backup container and restore safety contract.

Backup format version 1 shipped in public prerelease `v1.0.0-alpha.2` and is now a compatibility-sensitive boundary. A later supported build must either preserve version-1 restore support or provide an explicit tested migration path. A future format must not silently reinterpret version-1 bytes.

## Goals

A Daymark backup must:

- remain encrypted at rest;
- be portable between supported platforms;
- remain recoverable without the original Android/Linux device when the user has the portable credential;
- identify its format and database schema version before destructive restore work;
- detect modification, truncation, splicing, or accidental corruption before restore commit;
- validate the encrypted database before replacing an existing journal;
- recover safely from an application/process interruption during replacement;
- avoid dependencies on Android Keystore, Linux keyrings, machine identity, filesystem paths, or cloud accounts.

Version 1 intentionally does not define scheduled backup, retention rotation, remote storage, attachments, or recovery-secret UX. The current application does provide user-facing manual file selection/save and restore around this container; those presentation/file-gateway details are not part of the binary format contract.

## Security composition

Version 1 does not introduce a new encryption primitive.

The payload database is already encrypted with the journal's SQLite3MultipleCiphers ChaCha20-Poly1305 key material. The included key envelope is already authenticated and encrypted with the master-password Argon2id + XChaCha20-Poly1305 construction defined in `SECURITY.md`.

The backup container adds whole-container integrity with:

- HKDF-SHA256 for key separation;
- HMAC-SHA256 for container authentication;
- a random 16-byte integrity salt per backup.

The HKDF input keying material is the existing 48-byte serialized journal key material. The HKDF context string is:

```text
daymark-backup-v1-integrity
```

The derived integrity key is used only for HMAC-SHA256. It is not used as a database key or key-encryption key.

## Version-1 binary layout

All fixed-width integers use unsigned big-endian encoding.

```text
+----------------------+-------------------------------------------+
| Field                | Size                                      |
+----------------------+-------------------------------------------+
| Magic                | 16 bytes                                  |
| Format version       | uint32                                    |
| Manifest length      | uint32                                    |
| Key-envelope length  | uint32                                    |
| Database length      | uint64                                    |
| Manifest             | manifest length bytes, UTF-8 JSON         |
| Key envelope         | envelope length bytes, UTF-8 JSON         |
| Encrypted database   | database length bytes                     |
| HMAC-SHA256          | 32 bytes                                  |
+----------------------+-------------------------------------------+
```

The fixed header is 36 bytes.

The 16-byte magic value is:

```text
DAYMARK-BACKUP\0\0
```

The HMAC covers every byte from the magic through the final encrypted-database byte. The trailing 32-byte HMAC itself is not included in its own input.

The parser validates fixed lengths and the exact total file size before allocating or staging payload data. Version 1 limits the manifest and key envelope to 64 KiB each.

The backup service streams the encrypted database payload while constructing/validating the container rather than requiring the encrypted SQLite snapshot to be held as one application byte array.

### Application/file-picker memory boundary

Do not describe Daymark's current user-facing backup save path as streaming end-to-end.

The service produces a completed encrypted backup container, but the current application/file-picker gateway may read that **already-encrypted container** into memory before handing bytes to the native file-save API. The owned mutable byte buffer is cleared after the handoff where practical.

This distinction matters:

- the buffered bytes are encrypted backup-container bytes, not plaintext journal content;
- the binary format/service design remains streaming-capable for the database payload;
- the current native file-save handoff can have memory cost proportional to the completed encrypted container size;
- a future file API may remove that buffering without changing backup format v1.

Never claim plaintext buffering or full end-to-end streaming unless the implementation actually demonstrates it.

## Manifest

The version-1 manifest is strict JSON. Unknown or missing fields are rejected rather than silently ignored.

Logical shape:

```json
{
  "format": "daymark-backup",
  "version": 1,
  "createdAtUtcMicros": 0,
  "databaseSchemaVersion": 1,
  "databaseCipher": "sqlite3mc-chacha20",
  "keyEnvelopeFormat": "daymark-key-envelope",
  "keyEnvelopeVersion": 1,
  "integrity": {
    "kdf": "hkdf-sha256",
    "mac": "hmac-sha256",
    "salt": "base64url-encoded-16-byte-random-salt"
  }
}
```

The creation timestamp is metadata only and is not used to order or choose restore candidates automatically.

`databaseSchemaVersion` is an explicit compatibility declaration. Version-1 alpha.2 backups contain schema version 1. Future schema versions require a reviewed compatibility/migration path before accepting older or newer backup schemas.

## Backup creation

Backup creation follows this sequence:

1. require a currently valid encrypted journal database;
2. require the master password and the journal's current portable key envelope;
3. unwrap the envelope and constant-time compare the recovered serialized journal key material with the active journal key material;
4. create a transactionally consistent encrypted SQLite snapshot through SQLite's online backup API;
5. generate the random backup-integrity salt;
6. build the strict manifest and fixed header;
7. derive the HMAC key with HKDF-SHA256;
8. stream header, manifest, key envelope, and encrypted snapshot into a temporary backup container while calculating HMAC-SHA256 over the same bytes;
9. append the MAC;
10. flush and finalize the completed temporary container;
11. remove temporary encrypted snapshot/container files when no longer needed.

The service refuses to intentionally overwrite an existing backup path. The user-facing application layer may request an explicit destination/replace operation through the platform file provider, but replacement remains a deliberate user action.

A stale or unrelated key envelope is rejected during backup creation. This prevents generating a container whose database and portable credential refer to different journal keys.

## Restore validation

Restore performs no destructive journal replacement until all of these checks pass:

1. fixed magic/version/length parsing;
2. strict manifest parsing and metadata bounds;
3. key-envelope unwrap with the supplied master password;
4. whole-container HMAC verification using constant-time MAC comparison;
5. supported backup/database-schema compatibility;
6. extraction of the still-encrypted database into a staging file;
7. encrypted SQLite capability and correct-key read validation;
8. exact expected SQLite `user_version` validation;
9. `PRAGMA integrity_check` validation;
10. `PRAGMA foreign_key_check` validation.

Wrong password, invalid key envelope, modified authenticated bytes, truncated data, unsupported format versions, incompatible schema versions, and invalid encrypted databases therefore fail before restore commit.

## Restore transaction and rollback

The database and key envelope are a logical pair. Version 1 uses staged files plus a small restore-transaction marker so replacing that pair is rollback-safe across an application/process interruption.

Reserved sibling paths use these suffixes:

```text
.restore-staged
.restore-rollback
.restore-transaction
```

The marker records only the Daymark restore-transaction format/version and whether a complete destination journal pair existed before the restore.

Commit sequence:

1. fully stage and validate the replacement database and envelope;
2. write and flush the restore-transaction marker before moving any current journal file;
3. when a current pair exists, rename both current files to rollback paths;
4. rename the staged database into the destination;
5. rename the staged key envelope into the destination;
6. delete the transaction marker; this is the logical commit point;
7. delete the old encrypted rollback copies on a best-effort basis.

If an in-process failure occurs before the marker is deleted, the service immediately invokes interrupted-restore recovery.

If the application/process terminates before the marker is deleted, the next storage startup/restore recovery pass must call `recoverInterruptedRestore` before opening the destination journal. Recovery always aborts the interrupted replacement:

- when an old journal pair existed, rollback files replace any partially installed new files;
- when the destination was new, partially installed files are removed.

If the marker has already been deleted, the new pair is committed. Any rollback files left by a crash after that commit point are stale encrypted cleanup residue and may be deleted when a complete committed destination pair is present.

Dart does not expose a portable directory-fsync transaction primitive across Linux and Android. Daymark therefore describes this contract as rollback-safe application-level recovery rather than claiming filesystem/power-loss atomicity stronger than the runtime can guarantee.

## Session and UI boundary

The backup snapshot may be taken while normal journal persistence exists because SQLite's backup API provides a transactionally consistent snapshot.

Restore replacement is different: an active application session using the destination journal must be closed before commit. The application exposes restore only while the journal is locked or absent so it cannot replace files beneath a live encrypted database connection.

The session/application boundary responsible for restore must:

1. ensure the destination persistence session is not active;
2. invoke interrupted-restore recovery before opening journal storage;
3. perform restore and validate before replacement commit;
4. reopen only from the committed destination pair.

`JournalSession` remains the unlocked journal-lifetime boundary. Backup/restore UI and platform file selection must integrate with that existing lifecycle rather than creating a competing session abstraction.

## Password changes

A backup contains the key envelope that was current when the backup was created. Changing the live journal's master password re-wraps the same random journal key but does not rewrite historical external backups.

Therefore an older backup remains protected by the older password with which its included envelope was created. Daymark should recommend creating a fresh backup after a password change.

## Future attachments

Version 1 contains only the encrypted SQLite snapshot because attachments are not part of schema/product scope yet.

Future attachment support must not append unauthenticated plaintext files beside the backup. A later backup format version may add framed encrypted payload members while preserving:

- authenticated interpretation-sensitive metadata;
- encryption at rest;
- streaming validation/copying where the platform API permits it;
- explicit format versioning;
- restore staging before commit.

## Plaintext export remains separate

Markdown/JSON Open Export is intentionally outside this format. A user-requested human-readable export is plaintext and must remain a different operation with a clear security warning.

Encrypted Backup / Restore is the recovery and migration boundary. Open Export is portability for reading/machine processing, not restore.
