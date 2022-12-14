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
    if (current.isLoading) return;
    state = SearchState.loading(keyword: keyword);
    try {
      final result = await searchWord(keyword);
      state = SearchState.data(keyword: keyword, hits: result);
    } on Exception catch (e, stack) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      state = current;
    }
  }
}
