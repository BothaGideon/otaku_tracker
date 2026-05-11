# App identity migration checklist

- [x] Inspect the current Android package, iOS bundle identifier, Firebase config, and OAuth callback setup
- [x] Update the Android package to `com.tenjinlab.otaku_tracker`
- [x] Update the iOS bundle identifier to `com.tenjinlab.otaku_tracker`
- [x] Keep the existing MAL OAuth callback scheme `otaku.tracker://auth` unchanged in-app
- [x] Align repo-local Firebase config files with the new package and bundle identifiers where build-time matching depends on them
- [ ] Re-register the Android and iOS apps in Firebase and download fresh config files
- [ ] Re-run `flutterfire configure` after the new Firebase app registrations exist
- [ ] Update any external MAL app registration only if its redirect URI or app settings need to change
- [ ] Verify analytics, Crashlytics, and OAuth end-to-end on device with the regenerated Firebase configuration
