# Daymark release procedure

This document defines local packaging and release checks for Daymark prereleases, stable releases, and maintenance releases.

The authoritative release gate remains `docs/WORKFLOW.md`. `PROJECT.md` records the active release state.

## Product freeze

Daymark's functional product scope is frozen.

A release branch is a stabilization boundary, not a feature branch. Release preparation may contain only:

- version/release metadata;
- documentation alignment;
- packaging/signing/CI corrections;
- bug/security/compatibility fixes discovered during release validation.

No new product capability belongs in a release branch while the freeze is active.

## Active release preparation

Current candidate:

- application version: `1.0.0-alpha.3+3`;
- planned annotated tag: `v1.0.0-alpha.3`;
- release branch: `release/1.0.0-alpha.3`;
- release base: current `main` squash `a08c5f8f1e2bc340801f9e3f33e9353d6cb9122b` (PR #41);
- release name: `Daymark 1.0.0-alpha.3`;
- GitHub Release type: prerelease;
- target platforms: Linux x64 and Android;
- Android build number/version code: `3`.

Alpha.3 is the release-validation packaging of the completed post-alpha.2 product line. It includes schema v2 / Monthly Trackers, navigation/reflection/security/Open Export improvements, branding/UI/accessibility polish, and About/support identity. It does not begin another feature stage.

Until alpha.3 is explicitly promoted/published, the latest public release remains alpha.2.

## Latest published release

- application version: `1.0.0-alpha.2+2`;
- annotated tag: `v1.0.0-alpha.2`;
- published release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`;
- GitHub Release: `Daymark 1.0.0-alpha.2`, published as a prerelease on 2026-09-04;
- Ready PR: #32 `build(release): prepare 1.0.0-alpha.2`;
- exact Ready head: `ad3eff96d9b9459761d4bfcebb91dfbd560df95d`;
- Ready CI #474: quality, Linux, Android, dependency review, and `merge-gate` green;
- post-merge `main` CI #475: green on exact release source commit.

## Security rules

- Never commit Android signing material.
- Never paste keystore passwords, key passwords, journal passwords, key/recovery material, or other secrets into issues, PRs, CI logs, or chat transcripts.
- `android/key.properties`, `*.jks`, and `*.keystore` remain local-only and ignored by Git.
- Android release builds use explicit release signing and fail closed when configuration/keystore is missing.
- Release checks use disposable/controlled journal data unless the maintainer explicitly chooses otherwise.
- Never retag or replace a published release artifact. A changed artifact requires a new version/build.

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

The repository does not create, store, print, upload, or back up these secrets. Protect the keystore outside the repository.

The public Android lineage beginning with `v1.0.0-alpha.2` is signed with certificate SHA-256:

```text
44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88
```

Alpha.3 intended as an install-over upgrade must use the same signing lineage. Confirm the built APK certificate before distribution.

## Local validation before release builds

Start from the exact release/source head with a clean working tree.

Normal release validation order:

1. locked dependency resolution;
2. localization generation when applicable;
3. Drift/code generation plus migration snapshot/reproducibility checks;
4. pinned formatter;
5. analyzer;
6. focused tests for changed release/maintenance behavior;
7. complete Flutter suite;
8. exact native release builds;
9. manual Linux/physical-Android release flows.

Do not use `flutter clean` as routine release hygiene.

When Drift migration tests are part of the run, keep temporary generated migration sources present through analyzer/full tests. Remove them only after checks that import them finish.

## Linux release build

Build:

```text
flutter build linux --release --no-pub
```

Flutter places the relocatable bundle under `build/linux/x64/release/bundle/` on the current x64 Linux host. The complete bundle directory is the distributable runtime unit.

Alpha.3 Linux validation should cover at least:

- launch release bundle directly;
- create/open a controlled encrypted journal;
- persistence across restart;
- manual lock/unlock;
- Today/Monthly/Future/Collections/Search/Index basic navigation;
- Monthly Tracker creation/marking/history behavior with controlled data;
- Appearance persistence;
- About/version/project identity;
- encrypted Backup creation/Restore using controlled data;
- Open Export wrong-password rejection before plaintext creation;
- JSON/Markdown Save after successful reauthentication;
- JSON/Markdown clipboard Copy warning/notice flow;
- `ldd` inspection of native shared-library requirements;
- no unexpected plaintext journal database.

## Android release build

The pinned Flutter toolchain can leave `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` configured with the dev-only `integration_test` plugin after dependency/test work. A later `--no-pub` release build may fail because `IntegrationTestPlugin` is absent from the release classpath.

Refresh Android host configuration before a `--no-pub` release build:

```text
flutter build apk --config-only
flutter build apk --release --no-pub
```

Do not work around this by committing generated registrant sources, removing tests, adding `integration_test` to production dependencies, or routinely running `flutter clean`.

A release build must fail when release signing is not configured.

## Alpha.2 -> alpha.3 compatibility gate

This is the most important alpha.3 release-specific validation because alpha.2 is published with schema v1 and alpha.3 contains schema v2.

Use controlled data and a real release-signed alpha.2 installation.

Required direct-upgrade path:

1. install/use public `v1.0.0-alpha.2` signed APK;
2. create or retain controlled representative journal data across Today/Monthly/Future/Collections and other existing alpha.2 surfaces;
3. create an encrypted alpha.2 backup before install-over as a safety/compatibility artifact;
4. verify the candidate alpha.3 APK uses the same public release-signing certificate;
5. install alpha.3 over alpha.2 using the supported install-over path;
6. unlock with the existing master password;
7. confirm schema-v1 data migrated to schema v2 without loss or reset;
8. confirm restart persistence after migration;
9. confirm Today/Monthly/Future/Collections/Search/Index and Task states/lineage remain correct;
10. create/mark/end a Tracker after migration and confirm persistence;
11. validate Backup / Restore behavior on alpha.3;
12. validate Open Export reauthentication plus JSON/Markdown Save/Copy;
13. validate Appearance and About/version identity.

Required independent backup path:

1. preserve a known alpha.2 encrypted backup;
2. restore it into a controlled alpha.3 environment where restore is allowed;
3. confirm restored schema-v1 journal opens/migrates correctly and existing data remains intact;
4. confirm Tracker/schema-v2 operations work after restore/migration.

A failure in either path is a release blocker. Do not "fix" compatibility by deleting/recreating user journal data.

## Physical Android alpha.3 smoke test

Before public distribution test the signed candidate on physical Android hardware:

- direct alpha.2 -> alpha.3 install-over as above;
- unlock/restart persistence;
- manual/inactivity/system-lock paths where practical;
- Today/Monthly/Future/Collections basic operation;
- Tracker operation after upgrade;
- Backup/Restore file-provider flow;
- Open Export reauthentication, Save, and clipboard Copy;
- Appearance persistence;
- About version/project identity;
- clean install of alpha.3 where useful as a separate sanity check.

Do not expose real private journal content or signing secrets in release evidence.

## Artifact names

Alpha.3 distributed artifacts use:

```text
daymark-1.0.0-alpha.3-linux-x64.tar.gz
daymark-1.0.0-alpha.3-android.apk
SHA256SUMS
```

The Linux artifact contains the complete Flutter release bundle, not only the executable.

`SHA256SUMS` records exact SHA-256 identities for both distributed artifacts.

## Artifact identity

The Flutter application version is defined in `pubspec.yaml`. The About version constant is regression-tested against that value.

Android version code comes from the build number after `+` and must increase monotonically for distributable Android artifacts.

A checksum belongs to one exact artifact and must be regenerated whenever the artifact changes.

Never publish an artifact from a different source head without recording that distinction. If documentation-only commits occur after validated binaries are built, record the exact build-source head separately rather than pretending the binaries were built from a later commit.

## Alpha.3 Ready gate

Before creating the alpha.3 tag/GitHub Release require:

- release branch/head exact and clean;
- `pubspec.yaml` and About display version `1.0.0-alpha.3+3`;
- complete tests green;
- schema-v1-to-v2 migration tests green;
- Linux release build/manual smoke green;
- signed Android release build/physical smoke green;
- direct public alpha.2 -> alpha.3 install-over green;
- alpha.2 encrypted backup -> alpha.3 restore/migration green;
- Open Export reauthentication/Save/Copy checks green;
- signing certificate continuity confirmed;
- dependency/security review complete;
- no signing secrets/local-only files in Git;
- product-scope freeze respected, with no feature additions in the release branch;
- `README.md`, `PROJECT.md`, `docs/PRODUCT.md`, `SECURITY.md`, `docs/WORKFLOW.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CHANGELOG.md`, and this file aligned;
- exact Ready PR `merge-gate` green;
- explicit maintainer approval for merge;
- explicit maintainer approval for tag/release publication;
- annotated `v1.0.0-alpha.3` tag created only from approved release source;
- GitHub Release marked prerelease;
- uploaded artifact checksums verified after upload.

## Published alpha.2 artifact evidence

Final distributed alpha.2 SHA-256 values:

```text
490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4  daymark-1.0.0-alpha.2-linux-x64.tar.gz
96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0  daymark-1.0.0-alpha.2-android.apk
```

GitHub's published release-asset digests match those values. `SHA256SUMS` is attached to the release.

The alpha.2 release also established the public Android signing certificate shown above and validated real migration from the earlier debug-signed development lineage through encrypted Backup / Restore.

Detailed alpha.2 historical evidence remains preserved in the alpha.2 tag/release, Git history, and prior release commits. It is historical evidence, not the active alpha.3 procedure.

## Post-release rule

After a release is published:

1. verify tag, release metadata, artifact assets, and uploaded digests;
2. keep tag/assets immutable;
3. record exact source/build/artifact identity in `PROJECT.md` and this document;
4. return work to `main` maintenance mode;
5. retain the release branch as historical reference unless the maintainer explicitly requests removal;
6. do not create a new feature roadmap from release completion.
