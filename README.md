# Flutter Sensors

A small Flutter demo that shows various device sensors (accelerometer, gyroscope, magnetometer/compass, GPS/location). NFC support was intentionally removed from this repository; notes and instructions are included below.

**Quick summary:**
- **Platform:** Android & iOS
- **Main sensors shown:** accelerometer, gyroscope, magnetometer (compass), GPS/location
- **Removed:** NFC support (`nfc_manager`), NFC manifest entries and `res/xml/nfc_tech_filter.xml`

**Getting Started**
- **Prerequisites:**
  - Flutter SDK (stable channel) installed and on your PATH
  - Android SDK (for Android builds) and Xcode (for iOS builds on macOS)
  - A physical device is recommended for sensor tests (emulators may not expose all sensors)

- **Install dependencies:**
```
cd "$(pwd)"
flutter pub get
```

- **Run on device (debug):**
```
flutter run
```

- **Build release APK:**
```
flutter build apk
```

- **Build iOS (macOS):**
```
flutter build ios --no-codesign
```

**Files of interest**
- `lib/sensors_page.dart`: main UI and sensor subscriptions.
- `android/app/src/main/AndroidManifest.xml`: Android manifest (NFC entries removed).
- `ios/Runner/Info.plist`: iOS permission strings (location keys added).
- `pubspec.yaml`: project dependencies.

**Dependencies**
- This project uses (current): `sensors_plus`, `geolocator`, `flutter_compass`.
- NFC dependency `nfc_manager` was removed intentionally. If you need NFC, re-add it to `pubspec.yaml` and follow package instructions.

**Notes about NFC removal**
- The manifest previously referenced `@xml/nfc_tech_filter`, which caused a resource linking failure during build when that resource was missing. To avoid that class of problems the NFC entries and helper XML were removed.
- If you later reintroduce NFC support, make sure to:
  - Add `nfc_manager` (or equivalent) to `pubspec.yaml`.
  - Add the `res/xml/nfc_tech_filter.xml` resource and correct `<meta-data>` entry in `AndroidManifest.xml`.
  - Add any needed iOS Info.plist keys if the package requires them.

**iOS permissions**
- This app uses `geolocator` for GPS. The following keys were added to `ios/Runner/Info.plist`:
  - `NSLocationWhenInUseUsageDescription` — description shown when requesting location while app is in use.
  - `NSLocationAlwaysAndWhenInUseUsageDescription` — description shown if you request background/always access.

Make sure the descriptions explain why you need the permissions to avoid rejection during App Store review.

**Temperature sensor (removed)**
- Many phones do not expose an ambient temperature sensor. Originally a Thermometer card was present in the UI as an informational placeholder.
- Options if you want temperature data:
  - Use a weather API (e.g., OpenWeatherMap) to get ambient temperature by coordinates. This is the most portable solution.
  - Integrate a hardware-specific plugin or platform channel if you have a device with an actual ambient sensor.

Example: fetch temperature from OpenWeatherMap (conceptual):
```
final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=YOUR_KEY';
// Use http package to GET and parse JSON -> main.temp
```

**Troubleshooting**
- Android resource linking error referencing `@xml/nfc_tech_filter`: remove NFC manifest entries or add the missing file (`android/app/src/main/res/xml/nfc_tech_filter.xml`).
- If you see permission or runtime failures on location: ensure location services are enabled on the device and that you granted the requested permission.
- If `flutter pub get` shows incompatible versions, run `flutter pub outdated` then update versions as appropriate.

**Contributing**
- Feel free to open issues or PRs. Suggested small tasks:
  - Add a real temperature data source (weather API integration).
  - Improve permission handling UX and explanatory dialogs.

**License**
- This repository includes example/demo code — pick an appropriate license for your project or ask and I can add one.

If you want, I can:
- Add an example `OpenWeatherMap` integration and UI to replace the removed thermometer.
- Reintroduce NFC properly (add resource and dependency) instead of removing it.

---
Last updated: November 26, 2025
# flutter_sensors

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
