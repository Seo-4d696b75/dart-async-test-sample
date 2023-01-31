import 'dart:async';

import 'package:async_test_sample/domain/usecase/search_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_view_model.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  SearchUseCase get searchWord => ref.read(searchUseCaseProvider);

  @override
  FutureOr<List<String>> build() async {
    return await searchWord("keyword");
  }

  Future<void> search(String keyword) async {
    final current = state;
    // 検索中はスキップ
    if (current.isLoading) return;
    // 検索中の状態
    // 直前の状態に表示できるデータがあれば表示し続ける
    state = const AsyncLoading<List<String>>().copyWithPrevious(current);

    // 検索実行
    final result = await AsyncValue.guard(() => searchWord(keyword));
    // 検索結果の反映
    // Error発生の直前に表示できるデータがあれば表示し続ける
    state = result.copyWithPrevious(current);
  }
}
