# Product principles

## Purpose

Daymark exists to provide a faithful digital implementation of the Bullet Journal method without turning personal organization into a productivity platform.

The application should help the user capture, reflect, migrate, discard, and retrieve information with as little interface friction and distraction as possible.

## Digital minimalism

Daymark deliberately avoids features whose primary purpose is to increase engagement with the application.

The product must not introduce:

- advertising;
- feeds;
- streaks, badges, XP, or gamification;
- productivity scores;
- attention-seeking notifications;
- unsolicited suggestions;
- dashboards for the sake of dashboards;
- social or collaborative features in the core product;
- AI-generated journal content;
- automatic decisions that replace intentional reflection.

Animations must be restrained and functional. Colors, typography, navigation, and persistent controls must remain minimal.

## Method fidelity

The core vocabulary is intentionally small:

- task;
- event;
- note;
- Daily Log;
- Monthly Log;
- Future Log;
- Collection;
- Index;
- Migration;
- Reflection.

Migration is a deliberate decision. Unresolved entries must never be silently rolled forward merely because software can automate it.

## Local-first

The journal belongs to the user.

Daymark must work without an account or network connection. Core functionality must never depend on a remote service.

User data must be exportable in documented, non-proprietary formats. A user must remain capable of recovering meaningful data even if Daymark itself is no longer available.

## Initial platforms

The supported targets for the first development phase are:

- Linux;
- Android.

The domain and application layers must not depend on platform-specific APIs. Windows, macOS, and iOS are future targets, not current scope.

## Languages and localization

Daymark is multilingual by design, not as a later retrofit.

The initial product languages are:

- English;
- Portuguese (Brazil).

The application should follow the operating system locale by default while allowing the user to choose a language explicitly.

English is the canonical localization source for interface messages and translation keys. Product behavior, domain rules, persistence values, and identifiers must never depend on translated display strings.

The interface must avoid layout assumptions that make future right-to-left languages unnecessarily difficult to support. Hebrew, Arabic, and other RTL languages are future possibilities, not part of the initial release scope.

## Feature test

Before adding a feature, ask:

1. Does it support capture, reflection, migration, retrieval, or another core part of the method?
2. Does it reduce mechanical friction without removing a conscious decision?
3. Does it keep the user's attention on their journal rather than on Daymark itself?
4. Can it remain understandable without configuration overhead?

If the answer is no, the feature probably does not belong in Daymark.
