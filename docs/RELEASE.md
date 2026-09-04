# Daymark release procedure

This document defines the local packaging and release checks for Daymark prereleases and stable releases.

The authoritative release gate remains `docs/WORKFLOW.md`. This document contains platform-specific execution details.

## Current release target

The current stabilization target is `1.0.0-alpha.2+2`, tagged as `v1.0.0-alpha.2` only after the exact approved release commit has passed all release checks.

## Security rules

- Never commit Android signing material.
- Never paste keystore passwords, key passwords, journal passwords, recovery material, or other secrets into issues, pull requests, CI logs, or chat transcripts.
- `android/key.properties`, `*.jks`, and `*.keystore` remain local-only and are ignored by Git.
- Android release builds must use an explicit release signing configuration. Daymark must not silently publish an artifact signed with the debug key.
- Release checks use disposable or controlled journal data unless the user explicitly chooses otherwise.

## Android release signing

Daymark reads release signing data from `android/key.properties`.

Required properties:

```properties
storeFile=daymark-upload.jks
storePassword=<local secret>
keyAlias=daymark-upload
keyPassword=<local secret>
```

With this layout the keystore lives at `android/daymark-upload.jks`.

The repository does not create, store, print, upload, or back up these secrets. Create and protect the keystore locally before the first Android release build. Losing the signing material can prevent future upgrades from being signed consistently, so keep an offline backup outside the repository.

Release Gradle tasks fail closed when the signing configuration or keystore is missing. Debug builds do not require release signing material.

## Local validation before release builds

Start from the exact release branch head with a clean working tree.

Run the normal validation ladder first:

1. locked dependency resolution;
2. localization and generated-source checks when applicable;
3. formatter;
4. analyzer;
5. focused tests for changed release behavior;
6. complete Flutter suite;
7. exact native release builds.

Do not use `flutter clean` as routine release hygiene. Preserve warm caches unless a failure specifically requires a controlled clean rebuild.

## Linux release build

Build:

```text
flutter build linux --release --no-pub
```

Flutter places the relocatable bundle under `build/linux/x64/release/bundle/` on the current x64 Linux host. The complete bundle directory is the distributable runtime unit; the executable alone is insufficient.

Release validation must:

- launch the release bundle directly;
- create/unlock a disposable encrypted journal;
- verify persistence across restart;
- verify manual lock/unlock;
- verify Appearance persistence;
- create and restore an encrypted backup using controlled data;
- create JSON and Markdown Open Export files;
- inspect native shared-library requirements with `ldd`;
- verify no unexpected plaintext journal database is created.

## Android release build

The pinned Flutter toolchain can leave `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` configured with the dev-only `integration_test` plugin after dependency/test work. A subsequent Android build with `--no-pub` can then fail at `compileReleaseJavaWithJavac` because `IntegrationTestPlugin` is intentionally absent from the release classpath.

Refresh the Android host configuration before a `--no-pub` release build:

```text
flutter build apk --config-only
flutter build apk --release --no-pub
```

This follows the Flutter tool workaround for the `integration_test` / `--no-pub` registrant regression. Do not work around it by committing generated registrant sources, removing tests, adding `integration_test` to production dependencies, or using `flutter clean` as routine hygiene.

A release build must fail if release signing is not configured. Do not reintroduce debug signing as a fallback.

Before any public distribution, test the signed release APK on physical Android hardware:

- install as a clean application;
- create journal data and restart;
- lock/unlock;
- exercise backup/export file-provider flows;
- verify Appearance persistence;
- install the next build over the existing installation when testing an upgrade path;
- confirm existing encrypted journal data remains readable after the upgrade.

## Current alpha.2 validation evidence

The latest locally validated release candidates were produced after the `journal_metadata` compatibility repair and supersede every earlier alpha.2 artifact built before that repair.

Validated source head before final documentation-only commits:

```text
b39be30c8e5635f93dddc5f6a2b07632e8a472ec
```

Release artifact SHA-256 values:

```text
490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4  daymark-1.0.0-alpha.2-linux-x64.tar.gz
96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0  daymark-1.0.0-alpha.2-android.apk
```

Android release certificate SHA-256:

```text
44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88
```

Physical Android validation used a Multilaser `M7_3G_PLUS` running Android 8.1.0 / SDK 27. The real pre-existing `1.0.0-alpha.1` debug installation was first identified by version and certificate, then updated with a current-code debug build carrying the same debug certificate solely to create a portable migration backup. Before removing that debug installation, the backup was copied to the host and a second raw safety snapshot preserved the encrypted database, key envelope, and device preferences. The raw database did not expose the plaintext SQLite header.

The migration backup was then restored into the clean signed, non-debuggable alpha.2 release. Existing journal data, lock/unlock, Appearance persistence, backup creation, and same-release `adb install -r` retention were verified. The migration backup SHA-256 is:

```text
febbd3b2247ae9a434470ee1a6458b8bd7e14d0a49e5cea75b8629803255cdff
```

Physical Android Open Export validation passed for both formats. Markdown passed the format/version/schema header, explicit plaintext warning, complete section set, and UTF-8 validation. Its validation copy SHA-256 is:

```text
ada5a36771280785f57417f17e4d6baeaeb0720618b28e97d3ba1fe7454b206f
```

The first physical JSON validation exposed a real compatibility defect: the migrated alpha.1 journal had no `journal_metadata` row even though the data-model contract requires exactly one. Alpha.2 now initializes that singleton for new journals and idempotently repairs it on unlock for legacy journals with zero rows, while more than one row still fails closed. Focused metadata/session/export/backup tests, analyzer, the full Flutter suite, Linux release build, Android configuration refresh, and signed Android release build passed after the repair.

The repaired release was installed over the signed alpha.2 test installation without losing data. A new physical JSON Open Export then contained exactly one UUID-v7 metadata row and passed format v1 / schema v1 validation. Its SHA-256 is:

```text
c6c0b7b37466c91486f7793fd714ed7033acfa46c707e2e13fa5eb965e27d91e
```

The release branch still requires exact-head Ready CI and explicit user approval before merge, tagging, or publication. Documentation-only commits after the validated build head do not retroactively change artifact bytes, but the final release process must preserve the exact source/artifact mapping in the PR and GitHub Release notes.

## Artifact identity and checksums

The Flutter application version is defined in `pubspec.yaml`. Android's version code comes from the build number after `+` and must increase monotonically for distributable Android artifacts.

For directly distributed artifacts, record SHA-256 checksums. A checksum belongs to one exact artifact and must be regenerated whenever the artifact changes.

Do not retag or replace a published release artifact. Any changed release artifact requires a new version/build number according to `docs/WORKFLOW.md`.

## Final release gate

Before creating a tag or GitHub Release, require all of the following:

- exact release branch/main commit known and clean;
- complete tests green;
- Linux release build and manual smoke test green;
- signed Android release build and physical-device smoke test green;
- backup/restore compatibility check green;
- clean-install and upgrade checks green where applicable;
- dependency/security review complete;
- no signing secrets or local-only files in Git;
- `CHANGELOG.md` and `PROJECT.md` aligned;
- exact Ready PR `merge-gate` green;
- explicit user approval for merge/release;
- annotated `vX.Y.Z...` tag created only from the approved release commit;
- GitHub Release marked prerelease for alpha/beta/RC versions;
- directly distributed artifacts accompanied by SHA-256 checksums.
