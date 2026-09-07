# Project

## Purpose

Daymark is a minimal, local-first Bullet Journal application for Linux and Android. It is designed to preserve deliberate capture, reflection, migration, scheduling, indexing, and retrieval without turning the method into a generic productivity platform.

## Supported product

Daymark currently supports:

- Linux x64
- Android
- English
- Portuguese (Brazil)
- Spanish

The journal is local and encrypted at rest. There are no accounts, cloud sync, collaboration features, feeds, advertising, streaks, productivity scores, or gamified engagement systems.

## Product surface

The supported journal surface consists of:

- Today / Daily Log
- Monthly Log
- Future Log
- Collections
- Index
- Search
- Signifiers
- optional finite Trackers
- encrypted Backup / Restore
- plaintext Open Export
- appearance preferences
- manual, inactivity, and system-session locking

Daymark-specific adaptations must remain explicit adaptations rather than being presented as canonical Bullet Journal rules.

## Current development posture

The product is in prerelease stabilization toward 1.0. Development should favor correctness, security, compatibility, method fidelity, accessibility, localization, packaging, and documentation over feature expansion.

Changes that materially expand product scope require an explicit maintainer decision before implementation.

## Versioning

The application version is defined in `pubspec.yaml`.

Published releases are immutable. Release promotion is explicit and is never inferred from a branch name or successful CI run.

## Compatibility boundaries

Treat these as compatibility-sensitive:

- encrypted journal database format and schema migrations
- key-envelope format
- backup container format
- Open Export format
- Android application identity and signing lineage
- Linux package identity
- user-visible journal semantics

## Historical information

Do not use this file as a chronological project diary. Pull requests, commits, tags, releases, and the changelog preserve history.
