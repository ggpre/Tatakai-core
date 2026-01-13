# Tatakai Mobile - Flutter Anime Streaming App

A pixel-perfect Flutter implementation of the Tatakai anime streaming platform with full feature parity to the web app.

## 🚀 Features

### Core Features
- **Multi-source anime aggregation** (Consumet, AniSkip, WatchAnimeWorld)
- **Supabase Authentication** (Email/Password, OAuth with role-based access) — Mobile uses Supabase for all user authentication (no other auth systems are used).
- **Watch History** tracking with cloud sync
- **Watchlist & Favorites** management
- **Comments & Ratings** with community features
- **Custom Playlists** with sharing capabilities
- **Tier Lists** creation and community discovery
- **Full Search & Discovery** with advanced filtering
- **14+ Theme System** with dark/light modes and custom themes
- **Analytics Tracking** (opt-out available)

### Mobile-Specific Features
- **Download Support** for episodes and seasons
- **Offline Playback** of downloaded content
- **Web ↔ App Synchronization** (real-time)
- **Push Notifications** (FCM-based)
- **In-App Notifications** for instant alerts
- **WatchAnimeWorld Integration** with embed support
- **Over-the-Air Updates** capability

### Video Player Features
- HLS streaming support with multi-quality options
- Subtitle support with customization
- AniSkip integration (auto-skip intro/outro)
- Multi-source fallback logic
- Resume playback from last position
- Picture-in-Picture mode
- Playback speed control (0.5x - 2x)
- Quality selection (480p, 720p, 1080p, Auto)

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- iOS development: Xcode 14+ and CocoaPods
- Android development: Android Studio and SDK 21+
- Firebase project (for push notifications)
- Supabase account (already configured)

## 🛠️ Installation & Setup

### 1. Install Flutter

```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Clone and Setup Project

```bash
cd tatakai_mobile

# Install dependencies
flutter pub get

# Generate code for JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS and Android apps to your Firebase project
3. Download configuration files:
   - iOS: `GoogleService-Info.plist` → Place in `ios/Runner/`
   - Android: `google-services.json` → Place in `android/app/`

### 4. iOS Setup

```bash
cd ios
pod install
cd ..

# Open iOS project in Xcode to configure signing
open ios/Runner.xcworkspace
```

Update `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Tatakai needs access to save downloaded episodes</string>
<key>NSCameraUsageDescription</key>
<string>Tatakai needs camera access for profile pictures</string>
```

### 5. Android Setup

Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## 🏃 Running the App

### Development

```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor
flutter run --flavor dev

# Run in release mode
flutter run --release
```

### iOS

```bash
flutter run -d iphone
# or
flutter run -d <device_id>
```

### Android

```bash
flutter run -d android
# or
flutter run -d <device_id>
```

## 📦 Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode for App Store submission
open ios/Runner.xcworkspace
```

## 📁 Project Structure

```
tatakai_mobile/
├── lib/
│   ├── config/          # App configuration (env, theme, router)
│   ├── models/          # Data models (anime, user, download, etc.)
│   ├── providers/       # Riverpod providers for state management
│   ├── services/        # API, Supabase, downloads, notifications
│   ├── widgets/         # Reusable UI components
│   ├── screens/         # All app screens (18 total)
│   ├── constants/       # App constants (colors, strings, dimensions)
│   └── main.dart        # App entry point
├── assets/              # Images, icons, fonts, design references
├── android/             # Android-specific configuration
├── ios/                 # iOS-specific configuration
├── pubspec.yaml         # Flutter dependencies
└── README.md            # This file
```

## 🎨 Themes

The app includes 15+ pre-built themes:
- Default Dark/Light
- Cyberpunk
- Ocean
- Forest
- Sunset
- Midnight
- Rose
- Emerald
- Amber
- Slate
- Cherry Blossom
- Matrix
- Dracula
- Nord
- Tokyo Night

## 🔐 Environment Variables

Create a `.env` file with:
```env
API_BASE_URL=https://aniwatch-api-taupe-eight.vercel.app/api/v2/hianime
SUPABASE_URL=https://xkbzamfyupjafugqeaby.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
PROXY_URL=https://xkbzamfyupjafugqeaby.supabase.co/functions/v1/rapid-service
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of the Tatakai platform. All rights reserved.

## 🆘 Troubleshooting

### Common Issues

#### Build fails on iOS
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

#### Android build errors
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
```

#### Firebase not working
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are correctly placed
- Check Firebase project configuration matches your bundle ID

#### Video playback issues
- Ensure device has internet connection
- Check Supabase proxy is working
- Verify video URL is valid

### Performance Optimization

- Use `flutter run --profile` to profile performance
- Check for memory leaks with DevTools
- Optimize images and assets
- Use `const` constructors where possible

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Contact: support@tatakai.gabhasti.tech

## 🚧 Roadmap

- [ ] Chromecast support
- [ ] Apple TV support
- [ ] Android TV optimization
- [ ] Watch party feature
- [ ] Advanced video filters
- [ ] Manga reader integration

## 📊 Analytics

The app tracks:
- Page views (can be disabled in settings)
- Watch sessions (duration, completion rate)
- App crashes (for debugging)
- Feature usage (for improvements)

All analytics respect user privacy and can be opted out in Settings.

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- All 18 screens implemented
- Full feature parity with web app
- Download support
- Push notifications
- Real-time synchronization

---

Built with ❤️ using Flutter
