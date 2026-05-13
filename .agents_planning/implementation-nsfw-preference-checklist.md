# NSFW preference implementation checklist

- [x] Audit existing preference and anime-fetching code paths that need NSFW awareness
- [x] Add a persisted local NSFW preference provider
- [x] Add shared NSFW filtering/gating helpers for Jikan-backed surfaces
- [x] Wire the NSFW preference through MAL-backed search and ranking requests
- [x] Wire the NSFW preference through Jikan-backed landing, seasonal, and details providers
- [x] Add the NSFW toggle to the Profile page UI
- [x] Add or update tests for the NSFW toggle behavior
- [x] Run `flutter analyze`
- [x] Run `flutter test test/widget_test.dart`
- [x] Create a focused git commit for the NSFW toggle implementation
