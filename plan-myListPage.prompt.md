# Plan for My List Page Implementation

## Overview
Implement the My List page to display the user's MyAnimeList anime collection in a grid format, with filtering options for status (watching, completed, on_hold, dropped, plan_to_watch). Follow the design conventions from the landing and seasonal pages.

## Key Changes
- **OAuth Service**: Store access token and username in SharedPreferences after login. Add methods to retrieve them.
- **Models**: Add UserAnimeListDTO, UserAnimeData, ListStatus for user anime list API response.
- **Anime List Service**: Add getUserAnimeList() method using Bearer token.
- **Providers**: Add userDataProvider and userAnimeListProvider for async data management.
- **Widgets**: Create UserAnimeItem widget for displaying anime with user score and status.
- **My List Page**: Refactor to conditionally show login or grid list with status filter dropdown.

## Implementation Steps
1. Update OauthService to persist token and username.
2. Add new models to anime.dart.
3. Add getUserAnimeList method to AnimeListService.
4. Add providers to anime_list_provider.dart.
5. Create UserAnimeItem widget.
6. Refactor MyListPage to use providers and display grid with filter.
7. Run build_runner for JSON serialization.

## Files Modified
- lib/services/oauth_service.dart
- lib/models/response/anime.dart
- lib/services/anime_list_service.dart
- lib/providers/anime_list_provider.dart
- lib/pages/my_list_page.dart
- New: lib/widgets/user_anime_item.dart

## Dependencies
- Run `flutter pub run build_runner build` to generate model code.
- Ensure SharedPreferences is used for storage.
