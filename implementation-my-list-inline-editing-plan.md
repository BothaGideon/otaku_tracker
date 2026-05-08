# My List Inline Editing Plan

## Goal

Let users update progress and rating from `My List` without needing to open the anime details page, while keeping the existing grid layout readable on compact screens.

## Recommended Scope for First Pass

- Add a compact per-card quick action entry point on `My List`
- Support fast edits for:
  - status
  - episodes watched
  - score
- Keep advanced fields in the existing details-page editor for now:
  - rewatching
  - priority
  - rewatch count/value
  - tags
  - comments
  - remove from list

## Why This Scope

- The current page is a poster grid with a small visual footprint per item
- Trying to fit full editing controls directly inside each tile would either:
  - break the existing visual hierarchy, or
  - force a broader redesign into list cards instead of poster tiles
- A quick-edit sheet from each tile gives the speed benefit the feature needs without widening scope unnecessarily

## Proposed UX

1. Keep tap on a poster opening the anime details page
2. Add a small edit affordance on each tracked tile
3. Tapping that affordance opens a compact bottom sheet
4. The bottom sheet allows:
   - changing status
   - updating watched episodes
   - changing score
5. Include a secondary action to open the full editor on the details page if the user wants advanced fields later

## Implementation Steps

- [ ] Extract the reusable MAL editor pieces needed by both details page and My List
- [ ] Create a compact quick-edit sheet/widget for status, episodes watched, and score
- [ ] Add a per-item edit trigger to `My List` tiles
- [ ] Refresh list/profile providers after quick edits
- [ ] Add tests for quick edit from `My List`
- [ ] Verify with `flutter analyze` and `flutter test test/widget_test.dart`

## File Scope

- `lib/pages/my_list_page.dart`
- `lib/widgets/poster_image_title.dart`
- likely a new reusable widget in `lib/widgets/` for the quick-edit sheet
- possibly a small extraction from `lib/widgets/anime_details_content.dart` if we want shared editor code

## Risks / Design Notes

- The current `PosterImageTitle` overlay is already busy with score and status
- The edit affordance should stay small and accessible, likely in a corner action area
- If the card becomes too crowded, the better fallback is a long-press or overflow action rather than more inline controls
