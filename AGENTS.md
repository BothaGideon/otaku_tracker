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
- When a prompt includes multiple related changes, split them into detailed, reviewable commits grouped by concern so they are easy to track and revert independently.

## Practical Decision Rules

- If a page file contains substantial styling/content widgets, extract them into `lib/widgets/`.
- If a widget is only used by one page but clearly represents a standalone UI section, it should still live in `lib/widgets/` if that keeps the page focused.
- Favor explicit, readable widget composition over clever abstractions.
- When the user provides domain knowledge or corrects product semantics, update `AGENTS.md` to capture that guidance so future work keeps using it.

## Planning rules
- For multi-step tasks, break down the implementation into clear steps before coding.
- For example, if implementing a new feature that requires both API changes and UI changes, plan the API work first, then the UI work, and ensure each step is independently verifiable.
- For UI changes, plan the widget hierarchy and data flow before writing code, to ensure a clear separation of concerns and adherence to the architecture rules.
- When planning, also consider edge cases and error states, and ensure that the implementation will handle them gracefully.
- For any new features that require user input or interaction, plan the user flow and how the UI will guide the user through the process, ensuring a good user experience.
- For any changes that affect the data model or API interactions, plan how the data will be fetched, stored, and passed to the UI, ensuring that it follows the existing patterns in the codebase and does not introduce unnecessary complexity.
- When planning, also consider how the changes will be tested, and ensure that there are clear test cases for both the happy path and any edge cases or error states that may arise from the new implementation.
- For any new widgets or UI components, plan the styling and layout, ensuring that it is consistent with the existing design language of the app and provides a cohesive user experience.
- When planning, also consider the performance implications of the changes, and ensure that any new features or UI components are optimized for smooth performance, especially on lower-end devices or in scenarios with limited resources.
- For any changes that involve navigation or user flow, plan how the user will move through the app, and ensure that the navigation is intuitive and follows established patterns in the app, providing a seamless experience for the user.
- When planning, also consider how the changes will affect the overall architecture of the app, and ensure that they fit well within the existing structure and do not introduce unnecessary coupling or complexity, while still achieving the desired functionality and user experience.
- For any changes that involve state management, plan how the state will be managed and updated, ensuring that it follows the existing patterns in the codebase and does not introduce unnecessary complexity or bugs, while still providing a clear and maintainable way to manage the state of the app.
- Create a markdown checklist inside the repo for the implementation steps, and check off each step as it is completed, to ensure that the implementation is thorough and follows the planned approach, while also providing a clear record of the work that was done and any decisions that were made along the way.
- For any changes that involve user input or interaction, plan how the app will validate and handle that input, ensuring that it provides clear feedback to the user and handles any errors or edge cases gracefully, while still providing a good user experience.

## Domain Knowledge

- In `PosterImageTitle`, the thumbs-up icon represents the anime favorites count, not the popularity rank.
- The anime details hero poster should be a plain rounded poster image only. It should not reuse `PosterImageTitle`, and it should not show overlay stats, favorites, score, or the small title underneath.
