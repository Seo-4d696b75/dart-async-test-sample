import 'package:async_test_sample/data/model/search_result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchRepositoryProvider = Provider(
  (_) => SearchRepository(),
);

class SearchRepository {
  Future<SearchResult> fetch(String keyword) async {
    // add calling API here, if needed
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return SearchResult(
      keyword: keyword,
      list: List.generate(10, (index) => "'$keyword'の結果($index)"),
    );
  }
}
