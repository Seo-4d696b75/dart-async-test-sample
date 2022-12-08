# async_test_sample

async test samples

**Feature**  
- Unit test with async functions
- Uses [Mockito](https://pub.dev/packages/mockito) for mocking dependencies
- Immutable state by [freezed](https://pub.dev/packages/freezed)
- Tests StateNotifier of [riverpod](https://riverpod.dev/)

非同期処理のテストサンプル

[解説記事](https://qiita.com/Seo-4d696b75/private/b677999b4a82fcda11dd)

## Setup

### 1. Install dependencies

`flutter pub get`

### 2. Run Build Runner

`flutter pub run build_runner build`

## Run Tests

`flutter test`

Some tests fail, while others get passed. 
[Please see test codes for more details.](./test/view_model/search_view_model_test.dart)