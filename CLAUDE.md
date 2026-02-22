# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Frankly is an online deliberations platform built with Flutter (web-only) and a Firebase backend. It supports video-enabled breakout room discussions, participant matching via survey responses, and structured event templates.

## Repository Structure

- `client/` — Flutter web app (the main frontend)
- `data_models/` — Shared Dart data models used by both client and Firebase functions; code-generated with Freezed/build_runner
- `firebase/functions/` — Firebase Cloud Functions written in Dart, compiled to JavaScript via `dart2js`
- `matching/` — Dart package containing the breakout room participant matching algorithm
- `e2e/` — Playwright end-to-end tests

## Key Commands

All `flutter` commands should be run from the relevant package directory (`client/`, `data_models/`, or `firebase/functions/`).

### Data Models (run from `data_models/`)
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
# or just: ./build.sh
```

### Firebase Functions (run from `firebase/functions/`)
```bash
npm install           # install JS dependencies
flutter pub get       # install Dart dependencies

# Build and start emulators (do this before running client):
npm run emulators
# Which runs: dart run build_runner build --output=build && firebase emulators:start --only firestore,functions,auth,pubsub,database --project dev

# Run tests:
npm run test          # runs: dart test --concurrency=1

# Lint:
npm run lint          # runs: npx eslint@8
```

### Client (run from `client/`)
```bash
# Run with emulators (recommended for development):
flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart --dart-define-from-file=.env

# Run against staging backend:
flutter run -d chrome --release --web-renderer html -t lib/main.dart --dart-define-from-file=.env

# Analyze (lint):
flutter analyze

# Run unit tests:
flutter test --platform chrome

# Run a single test file:
flutter test test/path/to/test_file.dart

# Regenerate code (after modifying Freezed models):
dart run build_runner build --delete-conflicting-outputs
```

### E2E Tests (run from `e2e/`)
```bash
npm install
npx playwright install   # install browsers (first time)
npx playwright test
npx playwright test tests/event/rsvp-event.spec.ts   # single file
npx playwright test tests/event/rsvp-event.spec.ts -g "test name"  # single test
```

## Environment Configuration

Copy `client/.env.example.local` to `client/.env` and fill in secrets. The `.env` file is loaded via `--dart-define-from-file=.env`. All configuration flows through `client/lib/config/environment.dart` using `String.fromEnvironment`.

For emulators, create `firebase/functions/.runtimeconfig.json` (copy from `.runtimeconfig.json.local.example`) to configure third-party service credentials.

**Flutter version**: The project requires Flutter **3.22.2**. Use this exact version to avoid unexpected errors.

## Architecture

### Client (Flutter)

The client follows a **feature-first directory structure**:

```
client/lib/
  features/[feature]/
    data/          # services (Firestore, Cloud Functions)
    presentation/  # views (pages, widgets)
    features/      # nested sub-features
  core/            # shared infrastructure (routing, utils, widgets, localization)
  config/          # environment, firebase options
  styles/          # theme
  services.dart    # service locator (GetIt) initialization
  app.dart         # app root, Firebase initialization, Sentry setup
  main.dart        # production entrypoint
  dev_emulators_main.dart  # development entrypoint (connects to emulators)
```

**Dependency injection**: GetIt (`services.dart`) is the service locator. All services are registered as singletons in `createServices()` and accessed via top-level getters (e.g., `firestoreDatabase`, `cloudFunctions`).

**Routing**: Uses the Beamer package. Routes are defined in `client/lib/core/routing/locations.dart`.

**State management**: Provider for widget-level state; GetIt services for app-level singletons.

**Localization**: Flutter's built-in `flutter_gen` l10n system. ARB files live in `client/lib/l10n/`. The template is `app_en.arb`. Generated code goes to a synthetic package (`flutter_gen/gen_l10n/app_localizations.dart`). `missing.json` tracks untranslated strings.

**Code generation**: Freezed is used extensively for immutable data classes. Run `build_runner` after modifying any `@freezed` or `@JsonSerializable` annotated classes.

### Firebase Functions

Functions are written in Dart and compiled to Node.js JavaScript. The base classes are:
- `OnCallMethod` (`on_call_function.dart`) — for client-callable functions
- `OnFirestoreFunction` (`on_firestore_function.dart`) — for Firestore triggers
- `OnRequestMethod` (`on_request_method.dart`) — for HTTP request functions

Functions use `firebase_functions_interop` and `firebase_admin_interop` (both forked from the `berkmancenter` GitHub org).

### Data Models

The `data_models` package is a shared Dart library consumed by both the Flutter client and Firebase functions. Models use Freezed for immutability and `json_serializable` for serialization. Cloud function request/response types are defined in `data_models/lib/cloud_functions/`.

### Matching

The `matching/` package contains the algorithm for assigning participants to breakout rooms based on survey responses. It is imported as a Dart package by both the client and Firebase functions.

## Linting Rules (Client)

From `client/analysis_options.yaml`:
- `prefer_single_quotes: true`
- `avoid_print: true`
- `unawaited_futures: true` (error level)
- `missing_required_param: error`
- `require_trailing_commas: true`
- Generated files (`**.freezed.dart`, `**.g.dart`, `test/**.mocks.dart`) are excluded from analysis.

## E2E Testing Notes

- All Playwright tests must import `test` from the custom fixture (`custom-test-fixture.ts`) to enable Flutter accessibility semantics, which is required for element locators to work.
- Tests follow the [Page Object Model](https://playwright.dev/docs/pom); page models live in `e2e/pages/`.
- Tests must tear down anything they create.
- Requires `.env` in the `e2e/` directory with `BASE_URL`, `TEST_OWNER_USER_NAME/PASSWORD`, and `TEST_MEMBER_USER_NAME/PASSWORD`.

## Commit Style

Longform commits are preferred. Include the "why" behind changes, relevant context, and link to issues when applicable (`Fixes #1234`).
