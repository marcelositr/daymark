# Daymark Open Export format

Open Export is Daymark's explicit plaintext portability boundary. It is separate from encrypted backup and is not a recovery format.

Open Export format version 1 shipped in public prerelease `v1.0.0-alpha.2` and is now a compatibility-sensitive machine-readable boundary. Future incompatible structural changes require a new Open Export format version; existing version-1 fields must not be silently reinterpreted.

## Security boundary

Creating an Open Export is an explicit user action that writes journal content outside Daymark's encrypted database.

Before Daymark creates any plaintext representation, the user must re-enter the current master password. Reauthentication validates the existing authenticated key envelope with temporary key material that is destroyed immediately; it does not replace or reopen the live journal session.

- JSON and Markdown exports are plaintext.
- The UI may save the selected format to a file or copy it to the system clipboard.
- Exported files are not protected by Daymark's journal encryption.
- Clipboard contents are outside Daymark's encryption boundary and may be readable by other applications or retained by a clipboard manager.
- Open Export remains clearly distinguished from the authenticated encrypted Backup / Restore flow.
- Daymark does not create Open Export files automatically or transmit them to a remote service.
- Open Export is not an import or disaster-recovery contract.

Users who need protected recovery or migration should use encrypted Backup instead.

## JSON format v2

The machine-readable export has these top-level fields, in this order:

- `format`: `daymark-open-export`;
- `formatVersion`: `2`;
- `databaseSchemaVersion`: the Daymark database schema version used to interpret the exported records;
- `journalMetadata`;
- `logs`;
- `collections`;
- `entries`;
- `entryPlacements`;
- `migrations`;
- `collectionReferences`;
- `signifiers`;
- `entrySignifiers`;
- `indexItems`;
- `trackers`;
- `trackerMarks`.

Field names are language-neutral camelCase keys. Stable IDs, Task states, owners, ordering fields, migration lineage, Collection references, signifier relationships, Index targets, Tracker periods/visual slots, and explicit Tracker marks are preserved rather than flattened into display text. `0` Tracker values are not exported as synthetic rows because the Tracker model persists only explicit `+1` and `-1` marks.

Records are emitted in explicit deterministic orders. The export does not include an export timestamp, random nonce, localized labels, or other volatile metadata, so exporting an unchanged journal twice produces identical JSON bytes.

JSON strings use standard JSON escaping and UTF-8 when written by the UI.

A normal unlocked journal has exactly one `journalMetadata` row. Alpha.2 initializes this singleton for new journals and repairs older development journals with zero rows on unlock before journal work proceeds; more than one row remains corruption and fails closed rather than being silently exported as an arbitrary identity.

## Markdown format v2

Markdown is a human-readable rendering of the same snapshot used for JSON. It begins with the Open Export identifier, format version, database schema version, and an explicit plaintext warning.

Each exported table is rendered as a section. Entry content and other multiline scalar values use dynamically sized fenced text blocks. Inline scalar values use dynamically sized Markdown code spans so literal backticks do not corrupt the document structure.

Markdown is intended for reading and archival portability. It is not an import or restore contract.

## Consistency

A single export is created inside a database transaction, so every table in that export reflects one consistent journal snapshot.

Open Export does not mutate journal data, create Logs, alter Task state, create Index items, change ownership, or alter the encrypted backup state.

## Compatibility

`formatVersion` governs the Open Export structure. `databaseSchemaVersion` records the source journal schema separately.

Version 1 is published in `v1.0.0-alpha.2` with database schema version 1. Its keys retain their published meaning.

Version 2 accompanies database schema version 2 and adds `trackers` and `trackerMarks` after the version-1 sections. This is an explicit format-version change rather than silently changing the version-1 machine-readable contract.

A future Daymark release may add another Open Export format version, but it must not silently reinterpret the meaning of published keys. If backward machine readability is claimed, compatibility must be explicit and tested.

Open Export compatibility does not imply that a version-1 JSON file can be restored into Daymark. Restore compatibility belongs exclusively to the encrypted backup format and database migration contracts.
