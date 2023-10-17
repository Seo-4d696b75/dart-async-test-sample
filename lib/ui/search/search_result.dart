import 'package:async_test_sample/domain/usecase/search_usecase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_result.g.dart';

final searchWordProvider = StateProvider((ref) => 'keyword');

@riverpod
class SearchResult extends _$SearchResult {
  SearchUseCase get searchWord => ref.read(searchUseCaseProvider);

  @override
  FutureOr<List<String>> build() async {
    final word = ref.watch(searchWordProvider);
    return await searchWord(word);
  }
}
