# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

DComicReborn is a cross-platform Flutter comic/manga reader app (v2.3.9). It aggregates comics from CopyManga, DMZJ, and ZaiManHua sources. No self-hosted backend—pure client-side app talking to third-party APIs.

### Prerequisites

- **Flutter 3.29.0** installed at `/opt/flutter` (added to `PATH` via `~/.bashrc`)
- **Android SDK** at `/opt/android-sdk` (platforms;android-35, build-tools;35.0.0, ndk;27.0.12077973)
- **JDK 21** (pre-installed on VM)
- `ANDROID_HOME=/opt/android-sdk` set in `~/.bashrc`

### Key commands

| Task | Command |
|---|---|
| Install deps | `flutter pub get` |
| Code generation (Floor ORM) | `flutter packages pub run build_runner build --delete-conflicting-outputs` |
| Lint / static analysis | `flutter analyze` |
| Run tests | `flutter test` |
| Build debug APK | `flutter build apk --debug` |

See `README.md` for ORM database generation instructions.

### Gotchas

- **`key.properties` required**: `android/app/build.gradle` unconditionally loads `android/key.properties`. For debug builds, create it with a debug keystore (see `android/key.properties` if present). Without this file, Gradle will fail immediately.
- **Widget test is stale**: `test/widget_test.dart` is the default Flutter template counter test—it does not match the actual app and will always fail. This is a pre-existing issue.
- **`flutter analyze` exits with code 1** due to pre-existing warnings/info (unused imports, deprecated API usage, etc.). No actual errors.
- **No Linux desktop target**: The project targets Android/iOS/Windows. Linux toolchain warnings from `flutter doctor` are expected and non-blocking.
- **First Gradle build is slow** (~8 min) as it downloads Gradle, CMake, and dependencies. Subsequent builds are much faster.
