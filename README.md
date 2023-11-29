# async_test_sample


An example of UI test with [Maestro](https://maestro.mobile.dev/).

- Compatible with both mobile platforms:
  - Android
  - iOS (simulator only)
- Flows of Maestro test are defined here:
  - [common test flow](./maestro/search.yaml) 
  - [Android](./maestro/search_android.yaml)
  - [iOS](./maestro/search_ios.yaml)
- Details are described in [a Qiita article (japanese)](https://qiita.com/Seo-4d696b75/items/dadd62fab4545b7fad58).

For unit test, [please ses this branch.](https://github.com/Seo-4d696b75/dart-async-test-sample/tree/riverpod2)

## Setup

### 0. Install Flutter (if needed)

This project uses fvm. 
After installing, be sure to set "${projectRoot}/.fvm/flutter_sdk" as Flutter SDK path in your IDE.

`fvm install`

### 1. Install dependencies

`fvm flutter pub get`

### 2. Run Build Runner

`fvm flutter pub run build_runner build`


### 3. Build & Install

**Be sure to use mock build**

```bash
# Android
fvm flutter build apk --debug -t lib/main_mock.dart
adb install build/app/outputs/flutter-apk/app-debug.apk
# iOS
fvm flutter build ios --debug --simulator -t lib/main_mock.dart
xcrun simctl install ${device} build/ios/iphonesimulator/Runner.app
```

### 4. Install Maestro

[Please follow the official install guide](https://maestro.mobile.dev/getting-started/installing-maestro)

## Run Tests

```bash
# Android
maestro maestro/search_android.yaml
# iOS
maestro maestro/search_ios.yaml
```

![maestro_sample_android.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/440643/85200649-6a2f-bdd2-5369-7f9b9001e192.gif)
