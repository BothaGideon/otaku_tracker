# Anime Details Content Refactor Checklist

- [x] Review `AGENTS.md` and inspect the current anime details flow
- [x] Move anime-details display logic checks out of `anime_details_content.dart`
- [x] Keep widget rendering behavior unchanged while simplifying widget code
- [x] Update `AGENTS.md` with the architecture rule about widget logic placement
- [x] Verify with `flutter analyze` and `flutter test test/widget_test.dart`
