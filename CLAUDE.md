# Otaku Tracker — LLM Context and Rules

This file is for coding agents and LLM assistants working in this repository.

> Mirror of `AGENTS.md`. Do not edit directly — update `AGENTS.md` and mirror changes here.

## Project Context

- Stack: Flutter + Dart
- State management: `flutter_riverpod`
- Anime data source: `jikan_api`
- Auth: MyAnimeList OAuth
- Main UI areas:
  - `lib/pages/home/landing_page.dart`
  - `lib/pages/seasonal/seasonal_page.dart`
  - `lib/pages/my_list/my_list_page.dart`
  - `lib/pages/profile/profile_page.dart`
- Routing: `go_router` for navigation with `GoRouter` provider in `lib/providers/navigation/`
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
   - avoiding fallback/formatting/business-rule checks when those can be prepared in providers or services first

3. Services should focus on:
   - preparing presentation data (view models/presentation objects) that widgets consume
   - factoring out complex formatting, filtering, and state transformations
   - examples: `AnimeDetailsViewService` builds `AnimeDetailsViewData`, `AnimeListEntryPresentation` with all display logic prepared
   - view service methods are typically read-only and pure (no side effects)

4. When a widget needs multiple null/empty/formatting checks to present data, move those checks into the service/provider layer and pass the widget a prepared view model or presentation object.

5. Prefer existing project patterns before adding new ones:
   - use Riverpod providers already in the repo
   - use shared widgets when a pattern already exists
   - use `openAnimeDetailsPage(...)` (from `lib/constants/anime/anime_navigation.dart`) for anime-detail navigation

6. Keep changes scoped:
   - do not refactor unrelated files
   - do not add new dependencies unless necessary
   - prefer small, direct widget extraction over new abstraction layers

7. For UI/UX decisions, use and reference Material 3 guidance:
   - prefer Material 3 components, patterns, and terminology where they fit the product
   - use Material 3 color roles, spacing, states, and feedback patterns instead of ad hoc styling choices
   - when choosing loading, empty, error, navigation, or interaction patterns, align them with Material 3 guidance unless the existing product intentionally differs

8. Skeleton loading is mandatory for data-driven UI:
   - every new widget or UI component that waits on async data, deferred provider state, or any user-visible loading period must include skeleton loading by default
   - do not introduce new spinner-only or blank loading states for new UI work unless the user explicitly asks for a different pattern
   - skeletons should match the final layout closely enough to preserve spacing and reduce layout shift
   - when adding a new async surface, plan and implement loading, empty, error, and loaded states together
   - use existing skeletons from `lib/widgets/shared/loading/` (e.g., `AnimeDetailsAccountSectionSkeleton`) and match their layout

## Implementation Guidance

- Read before editing.
- If adding a new widget file, place it in `lib/widgets/` and match existing naming style.
- Preserve current UI behavior unless the task explicitly asks for behavior changes.
- For details-page work, keep API fetching in providers/pages, and keep display logic in widgets.
- When adding new async UI, include the skeleton widget(s) in the same change rather than deferring loading-state work.

### Services and View Models

- Services in `lib/services/` prepare data for consumption by widgets and pages.
- **View Services** (e.g., `AnimeDetailsViewService`) build presentation objects that encapsulate all formatting, filtering, and display logic:
  - Input: raw API model (e.g., `Anime`, `ListStatus`)
  - Output: presentation object (e.g., `AnimeDetailsViewData`, `AnimeListEntryPresentation`)
  - Methods should be pure and side-effect-free
  - Widgets receive prepared data, avoiding null/empty/formatting checks
- Organize services by domain: `lib/services/anime/`, `lib/services/auth/`, `lib/services/anime_details/`, etc.
- Providers can read services and call their methods to prepare data before passing to widgets.

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
- Don't overwrite or revert commits that are not related to the current change, even if they contain issues. Focus on the changes you made and ensure they are correct and well-documented in the commit message.
- Example commit message for a change that adds a new widget:
  ```
  Add AnimeCard widget for displaying anime details in a card format

  - Created AnimeCard widget in lib/widgets/anime_card.dart
  - Updated landing_page.dart to use AnimeCard for anime listings
  - Styled AnimeCard to match existing design language
  ```
- Example commit message for a change that updates a provider:
  ```
  Update AnimeProvider to include new method for fetching anime details

  - Added fetchAnimeDetails method to AnimeProvider in lib/providers/anime_provider.dart
  - Updated existing methods to use fetchAnimeDetails where appropriate
  - Ensured that the new method handles errors gracefully and returns expected data format
  ```

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
- For any new widgets or UI components that depend on loading or deferred data, plan the skeleton state up front and treat it as a required deliverable, not an optional enhancement.
- When planning, also consider the performance implications of the changes, and ensure that any new features or UI components are optimized for smooth performance, especially on lower-end devices or in scenarios with limited resources.
- For any changes that involve navigation or user flow, plan how the user will move through the app, and ensure that the navigation is intuitive and follows established patterns in the app, providing a seamless experience for the user.
- When planning, also consider how the changes will affect the overall architecture of the app, and ensure that they fit well within the existing structure and do not introduce unnecessary coupling or complexity, while still achieving the desired functionality and user experience.
- For any changes that involve state management, plan how the state will be managed and updated, ensuring that it follows the existing patterns in the codebase and does not introduce unnecessary complexity or bugs, while still providing a clear and maintainable way to manage the state of the app.
- Create a markdown checklist inside the repo for the implementation steps, and check off each step as it is completed, to ensure that the implementation is thorough and follows the planned approach, while also providing a clear record of the work that was done and any decisions that were made along the way.
- For any changes that involve user input or interaction, plan how the app will validate and handle that input, ensuring that it provides clear feedback to the user and handles any errors or edge cases gracefully, while still providing a good user experience.

## Firebase Tracking

### Overview

All Firebase tracking goes through `AppTelemetryService` (`lib/services/telemetry/app_telemetry_service.dart`). Never call `FirebaseAnalytics` or `FirebaseCrashlytics` directly from pages, widgets, or providers — always add a typed method to `AppTelemetryService` and call that.

Screen-level tracking is handled automatically by the `FirebaseAnalyticsObserver` wired into the GoRouter provider (`lib/providers/navigation/gorouter_provider.dart`). You do not need to emit screen events manually.

### Where tracking calls live

Tracking belongs in **services** (not widgets or pages). Services that need telemetry accept `AppTelemetryService?` in their constructor and default to `AppTelemetryService()`:

```dart
class MyFeatureService {
  MyFeatureService({AppTelemetryService? telemetry})
      : _telemetry = telemetry ?? AppTelemetryService();

  final AppTelemetryService _telemetry;
}
```

### Adding a tracking method for a new business feature

1. **Add a typed method** to `AppTelemetryService`. One method per logical event — do not use a generic `track(String event, ...)` catch-all.

2. **Name the event** in `snake_case`, ≤ 40 characters (Firebase hard limit). Names should be self-explanatory in the Analytics dashboard (e.g. `anime_added_to_list`, `list_filter_changed`).

3. **Dual-track every event**: log it to Analytics *and* write a human-readable line to Crashlytics, so errors can be correlated with recent user actions:

   ```dart
   Future<void> trackAnimeAddedToList({
     required int animeId,
     required String status,
   }) async {
     await _runSafely(
       () => analytics.logEvent(
         name: 'anime_added_to_list',
         parameters: {
           'anime_id': animeId,
           'status': _clip(status, maxLength: 20),
         },
       ),
       label: 'analytics.anime_added_to_list',
     );

     await _runSafely(
       () => crashlytics.log('Anime added to list: id=$animeId status=$status'),
       label: 'crashlytics.log.anime_added_to_list',
     );
   }
   ```

4. **Always use `_runSafely`** — every analytics and crashlytics call must be wrapped so telemetry failures never crash the app.

5. **Clip string parameters** with `_clip(value, maxLength: N)` before passing to Firebase. Firebase enforces a 100-character limit on parameter values; keep names shorter (40 chars for event-name-like fields).

6. **Use user properties** (`analytics.setUserProperty`) for stable per-user attributes that should segment dashboards (e.g. NSFW setting, auth state). Do not use them for event-level data.

7. **Record non-fatal errors** to Crashlytics with `crashlytics.recordError(error, stackTrace, fatal: false, reason: '...')` for caught exceptions in service calls that represent real failure paths (e.g. API failures). Use `crashlytics.log(...)` only for breadcrumbs.

### What to track for a new feature

For each significant new user-facing feature, add tracking for:

| Trigger | Event type |
|---|---|
| User completes a key action (add, update, delete) | `analytics.logEvent` + `crashlytics.log` |
| User changes a persistent preference | `analytics.logEvent` + `analytics.setUserProperty` + `crashlytics.log` |
| A recoverable error occurs (API failure, parse error) | `analytics.logEvent` + `crashlytics.recordError(fatal: false)` |
| A fatal / unexpected error occurs | `crashlytics.recordError(fatal: true)` |

Do not track purely cosmetic interactions (scroll position, tab hover) — track decisions and outcomes.

### Checklist when adding tracking to a new feature

- [ ] New typed method(s) added to `AppTelemetryService`
- [ ] Event name is `snake_case` and ≤ 40 characters
- [ ] All string parameters are clipped with `_clip`
- [ ] Every call is wrapped in `_runSafely`
- [ ] Crashlytics breadcrumb logged alongside the analytics event
- [ ] `AppTelemetryService` injected via constructor (not instantiated inline in call sites)
- [ ] No tracking calls in widgets or pages — only in services

## Domain Knowledge

- In `PosterImageTitle`, the thumbs-up icon represents the anime favorites count, not the popularity rank.
- The anime details hero poster should be a plain rounded poster image only. It should not reuse `PosterImageTitle`, and it should not show overlay stats, favorites, score, or the small title underneath.
- Navigation uses `GoRouter` with routes defined in `lib/providers/navigation/gorouter_provider.dart`; for anime details, always use `openAnimeDetailsPage(context, animeId)` from `lib/constants/anime/anime_navigation.dart`
- Deep linking is handled by `lib/services/navigation/deeplink_service.dart`; OAuth callbacks are routed through this service

### Icons

- Never use the `material_symbols_icons` package (`Symbols.*`). It does not render reliably in Play Store release builds. Always use Flutter's built-in `Icons.*` from `flutter/material.dart` instead.

### Anime Details page

- `AnimeDetailsInfoBadge` (the hero metadata chips showing type/status/episodes/season) must match the `_AnimeListInfoChip` style: `surfaceContainerHighest` background, `horizontal: 12` / `vertical: 8` padding, theme-default icon and text colors, `ConstrainedBox(maxWidth: 220)` with `TextOverflow.ellipsis` on the label. Do not use custom white overlay colours or forced white text for these chips.
- `AnimeDetailsScorePanel` and `AnimeDetailsMetadataPanel` must be wrapped in `SizedBox(width: double.infinity)` inside `AnimeDetailsHeroContent` so they fill the card width and have equal padding from the card background on both sides.
- `AnimeDetailsMetadataPanel`'s inner Column uses `crossAxisAlignment: CrossAxisAlignment.stretch` and `AnimeDetailsLabelValueText` uses `textAlign: TextAlign.start` on its `RichText` to ensure label rows are consistently left-aligned.
- The hero badge `Wrap` in `AnimeDetailsHeroContent` uses the default `WrapAlignment.start` so chips flow left-to-right, consistent with the Your List section.
