# App identity migration checklist

- [x] Inspect the current Android package, iOS bundle identifier, Firebase config, and OAuth callback setup
- [x] Detect the regenerated Firebase config mismatch between `com.tenjinlab.otaku_tracker` and `com.tenjinlab.otakutracker`
- [x] Standardize the Android app ID, native package path, and method channel to `com.tenjinlab.otakutracker`
- [x] Standardize the iOS bundle identifiers to `com.tenjinlab.otakutracker`
- [x] Keep the existing MAL OAuth callback scheme `otaku.tracker://auth` unchanged in-app
- [x] Align repo-local Firebase config files and FlutterFire outputs to the Firebase-registered app identifiers
- [ ] Verify analytics, Crashlytics, and OAuth end-to-end on device with the regenerated Firebase configuration
