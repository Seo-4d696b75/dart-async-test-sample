import 'package:async_test_sample/domain/usecase/search_usecase.dart';
import 'package:async_test_sample/ui/search/search_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchViewModelProvider =
    StateNotifierProvider.autoDispose<SearchViewModel, SearchState>(
  (ref) => SearchViewModel(
    ref.watch(searchUseCaseProvider),
  ),
);

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this.searchWord) : super(const SearchState.empty());

  final SearchUseCase searchWord;

  Future<void> search(String keyword) async {
    final current = state;
    // 検索中はスキップ
    if (current.isLoading) return;
    // 検索中の状態
    state = current.map(
      empty: (_) => SearchState.loading(keyword: keyword, previousHits: []),
      data: (s) => SearchState.loading(keyword: keyword, previousHits: s.hits),
      loading: (_) => throw AssertionError(),
    );
    try {
      // 検索実行
      final result = await searchWord(keyword);
      // 検索結果の反映
      if (result.isEmpty) {
        state = const SearchState.empty();
      } else {
        state = SearchState.data(hits: result);
      }
    } on Exception catch (e, stack) {
      // エラーハンドリング
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      state = current;
    }
  }
}
