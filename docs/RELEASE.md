# Release

## Scope

Daymark currently releases for:

- Linux x64: Debian package and AppImage
- Android: signed APK

Release promotion is explicit. A successful CI run does not create or approve a release.

## Version source

`pubspec.yaml` is the application version source.

Use semantic prerelease versions such as:

```text
1.0.0-alpha.N+BUILD
1.0.0-beta.N+BUILD
1.0.0-rc.N+BUILD
1.0.0+BUILD
```

Linux package naming strips the Flutter build suffix. Debian prerelease versions convert `-` to `~` for package ordering.

## Pre-release checks

Before building release artifacts:

1. confirm the intended branch and exact commit
2. confirm a clean worktree locally
3. confirm `pubspec.yaml` version
4. run the relevant generation steps
5. run format, analyze, and tests
6. confirm migration snapshots are current
7. confirm release signing configuration is available locally for Android
8. confirm no private signing material is tracked

Do not change version, signing lineage, schema, or packaging identity accidentally during release preparation.

## Linux

Build the Flutter release bundle:

```bash
flutter build linux --release --no-pub
```

`tool/package_linux.sh` creates and validates:

```text
build/distributables/daymark_<version>_amd64.deb
build/distributables/Daymark-<version>-x86_64.AppImage
```

The packaging script installs canonical Daymark branding and validates desktop/AppStream metadata and package contents.

The AppImage build uses externally downloaded `appimagetool` and runtime binaries whose expected SHA-256 values are pinned in CI. Local release preparation should preserve equivalent verification.

## Android signing

Application ID:

```text
io.github.marcelositr.daymark
```

Release signing is configured through local `android/key.properties` and a private upload keystore.

Required properties:

```text
storeFile
storePassword
keyAlias
keyPassword
```

Release builds fail if signing is requested without complete configuration or if the configured keystore file is missing.

Never commit:

```text
android/key.properties
*.jks
*.keystore
```

Preserve the established signing lineage. Losing the private key breaks seamless upgrade compatibility for artifacts signed by that lineage.

## Android build

For a signed release build:

```bash
flutter build apk --release --no-pub
```

Verify the produced APK's package identity, version, and signing certificate before publication.

## Checksums

Generate SHA-256 checksums for every published artifact and publish a `SHA256SUMS` file with the release.

Checksums should be computed from the final frozen files that will be uploaded.

## Git tag and GitHub Release

Tags and releases are maintainer-controlled promotion steps.

Before tagging, record the exact source commit and verify that the final artifacts were built from that source state.

Recommended tag shape:

```text
v1.0.0-beta.N
```

Prerelease tags should be marked as prereleases on GitHub.

## Post-publication verification

After publication, verify:

- tag points to the intended commit
- release is visible with the intended prerelease/stable status
- all expected assets exist
- published checksums match local frozen artifacts
- Linux artifacts install/run
- Android artifact installs/upgrades according to signing compatibility

## Release history

Release-specific narrative belongs in [`CHANGELOG.md`](CHANGELOG.md) and GitHub Releases, not in this procedure.
