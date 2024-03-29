import 'dart:async';

import 'package:async_test_sample/domain/usecase/search_usecase.dart';
import 'package:async_test_sample/ui/search/search_state.dart';
import 'package:async_test_sample/ui/search/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_view_model_test.mocks.dart';

abstract class ChangeListener {
  void call(SearchState? previous, SearchState next);
}

@GenerateMocks([SearchUseCase, ChangeListener])
void main() {
  final mockUseCase = MockSearchUseCase();

  group("Check loading-state while running search", () {
    setUp(() {
      // Some tests fail before verifying call of the mocked useCase.
      // The mocked should be reset everytime, so that other tests not affected.
      reset(mockUseCase);
    });
    test("1. Failure", () async {
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
    test("2. Failure", () async {
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
    test("3. Ambiguous Delay (Should be avoided)", () async {
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
    test("4. Read ProviderContainer", () async {
      final container = ProviderContainer(
        overrides: [
          searchUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
      addTearDown(container.dispose);

      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      final subscription = container.listen(
        searchViewModelProvider,
        (_, __) {},
      );
      final viewModel = container.read(searchViewModelProvider.notifier);

      // test
      final searchCall = viewModel.search("keyword");
      expect(
        subscription.read(),
        isA<SearchStateLoading>(),
      );

      // complete
      await searchCall;

      // verify
      verify(mockUseCase.call("keyword")).called(1);
      final state = subscription.read();
      expect(state, isA<SearchStateData>());
      state as SearchStateData;
      expect(state.hits, ["result1", "result2"]);
    });


    test("6. Listen ProviderContainer", () async {
      final container = ProviderContainer(
        overrides: [
          searchUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
      addTearDown(container.dispose);

      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      // listen
      final listener = MockChangeListener();
      container.listen(
        searchViewModelProvider,
        listener,
        fireImmediately: true,
      );

      // test
      final viewModel = container.read(searchViewModelProvider.notifier);
      await viewModel.search("keyword");

      // verify
      verifyInOrder([
        listener.call(argThat(isNull), argThat(isA<SearchStateEmpty>())),
        listener.call(
          argThat(isA<SearchStateEmpty>()),
          argThat(isA<SearchStateLoading>()
              .having((s) => s.keyword, "keyword", "keyword")
              .having((s) => s.previousHits.isEmpty, "previousHits", isTrue)),
        ),
        listener.call(
          argThat(isA<SearchStateLoading>()),
          argThat(isA<SearchStateData>()
              .having((s) => s.hits, "hits", ["result1", "result2"])),
        ),
      ]);
      verify(mockUseCase.call("keyword")).called(1);
    });

    test("7. Watch Stream", () async {
      final viewModel = SearchViewModel(mockUseCase);
      when(mockUseCase.call(any)).thenAnswer((_) async {
        return ["result1", "result2"];
      });

      final verifyStream = expectLater(
        viewModel.stream,
        emitsInOrder([
          isA<SearchStateLoading>()
              .having((s) => s.keyword, "keyword", "keyword")
              .having((s) => s.previousHits.isEmpty, "previousHits", isTrue),
          isA<SearchStateData>()
              .having((s) => s.hits, "hits", ["result1", "result2"]),
        ]),
      );

      // test
      await viewModel.search("keyword");

      // verify
      verify(mockUseCase.call("keyword")).called(1);
      await verifyStream;
    });
  });
}
