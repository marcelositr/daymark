# Development

## Toolchain

Daymark pins Flutter through `.flutter-version` and constrains Dart/Flutter in `pubspec.yaml`.

Use the committed `pubspec.lock`. CI resolves dependencies with `flutter pub get --enforce-lockfile`.

## Local setup

Typical development setup:

```bash
flutter pub get --enforce-lockfile
flutter gen-l10n
dart run build_runner build
```

Run the Linux application with:

```bash
flutter run -d linux
```

Run an Android device/emulator with the normal Flutter device workflow.

## Generated sources

Localization accessors and Drift code are generated. Do not hand-edit generated files.

When the schema changes:

```bash
dart run build_runner build
dart run drift_dev make-migrations
```

CI rejects stale Drift generated artifacts.

## Validation

For a normal code change, run the checks relevant to the affected area. Before a ready-for-review product/code PR, the expected full local baseline is:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

If localization changes, run `flutter gen-l10n` first.

If the database schema changes, regenerate Drift sources and migration snapshots before formatting/analyzing/testing.

If `wiki/` changes, run:

```bash
python3 tool/validate_wiki.py
```

## Test organization

Tests are grouped by responsibility:

```text
test/
├── app/
├── backup/
├── crypto/
├── database/
├── export/
├── journal/
├── presentation/
└── session/
```

Prefer focused tests near the contract being changed. Security, persistence, migration, lineage, lock, and restore changes require regression tests for failure paths as well as success paths.

## Repository workflow

`main` is the permanent integration branch and is protected.

Use short-lived branches for active work. Historical branches may be retained as project backups; do not delete them as routine cleanup.

Ready pull requests must satisfy the repository merge gate. Squash merge is the normal default unless preserving multiple commits has a concrete reason.

Do not merge, tag, or publish a release merely because CI succeeds. Promotion is an explicit maintainer action.

## CI

The main workflow has two modes.

### Draft PR

`dev-check` performs fast structural validation without the full test/build matrix.

### Ready PR / main push

The full path includes:

- locked dependency resolution
- localization generation
- Drift generation and migration freshness
- formatting
- static analysis
- tests
- Wiki validation
- Linux release build and package validation
- Android debug APK build
- dependency review for ready PRs
- `merge-gate` on ready PRs

Linux CI produces candidate `.deb` and AppImage artifacts. Android CI intentionally builds a debug APK because release signing material remains local.

## Linux packaging

`tool/package_linux.sh` packages one Flutter Linux release bundle into:

- Debian package (`.deb`)
- AppImage

The script also validates desktop metadata, AppStream metadata, icon installation, and generated package contents.

## Android

Android application ID: `io.github.marcelositr.daymark`.

The Android build uses Java 17. Release signing is read from local `android/key.properties`; private signing material must never enter the repository.

## Documentation

Technical documentation is English and lives under `docs/`.

The repository root README is a project introduction, not an implementation manual.

The user Wiki is Portuguese (Brazil) and lives under `wiki/`. A workflow synchronizes that versioned source to the public GitHub Wiki after changes land on `main`.

## Scope discipline

Avoid unrelated cleanup inside functional changes. Especially avoid combining security, schema, dependency, packaging, and product-behavior changes unless the combined change is necessary and reviewable as one unit.

The shortest correct change is preferred over architectural expansion for its own sake.
