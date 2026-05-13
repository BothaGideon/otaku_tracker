# MAL OAuth Redirect URI Checklist

- [x] Inspect the current Flutter OAuth redirect URI handling
- [x] Align the app redirect URI to `otaku.tracker://auth`
- [x] Send `redirect_uri` in the MAL authorization request
- [x] Send `redirect_uri` in the MAL token exchange request
- [x] Validate OAuth `state` on the callback
- [x] Align Android callback intent handling with the redirect URI
- [x] Register the iOS URL scheme for the callback
- [x] Verify with `flutter analyze` and `flutter test test/widget_test.dart`
