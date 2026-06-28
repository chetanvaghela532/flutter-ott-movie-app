# Flutter OTT Movie and Web Series App

A production-ready Flutter OTT app for discovering movies and web series, built with BLoC, Clean Architecture, TMDB API, Firebase Cloud Messaging, in-app video playback, favorites, AdMob-ready monetization, remote configuration, and a premium dark streaming UI.

This project is a strong starting point for anyone building a Netflix-style movie app, OTT streaming app UI, TMDB Flutter app, or production Flutter Clean Architecture project.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC-blueviolet)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-success)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?logo=firebase&logoColor=black)
![TMDB](https://img.shields.io/badge/API-TMDB-01B4E4)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

## Preview

| Home | Details | Search |
| --- | --- | --- |
| ![Home screen](docs/screenshots/home.png) | ![Details screen](docs/screenshots/details.png) | ![Search screen](docs/screenshots/search.png) |

Add your screenshots at:

```text
docs/screenshots/home.png
docs/screenshots/details.png
docs/screenshots/search.png
```

Recommended screenshot size: 1080 x 2400 PNG from a real Android or iOS production build.

## Highlights

- Netflix-style dark OTT user interface
- Movie and web series discovery experience
- Home, movies, web series, search, favorites, settings, and details screens
- TMDB-powered movie, TV show, cast, images, trailers, and watch provider data
- Feature-first Clean Architecture structure
- BLoC state management
- Dio networking layer with interceptors
- GetIt dependency injection
- Firebase Cloud Messaging push notification flow
- Notification tap handling for movie and web series navigation
- YouTube trailer playback
- Direct video URL playback with video player support
- Favorites saved locally
- AdMob-ready banner, interstitial, rewarded, native, and app-open ad hooks
- Remote config support for runtime feature and ad settings
- Android and iOS ready project structure

## Why This Repo Is Useful

This repository is useful if you want to learn or build:

- Flutter movie app
- Flutter OTT app
- Flutter TMDB API app
- Flutter Clean Architecture example
- Flutter BLoC production app
- Netflix-style Flutter UI
- Firebase push notifications in Flutter
- Flutter video player app
- AdMob integration structure in Flutter

## Tech Stack

| Area | Packages / Tools |
| --- | --- |
| Framework | Flutter, Dart |
| State Management | bloc, flutter_bloc |
| Architecture | Clean Architecture, feature-first modules |
| Networking | Dio |
| Dependency Injection | GetIt, Injectable |
| API | TMDB API |
| Push Notifications | Firebase Core, Firebase Messaging |
| Ads | Google Mobile Ads |
| Video | youtube_player_flutter, video_player, Chewie, flutter_inappwebview |
| Local Storage | shared_preferences |
| Utilities | cached_network_image, carousel_slider, shimmer, url_launcher |

## App Features

### Home

- Featured banner
- Latest movies
- Latest web series
- Top content sections
- Genre-based horizontal lists
- Pull-ready data loading structure

### Movies

- Popular, trending, upcoming, and top-rated movie flows
- Movie details
- Cast and crew
- Posters and backdrops
- Similar movies
- Watch providers
- Trailer playback

### Web Series

- Trending, popular, and top-rated TV show flows
- TV show details
- Series cast
- Similar web series
- Watch providers
- Trailer playback

### Search

- Movie search
- TV show search
- Person search
- Actor/person details and credits

### Favorites

- Save favorite movies and shows locally
- Persistent local storage
- Dedicated favorites screen

### Notifications

- Firebase Cloud Messaging setup
- Foreground notification handling
- Background notification handling
- Notification tap navigation
- Topic subscription support

### Monetization

- AdMob-ready architecture
- Banner ads
- Interstitial ads
- Rewarded ads
- Native ads
- App open ads
- Runtime ad configuration support

## Architecture

The project follows Clean Architecture with a feature-first structure.

```text
lib/
  core/
    constants/
    error/
    network/
    services/
    theme/
    utils/

  features/
    movies/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        screens/
        widgets/

  injection/
    injection_container.dart

  models/
    piktv_models.dart

  firebase_options.dart
  main.dart
```

### Layer Responsibilities

| Layer | Responsibility |
| --- | --- |
| Presentation | Screens, widgets, BLoCs, user interactions |
| Domain | Entities, repository contracts, use cases |
| Data | API models, remote datasources, repository implementations |
| Core | Shared services, networking, theme, errors, utilities |

## Public Repository Safety

This repo is prepared for public GitHub usage.

- Real TMDB API keys are not committed.
- Firebase config files are ignored.
- Local `.env` files are ignored.
- Runtime values are provided with `--dart-define`.
- Firebase options use placeholder values from environment defines.
- Private setup notes and verification files are removed.

Important: if you previously committed real keys in another repository history, rotate those keys before making the project public. Removing keys from the latest commit does not remove them from old Git history.

## Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Android Studio or Xcode
- A TMDB API key
- Optional Firebase project for push notifications
- Optional AdMob account for production ads

## Getting Started

### 1. Clone The Repository

```bash
git clone https://github.com/your-username/flutter-ott-movie-app.git
cd flutter-ott-movie-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Create A TMDB API Key

Create a free API key from TMDB:

[https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)

### 4. Run The App

```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

## Environment Values

Use `--dart-define` for local and production configuration.

```bash
flutter run \
  --dart-define=TMDB_API_KEY=your_tmdb_api_key \
  --dart-define=REMOTE_CONFIG_URL=https://example.com/ott_watch_config.txt \
  --dart-define=CONFIG_ENCRYPTION_KEY=replace_with_16_24_or_32_byte_key
```

See `.env.example` for all supported values.

## Firebase Setup

Firebase is optional. The app can run without Firebase, but push notifications require your own Firebase project.

1. Create a Firebase project.
2. Add Android and iOS apps in Firebase Console.
3. Run FlutterFire configuration for your own project.

```bash
flutterfire configure
```

4. Keep generated Firebase files local and do not commit real project config files.

Ignored Firebase files:

```text
firebase.json
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

You can also pass Firebase values through `--dart-define` using the names shown in `.env.example`.

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

## Build Commands

### Android Debug

```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

### Android Release APK

```bash
flutter build apk --release --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

### Android App Bundle

```bash
flutter build appbundle --release --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

### iOS Release

```bash
flutter build ios --release --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

## Recommended GitHub Topics

Add these topics to your GitHub repository for better discoverability:

```text
flutter
dart
flutter-app
movie-app
ott-app
web-series
tmdb-api
bloc
clean-architecture
firebase
firebase-cloud-messaging
admob
video-player
youtube-player
android
ios
mobile-app
streaming-app
open-source
flutter-clean-architecture
```

## Recommended Repository Description

```text
A production-ready Flutter OTT movie and web series app built with BLoC, Clean Architecture, TMDB API, Firebase Cloud Messaging, video playback, favorites, AdMob hooks, and a Netflix-style dark UI.
```

## Roadmap Ideas

- Authentication
- User profiles
- Continue watching
- Offline watchlist sync
- Better unit and widget test coverage
- CI workflow for analyze and test
- Deep links for movies and TV shows
- Multi-language support
- Theme customization

## Security Notes

- Do not commit real API keys.
- Do not commit Firebase service config files for your production project.
- Restrict API keys in Google Cloud and TMDB dashboards where possible.
- Rotate any key that was previously committed to Git history.
- Do not include admin dashboards, emails, tokens, or logs in screenshots.

## TMDB Attribution

This product uses the TMDB API but is not endorsed or certified by TMDB.

Movie and TV metadata, images, and related content are provided by [The Movie Database](https://www.themoviedb.org/).

## Contributing

Contributions are welcome.

If you want to improve the project:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Run `flutter analyze` and `flutter test`.
5. Open a pull request with a clear description.

## Support

If this project helps you, please consider:

- Starring the repository
- Sharing it with Flutter developers
- Opening issues for bugs or improvements
- Following the author for more Flutter projects

## License

This project is available for personal and educational use.

Before accepting external contributions or using this project commercially, add a formal license file such as MIT, Apache-2.0, or your preferred license.

## Keywords

`flutter`, `dart`, `flutter app`, `flutter movie app`, `flutter ott app`, `movie app`, `ott app`, `web series app`, `tmdb api`, `tmdb flutter`, `bloc`, `flutter bloc`, `clean architecture`, `flutter clean architecture`, `firebase`, `firebase cloud messaging`, `admob`, `video player`, `youtube player`, `android app`, `ios app`, `mobile app`, `streaming app`, `netflix clone flutter`, `open source flutter`
