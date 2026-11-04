# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`water_alert_app` — the Flutter client for a flood-warning system.
Users register, see water levels, weather and warnings, find shelters on a map, and make
donations. The backend is the sibling `FYP_Backend` repo (Django + DRF).

~5,900 lines of Dart across 31 files in `lib/`. Android is the target that's been exercised;
`ios/`, `web/`, `linux/`, `macos/` and `windows/` are untouched Flutter scaffolding.

## Two things stop this running on anyone else's machine

### 1. The API base URL is a hardcoded LAN IP

`lib/api/api_service.dart:11-13`:

```dart
//static const String baseUrl = "http://10.0.2.2:8000"; //模拟器
//static const String baseUrl = "http://192.168.59.89:8000";
static const String baseUrl = "http://10.170.202.245:8000";
```

Every API call goes through this one constant, so the app only works on the network where
that address is the developer's machine. The commented lines are previous networks. This is
edited by hand whenever the Wi-Fi changes.

- `10.0.2.2` is the Android emulator's alias for the host machine
- a `192.168.x` / `10.x` address is a physical device on the same LAN
- the backend must be started with `runserver 0.0.0.0:8000`, not the default bind

Fix properly with `--dart-define=API_BASE_URL=...` and
`String.fromEnvironment('API_BASE_URL')` so it's build-time config rather than a source edit.

### 2. A Google Maps API key is committed

`android/app/src/main/AndroidManifest.xml:13` contains a real `AIza…` key, and **this repo
is public**. Google Maps keys are billable. It should be restricted to this app's package
name and SHA-1 at minimum, ideally rotated and injected at build time. Treat the current key
as compromised.

## Architecture

```
lib/
  main.dart            29 lines — MaterialApp, 4 named routes, no initial auth check
  app_theme.dart       the shared ThemeData
  api/
    api_service.dart   290 lines — every backend call, all static methods
    weather.dart       66 lines — calls api.data.gov.my directly, NOT via the backend
  models/              7 plain data classes with fromJson
  screens/             22 screens; map_page.dart is the largest at 595 lines
  widgets/
    base_layout.dart   the shared scaffold
```

**There is no state management.** `provider` is in `pubspec.yaml` but **imported by zero
files** — the same trap as an unused framework anywhere else. Screens are `StatefulWidget`s
that call `ApiService` in `initState` and `setState` on the result. Don't assume a provider
tree exists.

**`ApiService` is all static methods** and reads the token from `SharedPreferences` on each
call:

```dart
'Authorization': 'Token $token',
```

The token is stored under the key `auth_token` after login. `main.dart` routes straight to
`MainScreen` with no check for an existing token, so auth state is decided per-screen.

**Two external data paths.** Water levels come from the Django backend (which scrapes a
government site with Selenium — see the backend's CLAUDE.md, those endpoints take 3+ seconds).
Weather comes from `api.data.gov.my` called **directly from the app**. So the backend is not
the single source of data.

## Packages in pubspec that nothing imports

| Package | Imported by |
|---|---|
| `provider` | **0 files** |
| `geolocator` | **0 files** — `map_page.dart` uses `location` instead |
| `flutter_map` | **0 files** — `map_page.dart` uses `google_maps_flutter` instead |
| `intl` | **0 files** |

Two map packages and two geolocation packages are declared; one of each is used. Removing
the four unused ones is a safe deletion that shrinks the dependency tree.

## Distance is calculated on the phone

`map_page.dart` imports `dart:math` and implements haversine inline (around line 80:
`cos(lat1) * cos(lat2)`, `2 * atan2(sqrt(aa), sqrt(1-aa))`). The backend's
`ShelterListAPIView` returns **every** shelter with no filtering, so the app downloads all
of them and sorts locally.

That works at this data size. "Nearest open shelter" belongs server-side if the shelter list
ever grows — which is the argument for PostGIS in the backend repo.

## Commands

```bash
flutter pub get
flutter run                      # device or emulator must reach baseUrl (see above)
flutter analyze
flutter test                     # only the stock widget_test.dart exists
flutter build apk --release
```

Android permissions already declared: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
`INTERNET`. Location permission is requested at runtime by the `location` package.

## Known issues

- **One commit, 15 months old.** The history is a single dump, so there's no record of how
  anything was built.
- **`README.md` is the stock "A new Flutter project"** and says nothing about the app.
- **No real tests** — `test/widget_test.dart` is the generated counter-app test and doesn't
  match this app.
- Comments are a mix of Chinese and English.
- No loading/error conventions: each screen handles failure its own way, and
  `ApiService` methods mostly return `bool` or an empty list on failure, so the UI can't
  distinguish "no data" from "request failed".
- Only Android has been exercised despite six platform folders existing.
