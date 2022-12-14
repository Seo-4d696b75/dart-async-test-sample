import 'package:async_test_sample/data/repository/search_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchUseCaseProvider = Provider(
  (ref) => SearchUseCase(ref.watch(searchRepositoryProvider)),
);

class SearchUseCase {
  SearchUseCase(this.repository);

  final SearchRepository repository;

  Future<List<String>> call(String keyword) async {
    final result = await repository.fetch(keyword);
    return result.list;
  }
}
