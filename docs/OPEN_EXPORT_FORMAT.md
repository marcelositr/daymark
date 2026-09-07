# Open Export format

## Purpose

Open Export is Daymark's explicit plaintext portability boundary.

It is designed for inspection, archival use, and interoperability. It is **not encrypted** and it is **not a restore format**.

## Current format

Format name: `daymark-open-export`

Format version: **2**

The export also records the Daymark database schema version that produced it.

## Output formats

Daymark can render the same logical export as:

- JSON
- Markdown

Both outputs contain the same journal structures.

## Exported sections

The current format includes:

- journal metadata
- Logs
- Collections
- Entries
- Entry placements
- migration lineage
- Collection references
- Signifiers
- Entry ↔ Signifier relationships
- Index items
- Trackers
- Tracker marks

The JSON representation uses camelCase field names.

## Consistency

Export generation runs inside a database transaction so all sections represent one consistent logical view of the journal.

Export does not mutate journal state.

## Plaintext warning

Exported content is readable without the Daymark master password.

The UI must clearly distinguish Open Export from encrypted Backup / Restore. Users are responsible for protecting exported files after they leave Daymark.

## JSON

JSON is the machine-oriented representation.

Top-level metadata includes:

```json
{
  "format": "daymark-open-export",
  "formatVersion": 2,
  "databaseSchemaVersion": 2
}
```

The remaining top-level properties contain ordered arrays for each exported table-like structure.

## Markdown

Markdown is the human-readable representation.

It includes format metadata, an explicit plaintext warning, and one section for every exported structure.

Entry content is rendered in fenced text blocks where appropriate so arbitrary user text remains readable.

## Compatibility rule

`formatVersion` describes the Open Export contract, not the database schema.

If an incompatible Open Export structure is introduced, increment `formatVersion` and update format tests/documentation.

Database schema changes do not automatically require a new Open Export version if the exported contract remains backward-compatible.
