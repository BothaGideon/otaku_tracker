# Firebase MAL telemetry implementation checklist

- [x] Review the repo instructions, existing Firebase setup, and MAL integration points
- [x] Add shared telemetry helpers for MAL API failures, MAL login journey events, and NSFW preference changes
- [x] Instrument MAL API services and the OAuth flow with the new telemetry hooks
- [x] Wire NSFW toggle interaction tracking through the persisted preference path
- [x] Align Android Crashlytics Gradle configuration with current Firebase guidance
- [x] Add focused automated tests for the new telemetry behavior
- [x] Run verification checks and capture any remaining manual console validation steps
