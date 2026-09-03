from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, content: str) -> None:
    Path(path).write_text(content)


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one match, found {count}")
    write(path, text.replace(old, new, 1))


def replace_between(path: str, start: str, end: str, replacement: str) -> None:
    text = read(path)
    start_index = text.find(start)
    if start_index < 0:
        raise SystemExit(f"{path}: start marker not found")
    end_index = text.find(end, start_index)
    if end_index < 0:
        raise SystemExit(f"{path}: end marker not found")
    write(path, text[:start_index] + replacement + text[end_index:])


replace_once(
    "docs/PRODUCT.md",
    "Daymark supports light and dark appearance, with a system-following option where the platform provides one).",
    "Daymark supports light and dark appearance, with a system-following option where the platform provides one.",
)

replace_once(
    "docs/ARCHITECTURE.md",
    "The Collection boundary follows the same split: `CollectionRepository` owns focused Collection reads and delegates semantic creates/captures to `JournalService`, while `JournalSession` serializes list/create/load/capture operations with the rest of the unlocked journal lifecycle. Collection ownership, Collection references, and migration remain distinct domain operations rather than being collapsed into presentation helpers.",
    "The Collection boundary follows the same split: `CollectionRepository` owns focused Collection reads for both owned entries and references, and delegates semantic create/capture/reference writes to `JournalService`, while `JournalSession` serializes list/create/load/capture/reference operations with the rest of the unlocked journal lifecycle. Collection ownership, Collection references, and migration remain distinct domain operations rather than being collapsed into presentation helpers.",
)

replace_once(
    "docs/ARCHITECTURE.md",
    "Forward Task migration to a Collection is exposed through `JournalSession.migrateTaskToCollection(...)`. The session first validates the persisted source as an open Task, then delegates to `JournalService.migrate(...)` with a `JournalCollectionOwner`. The presentation layer only lists existing Collections and records the user's deliberate choice; it does not create a destination or reproduce lineage rules.\n\nBecause Today or Monthly can now change a retained Collection while Collections is inactive, `CollectionsScreen` observes `AppSectionScope` reactivation and reloads both the Collection list and any selected Collection snapshot. This is the same presentation-lifecycle rule already used by Future scheduling, not a new persistence cache.",
    "Forward Task migration to a Collection is exposed through `JournalSession.migrateTaskToCollection(...)`. The session first validates the persisted source as an open Task, then delegates to `JournalService.migrate(...)` with a `JournalCollectionOwner`. The presentation layer only lists existing Collections and records the user's deliberate choice; it does not create a destination or reproduce lineage rules.\n\nCollection references are exposed through `JournalSession.referenceEntryInCollection(...)`. The serialized session delegates to the existing `JournalService.referenceInCollection(...)` transaction, so presentation only chooses an existing Collection and never changes source ownership, Entry identity, or Task state. `CollectionSnapshot` keeps owned entries and reference entries in separate read-model lists so the Collection UI cannot accidentally treat a reference as owned content or expose Task mutations through it.\n\nBecause Today, Monthly, or Future can now change a retained Collection while Collections is inactive, `CollectionsScreen` observes `AppSectionScope` reactivation and reloads both the Collection list and any selected Collection snapshot, including references. This is the same presentation-lifecycle rule already used by Future scheduling, not a new persistence cache.",
)

current_state = """## Current state

- Phase: pre-alpha, core Bullet Journal flows in active development.
- Integration branch: `main` only.
- Current `main` head before the active feature PR: `89c1907d17d0507fd84c403c7343afc2ccbbd8da` (`feat(journal): migrate tasks to collections (#21)`).
- Current merged product baseline: PR #21, deliberate Task migration to Collections, squash-merged as `89c1907d17d0507fd84c403c7343afc2ccbbd8da`.
- Active product implementation branch/PR: `feat/collection-references` / PR #22, `feat(journal): reference entries in collections`.
- PR #22 is Draft. Its implementation exposes deliberate references from Today, Monthly, and Future entries into an existing Collection without moving the source, changing Entry identity, or changing Task state.
- Current merged product scope includes Today, current Monthly, six-month Future, basic Collections, deliberate Task terminal actions, scheduling (`<`), and forward migration (`>`) into existing Collections.
- Current focus: finish PR #22 documentation and exact-head Draft CI, perform manual Linux cross-surface reference/persistence validation, then run full Ready CI before explicit merge approval.
- Merge policy: never merge without explicit user approval.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Last updated: 2026-09-03 (America/Sao_Paulo).

"""
replace_between("PROJECT.md", "## Current state\n", "## Product doctrine\n", current_state)

active_section = """## Merged PR #21: deliberate Task migration to Collections

Branch: `feat/task-migration-collections`.

PR: #21, `feat(journal): migrate tasks to collections`.

Scope merged:

- Today and Monthly open Tasks gain a deliberate **Migrate** action;
- the user chooses one existing Collection; migration never auto-selects or creates a destination;
- `JournalSession.migrateTaskToCollection(...)` validates the source as an open Task before delegating to existing `JournalService.migrate` / repository lineage semantics;
- the source stays historical as `migrated` (`>`);
- the chosen Collection receives a fresh open Task with its own identity and lineage;
- Collections refreshes on retained-tab reactivation after a migration from Today/Monthly;
- English, `pt`, and `pt_BR` migration labels are localized;
- session coverage proves source/destination state persists across lock/unlock;
- widget coverage proves Today/Monthly destination selection and retained-Collections refresh;
- no schema, crypto, backup, dependency, or platform-contract change.

Validation and merge:

- code-equivalent implementation head `57b171b3d3c1fc223dbdf13b5cd9c55a5f5efdc1` was produced by the pinned Flutter 3.47.2 / Dart 3.13.2 runner;
- formatter applied to 64 files with 6 changes; analyzer reported **No issues found**; **113 tests passed**;
- manual Linux migration/persistence validation passed;
- Draft CI #333 green;
- full Ready CI #334: quality/test suite, Linux build, Android build, dependency review, and merge-gate all green;
- explicit user approval was received;
- PR #21 squash-merged as `89c1907d17d0507fd84c403c7343afc2ccbbd8da`;
- post-merge main CI #335 green.

## Active PR #22: deliberate Collection references

Branch: `feat/collection-references`.

PR: #22, `feat(journal): reference entries in collections`.

Scope implemented:

- Today, Monthly, and Future entries can be deliberately referenced into one existing Collection;
- the reference preserves the original owner, stable Entry identity, content, and Task state;
- `JournalSession.referenceEntryInCollection(...)` keeps the write serialized and delegates to the existing `JournalService.referenceInCollection(...)` transaction;
- `CollectionRepository` loads owned entries and references separately;
- Collections displays references in a distinct read-only section, so referenced Tasks do not expose Complete/Discard there;
- retained Collections refreshes references after a cross-surface write;
- English, `pt`, and `pt_BR` reference labels are localized;
- repository, session, widget, and retained-navigation tests cover the new behavior;
- no schema, crypto, backup, dependency, or platform-contract change.

Explicit non-goals:

- no migration or scheduling behavior changes;
- no automatic Collection choice or Collection creation from the reference dialog;
- no reference action from Collection-owned entries inside Collections;
- no Task mutation through a Collection reference;
- no removing/unreferencing links;
- no navigation from a reference back to its source;
- no Index;
- no next-Monthly browsing;
- no schema v2.

Validation so far:

- temporary pinned-toolchain probes were used to materialize exact formatter output and were removed from the final PR diff;
- formatter and analyzer pass on the code-equivalent implementation;
- focused repository/session/reference-widget/Collections-refresh tests pass;
- a full-suite probe exposed one diagnostic-contract regression: existing Task failures were reported as `entry action` instead of the established `task action`; behavior was unaffected, the diagnostic label was restored, and the regression test now passes;
- the corrected full suite passes with **121 tests**;
- the exact product implementation was committed as `9fd64fa51ac901ec461ea03b88dffe71ef63216e` before temporary tooling removal;
- standard Draft CI #337 was green on an earlier tooling-only head and is superseded as final evidence;
- exact-head Draft CI after documentation remains required before manual validation.

## Next work after PR #22

Keep the next slice separate from Collection references. The leading method-native candidates are the deliberate Index surface or next-Monthly accessibility/historical browsing. Search, backup UI, exports, OS lock hooks, accessibility/keyboard work, and packaging remain later focused slices. Do not bundle Index with Search merely because both help retrieval.

"""
replace_between(
    "PROJECT.md",
    "## Active PR #21: deliberate Task migration to Collections\n",
    "## CI and handoff traps to remember\n",
    active_section,
)

print("PR #22 documentation patch applied")
