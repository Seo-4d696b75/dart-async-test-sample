# async_test_sample

**Feature**  
- Unit test with async functions
- Uses [Mockito](https://pub.dev/packages/mockito) for mocking dependencies
- Immutable state by [freezed](https://pub.dev/packages/freezed)
- Tests StateNotifier of [riverpod](https://riverpod.dev/)

For testing AsyncNotifier of Riverpod 2.0, [please see this branch.](https://github.com/Seo-4d696b75/dart-async-test-sample/tree/riverpod2)

非同期処理のテストサンプルです（[解説記事](https://qiita.com/Seo-4d696b75/private/b677999b4a82fcda11dd)）。
Riverpod 2.0以降のAsyncNotifierのテストは[こちらのブランチにあります。](https://github.com/Seo-4d696b75/dart-async-test-sample/tree/riverpod2)

## App to be Tested

<img src="https://user-images.githubusercontent.com/25225028/207562903-57e75115-3989-45c0-8401-404cdf444063.gif" width="300">

1. Put keyword string
2. Tap "Search" button or "Next" button on the soft keyboard
3. Progress indicator shown while searching
4. Search results (string list) shown

## Setup

### 0. Install Flutter (if needed)

This project uses fvm. 
After installing, be sure to set "${projectRoot}/.fvm/flutter_sdk" as Flutter SDK path in your IDE.

`fvm install`

### 1. Install dependencies

`fvm flutter pub get`

### 2. Run Build Runner

`fvm flutter pub run build_runner build`

## Run Tests

`fvm flutter test`

Some tests fail, while others get passed. 
[Please see test codes for more details.](./test/view_model/search_view_model_test.dart)
