# Daymark release procedure

This document defines the local packaging and release checks for Daymark prereleases and stable releases.

The authoritative release gate remains `docs/WORKFLOW.md`. This document contains platform-specific execution details and preserves the latest published release evidence.

## Latest published release

- application version: `1.0.0-alpha.2+2`;
- annotated tag: `v1.0.0-alpha.2`;
- published release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`;
- GitHub Release: `Daymark 1.0.0-alpha.2`, published as a prerelease on 2026-09-04;
- Ready PR: #32 `build(release): prepare 1.0.0-alpha.2`;
- exact Ready head: `ad3eff96d9b9459761d4bfcebb91dfbd560df95d`;
- Ready CI #474: quality, Linux, Android, dependency review, and `merge-gate` green;
- post-merge `main` CI #475: green on exact release source commit.

The release branch is complete. Future product/release work must start from current `main` rather than continuing `release/1.0.0-alpha.2`.

## Security rules

- Never commit Android signing material.
- Never paste keystore passwords, key passwords, journal passwords, recovery material, or other secrets into issues, pull requests, CI logs, or chat transcripts.
- `android/key.properties`, `*.jks`, and `*.keystore` remain local-only and ignored by Git.
- Android release builds must use an explicit release signing configuration. Daymark must not silently publish an artifact signed with the debug key.
- Release checks use disposable or controlled journal data unless the user explicitly chooses otherwise.
- Never retag or replace an already published release artifact. A changed artifact requires a new version/build according to `docs/WORKFLOW.md`.

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

The repository does not create, store, print, upload, or back up these secrets. Create and protect the keystore locally before an Android release build. Losing the signing material can prevent future install-over upgrades from being signed consistently, so keep an offline/private backup outside the repository.

Release Gradle tasks fail closed when the signing configuration or keystore is missing. Debug builds do not require release signing material.

The `v1.0.0-alpha.2` public Android lineage is signed with certificate SHA-256:

```text
44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88
```

Future Android releases intended to upgrade this public lineage must preserve signing continuity unless an explicit platform-supported signing migration is deliberately designed and tested.

## Local validation before release builds

Start from the exact release/source head with a clean working tree.

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

Release validation must cover the applicable user-data boundaries, including:

- launch the release bundle directly;
- create/unlock a controlled encrypted journal;
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

This follows the Flutter-tool workaround for the `integration_test` / `--no-pub` registrant regression observed on the pinned toolchain. Do not work around it by committing generated registrant sources, removing tests, adding `integration_test` to production dependencies, or using `flutter clean` as routine hygiene.

A release build must fail if release signing is not configured. Do not reintroduce debug signing as a fallback.

Before public distribution, test the signed release APK on physical Android hardware:

- install as a clean application when the release lineage permits it;
- create/open journal data and restart;
- lock/unlock;
- exercise backup/export file-provider flows;
- verify Appearance persistence;
- test install-over upgrade from every predecessor lineage the release claims to support;
- confirm existing encrypted journal data remains readable after the supported upgrade.

If an earlier development build uses a different signing certificate, do not call a blocked `adb install -r` path a release upgrade. Use the documented portable encrypted backup boundary to validate migration into the public release lineage.

## Published alpha.2 artifact evidence

The final locally validated release candidates were produced after the `journal_metadata` compatibility repair and superseded every earlier alpha.2 artifact.

Validated build-source head:

```text
b39be30c8e5635f93dddc5f6a2b07632e8a472ec
```

Final distributed artifact SHA-256 values:

```text
490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4  daymark-1.0.0-alpha.2-linux-x64.tar.gz
96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0  daymark-1.0.0-alpha.2-android.apk
```

GitHub's published release-asset digests match those exact Linux and Android SHA-256 values. `SHA256SUMS` is also attached to the release.

The three commits after build-source head `b39be30c...` and before Ready head `ad3eff96...` were documentation-only. Therefore Flutter/native build inputs did not change between the validated build head and the final PR tree. The tagged squash commit has the final reviewed tree, but the distributed binaries were literally produced from `b39be30c...`; preserve that distinction rather than claiming a byte-build from a later commit.

## Published alpha.2 physical Android evidence

Validation hardware: Multilaser `M7_3G_PLUS`, Android 8.1.0 / SDK 27.

The real pre-existing `1.0.0-alpha.1` installation was a debug build signed with a different certificate. The migration flow therefore deliberately did not pretend that a direct release-key install-over was possible.

Validated path:

1. identify the installed alpha.1 version, debug status, and certificate before destructive work;
2. preserve the installed APK;
3. build current code in debug mode and confirm it uses the same old debug certificate;
4. `adb install -r` that temporary debug build to preserve the real alpha.1 journal while exposing current backup behavior;
5. create a portable encrypted backup and pull it to the host;
6. additionally preserve a raw encrypted database/key-envelope/device-preferences safety snapshot before uninstall;
7. verify the raw database does not expose the plaintext SQLite header;
8. uninstall only after both safety copies exist;
9. install the signed, non-debuggable alpha.2 release cleanly;
10. restore the portable alpha.1 backup into alpha.2 and verify real journal data;
11. revalidate lock/unlock and Appearance;
12. create an alpha.2 backup and validate its v1/schema-v1 structure;
13. `adb install -r` the same signed release and verify retained data again;
14. create a second post-reinstall backup and validate it.

Migration backup SHA-256:

```text
febbd3b2247ae9a434470ee1a6458b8bd7e14d0a49e5cea75b8629803255cdff
```

Physical Android Open Export validation passed for both formats.

Markdown validation copy SHA-256:

```text
ada5a36771280785f57417f17e4d6baeaeb0720618b28e97d3ba1fe7454b206f
```

The first physical JSON validation exposed a real compatibility defect: the migrated alpha.1 journal had no `journal_metadata` row even though the data-model contract requires exactly one. Alpha.2 now initializes that singleton for new journals and idempotently repairs it on unlock for legacy journals with zero rows, while more than one row fails closed.

The repaired signed release was installed over the alpha.2 test installation without losing data. A new physical JSON Open Export contained exactly one UUID-v7 metadata row and existing entries. Validation copy SHA-256:

```text
c6c0b7b37466c91486f7793fd714ed7033acfa46c707e2e13fa5eb965e27d91e
```

Focused metadata/session/export/backup tests, analyzer, complete Flutter suite, Linux release build, Android configuration refresh, signed Android release build, exact-head Ready CI, and post-merge `main` CI passed before publication.

## Artifact identity and checksums

The Flutter application version is defined in `pubspec.yaml`. Android's version code comes from the build number after `+` and must increase monotonically for distributable Android artifacts.

For directly distributed artifacts, record SHA-256 checksums. A checksum belongs to one exact artifact and must be regenerated whenever the artifact changes.

Do not retag or replace a published release artifact. Any changed artifact requires a new version/build number according to `docs/WORKFLOW.md`.

## Release gate for future versions

Before creating a future tag or GitHub Release, require all applicable gates:

- exact release branch/main source commit known and clean;
- complete tests green;
- Linux release build and manual smoke test green;
- signed Android release build and physical-device smoke test green;
- backup/restore compatibility check green for supported predecessors;
- clean-install and install-over upgrade checks green where applicable;
- dependency/security review complete;
- no signing secrets or local-only files in Git;
- `CHANGELOG.md` and `PROJECT.md` aligned;
- exact Ready PR `merge-gate` green;
- explicit user approval for merge and release promotion;
- annotated `vX.Y.Z...` tag created only from the approved release commit;
- GitHub Release marked prerelease for alpha/beta/RC versions;
- directly distributed artifacts accompanied by SHA-256 checksums and verified after upload.
