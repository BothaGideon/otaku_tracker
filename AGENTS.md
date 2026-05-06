# Otaku Tracker — LLM Context and Rules

This file is for coding agents and LLM assistants working in this repository.

## Project Context

- Stack: Flutter + Dart
- State management: `flutter_riverpod`
- Anime data source: `jikan_api`
- Auth: MyAnimeList OAuth
- Main UI areas:
  - `lib/pages/landing_page.dart`
  - `lib/pages/seasonal_page.dart`
  - `lib/pages/my_list_page.dart`
  - `lib/pages/my_profile_page.dart`
- Reusable UI belongs in `lib/widgets/`
- App-level helpers/constants belong in `lib/constants/`
- Providers belong in `lib/providers/`

## Architecture Rules

1. Pages should focus on:
   - screen-level composition
   - provider reads
   - loading/error/success states
   - navigation boundaries

2. Widgets should focus on:
   - rendering content
   - owning UI styling
   - presenting already-available data

3. Prefer existing project patterns before adding new ones:
   - use Riverpod providers already in the repo
   - use shared widgets when a pattern already exists
   - use `openAnimeDetailsPage(...)` for anime-detail navigation

4. Keep changes scoped:
   - do not refactor unrelated files
   - do not add new dependencies unless necessary
   - prefer small, direct widget extraction over new abstraction layers

## Implementation Guidance

- Read before editing.
- If adding a new widget file, place it in `lib/widgets/` and match existing naming style.
- Preserve current UI behavior unless the task explicitly asks for behavior changes.
- For details-page work, keep API fetching in providers/pages, and keep display logic in widgets.

## Verification Rules

- After code changes, run the relevant verification commands.
- Preferred Flutter checks:
  - `flutter test test/widget_test.dart`
  - `flutter analyze`

- If `flutter analyze` reports older unrelated issues already present in the repo, do not misreport them as introduced by the current change.

## Commit Rule

- After each finished prompt that changes code, create a proper git commit before ending the task.
- Commit messages should be specific and describe the completed change clearly.

## Practical Decision Rules

- If a page file contains substantial styling/content widgets, extract them into `lib/widgets/`.
- If a widget is only used by one page but clearly represents a standalone UI section, it should still live in `lib/widgets/` if that keeps the page focused.
- Favor explicit, readable widget composition over clever abstractions.
- When the user provides domain knowledge or corrects product semantics, update `AGENTS.md` to capture that guidance so future work keeps using it.

## Domain Knowledge

- In `PosterImageTitle`, the thumbs-up icon represents the anime favorites count, not the popularity rank.
- The anime details hero poster should be a plain rounded poster image only. It should not reuse `PosterImageTitle`, and it should not show overlay stats, favorites, score, or the small title underneath.
