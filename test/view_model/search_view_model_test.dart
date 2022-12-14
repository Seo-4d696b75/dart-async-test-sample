import 'dart:async';

import 'package:async_test_sample/domain/usecase/search_usecase.dart';
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

  group("Check loading-state while running search", () {
    setUp(() {
      // Some tests fail before verifying call of the mocked useCase.
      // The mocked should be reset everytime, so that other tests not affected.
      reset(mockUseCase);
    });
    test("Failure 1", () async {
      final viewModel = SearchViewModel(mockUseCase);
      expect(viewModel.debugState, isA<SearchStateEmpty>());
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      await viewModel.search("keyword");
      // Search operation has be done and the current is data-state, not loading
      expect(viewModel.debugState, isA<SearchStateLoading>()); // Error

      verify(mockUseCase.call("keyword")).called(1);
      expect(viewModel.debugState, isA<SearchStateData>());
    });
    test("Failure 2", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>()); // OK

      verify(mockUseCase.call("keyword")).called(1);
      // Search operation has NOT done yet and the current is still loading-state.
      expect(viewModel.debugState, isA<SearchStateData>()); // Error
    });
    test("Ambiguous Delay", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      // Insert delay so that search operation has done before verifying
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verify(mockUseCase.call("keyword")).called(1);
      expect(viewModel.debugState, isA<SearchStateData>());
    });
    test("Wait for Async Operation 1", () async {
      final viewModel = SearchViewModel(mockUseCase);
      final searchCompleter = Completer<List<String>>();
      when(mockUseCase.call(any)).thenAnswer(
        // calling this will NOT return until the completer has been completed
        (_) => searchCompleter.future,
      );

      // test
      final searchCall = viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      // complete
      searchCompleter.complete(["result1", "result2"]);
      await searchCall;

      // verify
      verify(mockUseCase.call("keyword")).called(1);
      final state = viewModel.debugState;
      expect(state, isA<SearchStateData>());
      state as SearchStateData;
      expect(state.keyword, "keyword");
      expect(state.hits, ["result1", "result2"]);
    });
    test("Wait for Async Operation 2", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // test
      viewModel.search("keyword");
      expect(viewModel.debugState, isA<SearchStateLoading>());

      // wait until data-state is received from StateNotifier#stream
      await viewModel.waitUntil<SearchStateData>();

      // verify
      verify(mockUseCase.call("keyword")).called(1);
      final state = viewModel.debugState;
      expect(state, isA<SearchStateData>());
      state as SearchStateData;
      expect(state.keyword, "keyword");
      expect(state.hits, ["result1", "result2"]);
    });
    test("Watch Stream (Failure)", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // listen
      final listener = MockStateListener();
      viewModel.stream.listen(listener);

      // test
      await viewModel.search("keyword");

      // At this moment, data-state not received in the listener yet.
      // To verify all the state changes, it's needed to wait for a while.
      // If any of the following comment-outed lines toggled, this test will pass.
      // await Future<void>.delayed(const Duration(milliseconds: 100));
      // await Future.microtask(() => null);

      // verify
      verify(mockUseCase.call("keyword")).called(1);
      verifyInOrder([
        listener.call(argThat(isA<SearchStateLoading>())),
        listener.call(argThat(isA<SearchStateData>())),
      ]);
    });
    test("Watch Stream", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // listen
      final listener = MockStateListener();
      viewModel.stream.listen(listener);

      // test
      viewModel.search("keyword");
      // wait until all state changes received in the listener
      await viewModel.waitUntil<SearchStateData>();

      // verify
      verify(mockUseCase.call("keyword")).called(1);
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
