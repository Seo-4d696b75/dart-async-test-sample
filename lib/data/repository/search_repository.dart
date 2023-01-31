import 'dart:math';

import 'package:async_test_sample/data/model/search_result.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchRepositoryProvider = Provider(
  (_) => SearchRepository(0),
);

class SearchRepository {
  SearchRepository(int seed) : _random = Random(seed);

  final Random _random;

  Future<SearchResult> fetch(String keyword) async {
    // add calling API here, if needed
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (_random.nextDouble() < 0.2) {
      debugPrint("throw exception");
      throw Exception("test");
    }
    final size = max(_random.nextInt(20) - 5, 0);
    debugPrint("fetch success size: $size");
    return SearchResult(
      keyword: keyword,
      list: List.generate(size, (index) => "Result '$keyword'($index)"),
    );
  }
}
