# Daymark Open Export format

Open Export is Daymark's explicit plaintext portability boundary. It is separate from encrypted backup and is not a recovery format.

## Security boundary

Creating an Open Export is an explicit user action that writes journal content outside Daymark's encrypted database.

- JSON and Markdown exports are plaintext.
- Exported files are not protected by Daymark's journal encryption.
- Open Export must remain clearly distinguished from the authenticated encrypted backup/restore flow.
- Daymark does not create Open Export files automatically or transmit them to a remote service.

Users who need protected recovery should use encrypted backup instead.

## JSON format v1

The machine-readable export has these top-level fields, in this order:

- `format`: `daymark-open-export`;
- `formatVersion`: `1`;
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
- `indexItems`.

Field names are language-neutral camelCase keys. Stable IDs, Task states, owners, ordering fields, migration lineage, Collection references, signifier relationships, and Index targets are preserved rather than flattened into display text.

Records are emitted in explicit deterministic orders. The export does not include an export timestamp, random nonce, localized labels, or other volatile metadata, so exporting an unchanged journal twice produces identical JSON bytes.

JSON strings use standard JSON escaping and UTF-8 when written by the UI.

## Markdown format v1

Markdown is a human-readable rendering of the same snapshot used for JSON. It begins with the Open Export identifier, format version, database schema version, and an explicit plaintext warning.

Each exported table is rendered as a section. Entry content and other multiline scalar values use dynamically sized fenced text blocks. Inline scalar values use dynamically sized Markdown code spans so literal backticks do not corrupt the document structure.

Markdown is intended for reading and archival portability. It is not an import or restore contract.

## Consistency

A single export is created inside a database transaction, so every table in that export reflects one consistent journal snapshot.

Open Export does not mutate journal data, create Logs, alter Task state, create Index items, or change ownership.

## Compatibility

`formatVersion` governs the Open Export structure. `databaseSchemaVersion` records the source journal schema separately.

Future incompatible changes to the machine-readable contract require a new Open Export format version. Existing version-1 keys must not be silently reinterpreted.
