# Security foundation validation

## Purpose

This document defines the focused implementation and validation cycle that turns Daymark's security architecture into tested engineering constraints.

`SECURITY.md` remains the authoritative threat model and product security contract. This document is narrower: it records what must be proven before Daymark treats master-password unlock, encrypted journal persistence, recovery, and portable key handling as an implementation baseline.

The goal is not to invent cryptography. The goal is to compose mature primitives correctly, make failure explicit, and keep portable recovery independent from device-local convenience mechanisms.

## Scope of this cycle

This branch must validate, with executable tests where practical:

1. cryptographically secure generation of a random journal data-encryption key;
2. master-password key derivation using Argon2id;
3. a versioned authenticated key-envelope format outside the encrypted Drift database;
4. wrapping and unwrapping the journal key without storing the master password;
5. opening a SQLite3MultipleCiphers-backed journal only after successful key recovery;
6. proving that the on-disk journal database is not readable as plaintext SQLite;
7. wrong-password and corrupted-envelope failure behavior;
8. explicit key-material lifecycle boundaries in application code;
9. optional offline recovery-key architecture at the same portable trust layer as the master password;
10. benchmark hooks and recorded results needed to choose Argon2id parameters for Linux and Android.

## Explicitly not in this cycle

This security-foundation PR does not need to finish:

- biometric UI;
- Android Keystore integration;
- Linux Secret Service integration;
- automatic locking timers or lifecycle UI;
- the final backup archive/container format;
- cloud storage;
- synchronization;
- journal product screens.

Device-assisted unlock remains a convenience layer and will be connected only after the portable master-password/recovery path works independently.

The encrypted backup container is the next focused security task. This cycle may define reusable envelope primitives for it, but must not quietly expand into a full backup subsystem.

## Key hierarchy

The intended hierarchy remains:

```text
master password
      |
      v
Argon2id + random salt + versioned parameters
      |
      v
password-derived key-encryption key
      |
      v
authenticated wrapping of random journal key
      |
      v
random journal data-encryption key
      |
      v
SQLite3MultipleCiphers encrypted journal database
```

The master password is never stored.

The journal key is generated from a cryptographically secure random source and is not deterministically derived from the password. Changing the master password must therefore re-protect the journal key rather than require rewriting semantic journal data.

## Key-envelope boundary

Unlock metadata must exist before the encrypted database can be opened, so it remains outside the Drift journal schema.

The envelope must be small, versioned, authenticated, and portable. It may contain non-secret metadata needed to derive or select keys, such as:

- format/version identifier;
- KDF identifier;
- Argon2id parameters;
- random KDF salt;
- authenticated-encryption algorithm identifier when versioning requires it;
- nonce/IV material required by the selected reviewed primitive;
- wrapped journal-key ciphertext and authentication data;
- recovery metadata that does not expose the recovery secret itself.

The exact serialized representation is not frozen until the implementation spike proves that the chosen Dart APIs and platform behavior are maintainable.

No envelope field may contain journal content, the master password, or plaintext journal-key material.

## Password derivation

Argon2id remains the preferred password KDF.

Do not freeze parameters from a desktop-only benchmark or copy a generic value without measurement. The final parameter set must be selected from representative measurements on both initial platforms, with Android treated as a first-class constraint rather than an afterthought.

The implementation must make KDF parameters versioned data so stronger parameters can be introduced later without reinterpreting old journals.

Tests must demonstrate at minimum:

- same password + same salt + same parameters derives the same key material;
- changing salt changes derived key material;
- changing password fails authenticated unwrap;
- malformed or unsupported KDF metadata fails closed.

## Authenticated key wrapping

Daymark must use a mature authenticated-encryption primitive exposed by a reviewed package. It must not implement AEAD, MAC construction, nonce generation rules, or password hashing manually.

The selected construction must authenticate the envelope fields that influence interpretation. Version or algorithm substitution must not be silently accepted.

Tests must include:

- successful wrap/unwrap;
- wrong password;
- modified ciphertext;
- modified nonce/IV;
- modified authenticated metadata;
- truncated envelope;
- unsupported envelope version.

All integrity failures are unlock failures. The application must not attempt recovery by opening the journal with guessed/default parameters.

## Encrypted SQLite validation

The build already selects SQLite3MultipleCiphers through the `sqlite3` build hook. This cycle must prove runtime behavior, not merely trust build configuration.

The implementation must verify that expected cipher support is present before journal creation/opening. If encrypted SQLite support is unavailable, Daymark must fail closed rather than create or open a plaintext journal.

The spike must create a representative journal database using a random journal key, close it, and prove that:

- reopening with the correct journal key succeeds;
- reopening with an incorrect key fails;
- ordinary plaintext SQLite access cannot read the journal schema/content;
- the journal file does not contain representative sensitive test strings in plaintext;
- normal Drift schema/invariant behavior still works through the encrypted connection.

Exact SQLite3MultipleCiphers raw-key and salt handling must be documented from the working implementation rather than inferred from older SQLCipher examples.

## Recovery direction

The existing product decision remains: recovery is optional, offline, and account-independent.

The security foundation must preserve the ability for a securely generated recovery secret to protect/recover the same random journal key without requiring the original device or its Keystore/keyring.

The final human representation and recovery UX do not need to be frozen in this PR, but the envelope architecture must not make independent recovery impossible.

No server reset, maintainer backdoor, or hidden universal recovery mechanism is permitted.

## Sensitive-memory discipline

Dart and Flutter do not provide a universal guarantee that secret bytes can be securely zeroized from all runtime copies. The implementation must therefore avoid pretending stronger guarantees than the runtime provides.

Practical rules:

- keep plaintext password and key material scoped as narrowly as possible;
- avoid converting secret bytes to `String` except where the user password necessarily enters as text;
- do not log secrets or derived material;
- do not persist derived keys in preferences, diagnostics, crash output, or temporary files;
- do not keep unlocked journal keys in global/static state longer than the unlocked session requires;
- use explicit session/key-holder abstractions so locking can drop application references deterministically;
- document runtime limitations instead of claiming perfect memory erasure.

## Test boundary

Security tests use synthetic secrets and disposable databases only.

CI must never require real user credentials or committed secret material.

Tests should distinguish:

- expected authentication failure;
- unsupported-format failure;
- corrupted-data failure;
- missing cipher support;
- programming/configuration errors.

Failure classes must not encourage the UI to reveal whether a guessed password was "almost" correct.

## Decisions this cycle must produce

Before this PR is ready for review, it should close or explicitly defer these questions:

1. exact maintained Dart package/API used for Argon2id and key-envelope AEAD;
2. exact AEAD primitive and nonce handling;
3. envelope version-1 serialization and authenticated metadata;
4. journal-key length and representation passed to SQLite3MultipleCiphers;
5. runtime cipher-capability verification;
6. measured Argon2id parameter baseline or, if physical Android benchmarking cannot be completed in CI, the exact benchmark harness and release-blocking validation procedure;
7. recovery-envelope relationship to the primary password envelope;
8. key/session object boundaries needed for later manual/automatic lock implementation.

## Review rule

A security-format decision is a compatibility decision.

Once a prerelease containing real user journals is published, changing the key-envelope format, KDF interpretation, database-key representation, or recovery wrapping requires an explicit tested compatibility/migration path. Failure to unlock old data is data loss even when the encrypted database itself remains intact.
