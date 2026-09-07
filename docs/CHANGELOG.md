# Changelog

This file summarizes published Daymark releases and notable unreleased product changes. Detailed implementation history remains in Git commits and pull requests.

## Unreleased

### Method fidelity and journal flow

- added deliberate Daily and Monthly reflection flows for unresolved Tasks
- added historical Daily and Monthly navigation with read-only past views
- added Future arrival review
- added Future Event migration into a dated Monthly Calendar entry
- added dated Tasks to the Monthly Calendar
- added built-in Signifiers and Signifier-aware Search
- refined migration lineage and related navigation/UI behavior

### Documentation

- reorganized technical documentation under `docs/`
- simplified the root README
- separated AI operating instructions from human developer documentation
- refreshed the Portuguese (Brazil) user Wiki

## 1.0.0-beta.2 — 2026-09-06

Maintenance prerelease focused on application-icon integration.

- corrected canonical Daymark icon installation in Debian and AppImage packages
- corrected Android launcher icon generation
- added CI checks for stale Android launcher resources
- preserved Android signing lineage from alpha.3/beta.1
- preserved database schema v2 and product behavior

Published for Linux x64 and Android.

## 1.0.0-beta.1 — 2026-09-06

First beta prerelease of the feature-complete Linux/Android product line.

- Linux Debian and AppImage packaging
- signed Android release artifact
- encrypted Backup / Restore
- Open Export
- current journal feature set and prerelease stabilization baseline

## 1.0.0-alpha.3 — 2026-09-06

Feature-complete alpha baseline for Linux and Android.

- established the current Android signing lineage
- consolidated encrypted local journal storage and supported journal surfaces
- published Linux x64 and Android artifacts with checksums

## Earlier development

Earlier alpha development established the initial Daymark architecture, encrypted persistence, Bullet Journal structures, CI, packaging, and platform integration. Refer to Git history and GitHub pull requests for detailed chronology.
