import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchUseCaseProvider = Provider(
  (_) => SearchUseCase(),
);

class SearchUseCase {
  Future<List<String>> call() async {
    // 何らかの実装
    throw UnimplementedError();
  }
}
