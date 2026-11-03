# Weather App

A small Flutter app that lets you search for a city and see its **current weather** and a **5-day forecast**, using the free [Open-Meteo](https://open-meteo.com/en/docs) API (no API key or signup needed).

> Screenshots / screen recording: _add them here (e.g. `docs/screenshots/`)_

---

## 1. Technology and version

| Item | Version |
|---|---|
| Framework | Flutter (stable channel), Material 3 |
| Flutter version used | **3.47.9** |
| Dart SDK constraint | `>=3.3.0 <4.0.0` (resolved against Dart 3.13+) |
| IDE | Android Studio / IntelliJ (Flutter + Dart plugins) |
| Target platforms | Android and iOS |
| API | Open-Meteo Geocoding + Forecast (REST, JSON) |

---

## 2. Setup and run

**Prerequisites:** Flutter SDK installed and on your `PATH`, plus an Android emulator / iOS simulator or a physical device. Check your setup with `flutter doctor`.

1. **Clone the repository**
   ```bash
   git clone <this-repository-url>
   cd weather_app
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Start an emulator or connect a device**, then confirm it is detected:
   ```bash
   flutter devices
   ```
4. **Run the app**
   ```bash
   flutter run
   ```
5. **(Optional) Run static analysis and tests**
   ```bash
   flutter analyze
   flutter test
   ```

An internet connection is required for fresh data. The `INTERNET` permission is already declared in `android/app/src/main/AndroidManifest.xml`, so release builds also work (`flutter build apk`).

---

## 3. Features completed

### Must-have requirements

- [x] **City search** – the user types a city name and submits. Empty input, whitespace-only input and input without any letter (e.g. `"   "`, `"!!!"`) is rejected **before** any API call.
- [x] **Two-step API flow** – geocoding first (city → coordinates), then forecast (coordinates → weather).
- [x] **Current weather** – city, country, temperature, condition (text + emoji icon), humidity and wind speed, all with units (°C / °F, %, km/h).
- [x] **5-day forecast** – day/date, weather icon and min/max temperature for each day.
- [x] **Loading state** – spinner on first load, thin progress bar when refreshing existing data. The UI never blocks.
- [x] **Error states** – friendly messages for: city not found, invalid input, no internet, timeout, server/API failure and unexpected data. Raw exceptions are never shown and the app does not crash.
- [x] **Empty state** – "Search for a city to see its weather" before the first search.
- [x] **Offline support** – the last successful result is saved locally (SharedPreferences). When the network fails, the saved data is shown with a "may be outdated" notice and a last-updated time.

### Edge cases handled

- City that does not exist, or a query made only of spaces/special characters.
- No internet on first launch (error screen with **Try again**) vs. no internet with cached data (saved data + notice).
- 10-second request timeout with a clear error message.
- Searching again while a previous request is still loading – a request-id guard makes sure only the **newest** request updates the UI; older responses are ignored.
- Same city name in different countries – a list (name, region, country) is shown to choose from.
- Unknown weather codes – shown as "Unknown" with a default icon.
- Screen rotation and app restart – state lives in a view model above the screen; on restart the cached city is shown immediately and refreshed in the background.
- Corrupted cache – ignored safely instead of crashing the app.

### Bonus features

- [x] **Celsius / Fahrenheit toggle** (preference saved between launches)
- [x] **Pull-to-refresh** for the current city
- [x] **Dark mode** (follows the system light/dark theme)
- [x] **Search history** (last 5 cities, shown as chips)
- [x] **Unit and widget tests** (models/parsing, weather-code mapping, validator, formatters, API service with a mock HTTP client, local storage, view model, and UI)
- [ ] Current location (not implemented – see section 6)

---

## 4. Architecture and libraries

### Pattern: MVVM + Repository

```
lib/
├── main.dart                     # app entry, wires dependencies
├── app.dart                      # MaterialApp, themes, provider setup
├── core/
│   ├── constants.dart            # URLs, storage keys, limits, UI strings
│   ├── app_exception.dart        # AppException + FailureType
│   ├── formatters.dart           # temperature / wind / date formatting
│   ├── input_validator.dart      # city-query validation
│   └── weather_code.dart         # WMO code -> description + emoji
├── data/
│   ├── models/                   # City, CurrentWeather, DailyForecast, WeatherReport
│   ├── services/                 # WeatherApiService (HTTP only)
│   ├── local/                    # WeatherLocalDataSource (SharedPreferences only)
│   └── repositories/             # WeatherRepository (API + cache, validation)
└── presentation/
    ├── viewmodels/               # WeatherViewModel (ChangeNotifier, all screen state)
    ├── screens/                  # HomeScreen
    └── widgets/                  # search field, current card, forecast list, states...
```

**Why this structure:** the UI never touches the network or storage, the view model never touches widgets, and each layer can be tested on its own (the view model is tested against a fake repository, the API service against a mock HTTP client). `provider` + `ChangeNotifier` was chosen because it is simple, built on standard Flutter concepts and fully sufficient for a single screen of state.

### Libraries

| Package | Version | Purpose |
|---|---|---|
| `http` | 1.6.0 | REST calls to Open-Meteo |
| `provider` | 6.1.5+1 | State management (`ChangeNotifier`) |
| `shared_preferences` | 2.5.6 | Offline cache, search history, unit preference |
| `flutter_lints` (dev) | 4.0.0 | Lint rules |
| `flutter_test` (dev) | SDK | Unit and widget tests |

### Design decisions

- **Several matching cities:** a short list is shown to choose from. If only one city matches, it is used directly.
- **Units:** temperatures are stored in Celsius and converted only for display.
- **Offline detection:** instead of a connectivity plugin, an actual request failure (`SocketException` / timeout) triggers the fallback to cached data. This is more reliable than a "connected" flag.
- **Error policy:** errors caused by the user (invalid input, unknown city) always show an error screen. Connectivity/API errors fall back to saved data when it exists.
- **No hard-coded values:** URLs, timeouts, limits, storage keys and all UI strings live in `core/constants.dart`.

---

## 5. Assumptions and known limitations

**Assumptions**

- The first forecast row is "today" in the **searched city's** timezone (API called with `timezone=auto`), so it is labelled by position rather than by the device clock.
- Open-Meteo returns temperature in °C and wind in km/h by default; these units are used as the base.

**Known limitations**

- Only the most recent successful result is cached (one city). The search history stores city names only; opening one fetches fresh data.
- Emoji are used as weather icons, so their appearance depends on the device's emoji font.
- Wind speed is always shown in km/h, even in Fahrenheit mode.
- The app is English only (not localized).
- Offline detection relies on a failed request, so on a very poor connection it can take up to the timeout (10 s) before the saved data is shown.
- Current location (GPS) is not implemented.
- Tested mainly on Android; iOS was not tested on a physical device.

---

## 6. What I would improve or add with more time

- **Current location** with proper permission handling (`geolocator`).
- **Hourly forecast** and a **weekly temperature chart**.
- **Auto-suggestions while typing** (debounced search).
- Proper **icon assets** (or an icon pack) instead of emoji.
- **Localization** and mph for wind in Fahrenheit mode.
- Cache **multiple cities**, not just the last one.
- **Integration tests** on a real device and **CI** running `flutter analyze` and `flutter test`.