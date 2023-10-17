import 'package:async_test_sample/domain/usecase/search_usecase.dart';
import 'package:async_test_sample/ui/search/search_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_result_test.mocks.dart';

abstract class ChangeListener<T> {
  void call(T? previous, T next);
}

@GenerateMocks([SearchUseCase, ChangeListener])
void main() {
  final mockUseCase = MockSearchUseCase();
  final listener = MockChangeListener<AsyncValue<List<String>>>();

  ProviderContainer init() {
    final container = ProviderContainer(
      overrides: [
        searchUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
    addTearDown(container.dispose);
    container.listen(
      searchResultProvider,
      listener,
      fireImmediately: true,
    );
    return container;
  }

  group("SearchResult", () {
    setUp(() {
      reset(listener);
      reset(mockUseCase);
    });

    group("initial search", () {
      test("data", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result"],
        );
        final container = init();
        await expectLater(
          container.read(searchResultProvider.future),
          completion(const ["result"]),
        );

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(
                isA<AsyncData>().having((d) => d.value, "value", ["result"])),
          ),
        ]);
        verify(mockUseCase.call("keyword")).called(1);
      });
      test("empty", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => [],
        );
        final container = init();
        await expectLater(
          container.read(searchResultProvider.future),
          completion(const []),
        );

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncData>().having((d) => d.value, "value", [])),
          ),
        ]);
        verify(mockUseCase.call("keyword")).called(1);
      });
      test("error", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => throw Exception("test"),
        );
        final container = init();
        await expectLater(
          container.read(searchResultProvider.future),
          throwsException,
        );

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncError>()),
          ),
        ]);
        verify(mockUseCase.call("keyword")).called(1);
      });
    });

    group("refresh provider", () {
      test("data > data", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result1"],
        );
        final container = init();
        await container.read(searchResultProvider.future);

        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result2"],
        );
        await container.refresh(searchResultProvider.future);

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isFalse)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isTrue)
                .having((d) => d.isReloading, "isReloading", isFalse)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isFalse)
                .having((d) => d.value, "value", ["result2"])),
          ),
        ]);
      });

      test("data > error", () async {
        when(mockUseCase.call(any)).thenAnswer(
              (_) async => ["result1"],
        );
        final container = init();
        await container.read(searchResultProvider.future).then((value) => null);


        when(mockUseCase.call(any)).thenAnswer(
              (_) async => throw Exception("test"),
        );
        await expectLater(
          container.refresh(searchResultProvider.future),
          throwsException,
        );

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isFalse)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isTrue)
                .having((d) => d.isReloading, "isReloading", isFalse)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncError>()
                .having((d) => d.isLoading, "isLoading", isFalse)
                .having((d) => d.hasValue, "hasValue", isTrue)
                .having((d) => d.value, "value", ["result1"])),
          ),
        ]);
      });

      test("error > data", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => throw Exception("test"),
        );
        final container = init();
        await expectLater(
          container.read(searchResultProvider.future),
          throwsException,
        );

        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result2"],
        );
        await container.refresh(searchResultProvider.future);

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncError>()
                .having((d) => d.isLoading, "isLoading", isFalse)),
          ),
          listener.call(
            argThat(isA<AsyncError>()),
            argThat(isA<AsyncError>()
                .having((d) => d.isLoading, "isLoading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isTrue)
                .having((d) => d.isReloading, "isReloading", isFalse)),
          ),
          listener.call(
            argThat(isA<AsyncError>()),
            argThat(isA<AsyncData>()
                .having((d) => d.isLoading, "isLoading", isFalse)
                .having((d) => d.value, "value", ["result2"])),
          ),
        ]);
      });
    });

    group("successive search", () {
      test("data > data", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result1"],
        );
        final container = init();
        await container.read(searchResultProvider.future);

        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result2"],
        );
        container.read(searchWordProvider.notifier).state = "keyword2";
        await container.read(searchResultProvider.future);

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(
                isA<AsyncData>().having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncLoading>()
                .having((d) => d.isReloading, "isReloading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isFalse)
                .having((d) => d.hasValue, "hasValue", isTrue)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(
                isA<AsyncData>().having((d) => d.value, "value", ["result2"])),
          ),
        ]);
        verifyInOrder([
          mockUseCase.call("keyword"),
          mockUseCase.call("keyword2"),
        ]);
      });
      test("data > error", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result1"],
        );
        final container = init();
        await container.read(searchResultProvider.future);

        when(mockUseCase.call(any)).thenAnswer(
          (_) async => throw Exception("test"),
        );
        container.read(searchWordProvider.notifier).state = "keyword2";
        await expectLater(
          container.read(searchResultProvider.future),
          throwsException,
        );

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(
                isA<AsyncData>().having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncData>()),
            argThat(isA<AsyncLoading>()
                .having((d) => d.isReloading, "isReloading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isFalse)
                .having((d) => d.hasValue, "hasValue", isTrue)
                .having((d) => d.value, "value", ["result1"])),
          ),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncError>()
                .having((d) => d.hasValue, "hasValue", isTrue)
                .having((d) => d.value, "value", ["result1"])),
          ),
        ]);
        verifyInOrder([
          mockUseCase.call("keyword"),
          mockUseCase.call("keyword2"),
        ]);
      });

      test("error > data", () async {
        when(mockUseCase.call(any)).thenAnswer(
          (_) async => throw Exception("test"),
        );
        final container = init();
        await expectLater(
          container.read(searchResultProvider.future),
          throwsException,
        );

        when(mockUseCase.call(any)).thenAnswer(
          (_) async => ["result2"],
        );
        container.read(searchWordProvider.notifier).state = "keyword2";
        await container.read(searchResultProvider.future);

        verifyInOrder([
          listener.call(argThat(isNull), argThat(isA<AsyncLoading>())),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncError>()),
          ),
          listener.call(
            argThat(isA<AsyncError>()),
            argThat(isA<AsyncLoading>()
                .having((d) => d.isReloading, "isReloading", isTrue)
                .having((d) => d.isRefreshing, "isRefreshing", isFalse)
                .having((d) => d.hasError, "hasError", isTrue)),
          ),
          listener.call(
            argThat(isA<AsyncLoading>()),
            argThat(isA<AsyncData>()
                .having((d) => d.hasError, "hasError", isFalse)
                .having((d) => d.value, "value", ["result2"])),
          ),
        ]);
        verifyInOrder([
          mockUseCase.call("keyword"),
          mockUseCase.call("keyword2"),
        ]);
      });
    });
  });
}
