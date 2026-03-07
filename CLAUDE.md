# Frankly — Claude Code Guidance

## Project Overview

Frankly is an online deliberations platform with video-enabled breakout rooms and participant matching. It is built with Flutter (frontend) and Firebase (backend).

## Tech Stack

- **Frontend**: Flutter (Dart), targeting Web (Chrome), iOS, Android
- **Backend**: Firebase — Firestore, Cloud Functions (Dart → compiled JS), Auth, Realtime Database
- **Video**: Agora RTC Engine
- **E2E Tests**: Playwright (TypeScript)
- **Flutter version**: `3.22.2` — use this exact version

## Repository Structure

```
client/          # Flutter app (main frontend)
firebase/
  functions/     # Firebase Cloud Functions (Dart)
  firestore/     # Firestore rules and indexes
data_models/     # Shared Dart data models (Freezed-generated, used by client + functions)
matching/        # Participant matching algorithm (Dart CLI)
e2e/             # Playwright end-to-end tests
docs/            # MkDocs documentation
.github/workflows/ # CI/CD pipelines
```

## Development Setup

### First-time setup

1. Build shared data models (run in `data_models/`):
   ```
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   # or: ./build.sh
   ```

2. Install Firebase Functions deps (run in `firebase/functions/`):
   ```
   npm install
   flutter pub get
   ```

3. Copy `client/.env.example.local` → `client/.env` and fill in secrets.

4. Create `firebase/functions/.runtimeconfig.json` from `.runtimeconfig.json.local.example`.

### Running locally

Start Firebase emulators first (run in `firebase/functions/`):
```
dart run build_runner build --output=build
firebase emulators:start --only firestore,functions,auth,pubsub,database
# or: npm run emulators
```

Then run the Flutter client (run in `client/`):
```
# With emulators:
flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart --dart-define-from-file=.env

# Against staging:
flutter run -d chrome --release --web-renderer html -t lib/main.dart --dart-define-from-file=.env
```

VSCode launch configs in `.vscode/launch.json` handle this automatically.

## Testing

### Flutter unit tests (run in `client/`):
```
flutter pub run build_runner build   # from client/test first
cd ../
flutter test --platform chrome
```

### E2E tests (Playwright):
See `docs/pages/e2e.md` for setup and run instructions.

### Firebase Functions tests:
Uses Firebase emulator. See `firebase/functions/test/`.

## CI/CD

GitHub Actions workflows in `.github/workflows/`:
- `test_client.yaml` — Flutter unit tests (triggers on client changes)
- `test_firebase.yaml` — Firebase Functions tests
- `deploy_client_staging.yaml` / `deploy_client_prod.yaml` — Flutter web deploy
- `deploy_firebase_staging.yaml` / `deploy_firebase_prod.yaml` — Functions deploy
- `playwright.yml` — E2E tests
- `deploy-preview.yml` — PR preview deployments

**Main branch for PRs**: `staging`

## Code Conventions

- **Commit messages**: Longform preferred. Include a short title, then a body explaining *why* the change was made. Reference issues with `Fixes #1234`.
- **Data models**: Use Freezed + json_serializable. Run `build_runner` after changes to `data_models/`.
- **Dart formatting**: Follow standard Dart/Flutter analysis options (`analysis_options.yaml`).
- **No ORM**: Direct Firestore SDK usage with Freezed-serialized models.

## Key Entry Points

| File | Purpose |
|------|---------|
| `client/lib/main.dart` | App entry point |
| `client/lib/app.dart` | App initialization |
| `client/lib/services.dart` | Dependency injection / service setup |
| `firebase/functions/lib/main.dart` | Firebase Functions root |
| `data_models/lib/` | Shared data models |
| `matching/lib/matching.dart` | Participant grouping logic |

## Third-Party Services

- **Agora**: Video calling — requires `app_id`, `app_certificate`, REST keys in `.runtimeconfig.json`
- **Cloudinary**: Image/video uploads — configured in `client/.env`
- **Mux**: Livestreaming webhooks — requires a deployed Cloud Function URL
- **SendGrid**: Email via Firestore extension
- **Stripe**: Payments (currently disabled)

## Notes

- Firestore must be configured as **single region**.
- The Realtime Database name must be `default` (not a named database).
- When adding new Dart dependencies to `data_models/`, re-run `build_runner` in that package and restart the emulators.
