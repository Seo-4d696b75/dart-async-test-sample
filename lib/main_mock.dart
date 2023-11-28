import 'package:async_test_sample/data/model/search_result.dart';
import 'package:async_test_sample/data/repository/search_repository.dart';
import 'package:async_test_sample/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        searchRepositoryProvider.overrideWithValue(const MockSearchRepository())
      ],
      child: const MyApp(),
    ),
  );
}

class MockSearchRepository implements SearchRepository {
  const MockSearchRepository();

  @override
  Future<SearchResult> fetch(String keyword) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (keyword == 'error') {
      throw Exception('test');
    } else if (keyword == 'hoge') {
      return SearchResult(
        keyword: keyword,
        list: [
          'hoge',
          'fuga',
          'piyo',
        ],
      );
    } else if (keyword == 'more') {
      return SearchResult(
        keyword: keyword,
        list: List.generate(20, (index) => '${index + 1}'),
      );
    } else {
      return SearchResult(
        keyword: keyword,
        list: [],
      );
    }
  }
}
