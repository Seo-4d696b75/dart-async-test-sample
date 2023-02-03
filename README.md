# async_test_sample


**Feature**  
- Unit test with async functions
- Uses [Mockito](https://pub.dev/packages/mockito) for mocking dependencies
- Tests AsyncNotifier of [riverpod 2.0](https://riverpod.dev/)

For testing StateNotifier, [please ses this branch.](https://github.com/Seo-4d696b75/dart-async-test-sample/tree/main)

非同期処理のテストサンプルです（[解説記事](https://qiita.com/Seo-4d696b75/items/eee020162d0537fdbc36)）。
StateNotifierのテストは[こちらのブランチにあります。](https://github.com/Seo-4d696b75/dart-async-test-sample/tree/main)

## App to be Tested

<img src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/440643/e6a6c293-0845-3d28-0164-dd1903266347.gif" width="300">

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

[Please see test codes for more details.](./test/view_model/search_view_model_test.dart)
