# Calculator Hub

Five offline Flutter tools: percentage calculations, exact fractions, geometry,
number bases and unit conversion. Invalid and nonfinite inputs are explained in
the tool. Geometry and unit conversion use floating-point arithmetic; fraction
arithmetic uses exact integer fractions. No accounts, telemetry or network API.

This repository was empty. Its first implementation reuses the owner's five
numeric modules from `offline-fifty-flutter-20261002`, with a new smaller catalog.
The shared foundation contains UI widgets only; the larger catalog's storage
system and unrelated applications are not included.

```sh
flutter pub get
dart analyze .
flutter test test apps
flutter run -d windows
flutter build windows --debug
flutter build apk --debug
```

Android and Windows platform source is included. Debug builds are development
artifacts; no release signing or app-store publication is claimed. iOS/macOS/
Linux are not included or tested in this first version.

Verified in this first version: 39 passing tests, clean analysis, Android debug APK and Windows debug build. See the development review for exact scope.
