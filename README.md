# Learning Kashmir Shaivism (PlainOS)

Interactive study companion for Kashmir Shaivism learners. Built with Flutter and optimized for Android, iOS, macOS, Windows, and Linux.

## 🌐 Web Live Demo

Try the app directly in your browser: **[https://riverart2000.github.io/learning_hub_KS/](https://riverart2000.github.io/learning_hub_KS/)**

## Requirements

- Flutter 3.27.x (stable channel)
- Dart SDK ^3.9.2
- macOS builds require Xcode and CocoaPods
- Windows builds require Visual Studio with desktop workload
- Linux builds require `clang`, `cmake`, `ninja`, GTK3, LZMA, and GStreamer dev packages

Install Flutter dependencies: `flutter pub get`

### Linux dependencies

Before running `flutter build linux --release`, install:

```bash
sudo apt-get update
sudo apt-get install -y \
	clang \
	cmake \
	ninja-build \
	pkg-config \
	libgtk-3-dev \
	liblzma-dev \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev
```

## Build Commands

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
flutter build macos --release
flutter build windows --release
flutter build linux --release
flutter build web --release
```

## CI

GitHub Actions workflow `.github/workflows/build_and_release_all.yml` runs analysis plus builds for every platform and uploads artifacts. Configure Android signing secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`) for release artifacts.


