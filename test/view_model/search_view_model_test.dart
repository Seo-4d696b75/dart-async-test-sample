import 'dart:async';

import 'package:async_test_sample/model/search_usecase.dart';
import 'package:async_test_sample/ui/search/search_state.dart';
import 'package:async_test_sample/ui/search/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'helper.dart';
import 'search_view_model_test.mocks.dart';

@GenerateMocks([SearchUseCase, StateListener])
void main() {
  final mockUseCase = MockSearchUseCase();

  group("検索中のloading状態を確認", () {
    setUp(() {
      // verifyでモック呼び出しを確認するまえに落ちるテストケースがあるので
      // 他テストケースに影響しないよう毎回リセットする
      reset(mockUseCase);
    });
    test("失敗1", () async {
      final viewModel = SearchViewModel(mockUseCase);
      expect(viewModel.debugState, isA<SearchStateEmpty>());
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      await viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      verify(mockUseCase.call()).called(1);
      expect(viewModel.debugState, isA<SearchStateData>());
    });
    test("失敗2", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      verify(mockUseCase.call()).called(1);
      expect(viewModel.debugState, isA<SearchStateData>());
    });
    test("怪しい非同期処理のテスト", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      verify(mockUseCase.call()).called(1);
      expect(viewModel.debugState, isA<SearchStateData>());
    });
    test("非同期処理を正しく待機する1", () async {
      final viewModel = SearchViewModel(mockUseCase);
      final searchCompleter = Completer<List<String>>();
      when(mockUseCase.call()).thenAnswer(
        (_) => searchCompleter.future,
      );

      // test
      final searchCall = viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      // complete
      searchCompleter.complete(["result1", "result2"]);
      await searchCall;

      // verify
      verify(mockUseCase.call()).called(1);
      final state = viewModel.debugState;
      expect(state, isA<SearchStateData>());
      state as SearchStateData;
      expect(state.keyword, "keyword");
      expect(state.hits, ["result1", "result2"]);
    });
    test("非同期処理を正しく待機する2", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // test
      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      // wait
      await viewModel.waitUntil<SearchStateData>();

      // verify
      verify(mockUseCase.call()).called(1);
      final state = viewModel.debugState;
      expect(state, isA<SearchStateData>());
      state as SearchStateData;
      expect(state.keyword, "keyword");
      expect(state.hits, ["result1", "result2"]);
    });
    test("streamを監視する（失敗）", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // listen
      final listener = MockStateListener();
      viewModel.stream.listen(listener);

      // test
      await viewModel.search("keyword");

      // await Future<void>.delayed(const Duration(milliseconds: 100));
      // await Future.microtask(() => null);

      // verify
      verify(mockUseCase.call()).called(1);
      verifyInOrder([
        listener.call(argThat(isA<SearchStateLoading>())),
        listener.call(argThat(isA<SearchStateData>())),
      ]);
    });
    test("streamを監視する", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call()).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // listen
      final listener = MockStateListener();
      viewModel.stream.listen(listener);

      // test
      viewModel.search("keyword");
      await viewModel.waitUntil<SearchStateData>();

      // verify
      verify(mockUseCase.call()).called(1);
      verifyInOrder([
        listener.call(argThat(isA<SearchStateLoading>())),
        listener.call(
          argThat(
            isA<SearchStateData>()
                .having((s) => s.keyword, "keyword", "keyword")
                .having((s) => s.hits, "hits", ["result1", "result2"]),
          ),
        ),
      ]);
    });
  });
}
