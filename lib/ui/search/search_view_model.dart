import 'package:async_test_sample/model/search_usecase.dart';
import 'package:async_test_sample/ui/search/search_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>(
  (ref) => SearchViewModel(
    ref.watch(searchUseCaseProvider),
  ),
);

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this.searchWord) : super(const SearchState.empty());

  final SearchUseCase searchWord;

  Future<void> search(String keyword) async {
    state = SearchState.loading(keyword: keyword);
    final result = await searchWord();
    state = SearchState.data(keyword: keyword, hits: result);
  }
}
