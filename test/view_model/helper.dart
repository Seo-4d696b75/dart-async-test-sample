import 'package:async_test_sample/ui/search/search_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class StateListener {
  void call(SearchState state);
}

extension ViewModelExt<T> on StateNotifier<T> {
  Future<void> waitUntil<S extends T>() async {
    await for (final state in stream) {
      if (state is S) break;
    }
  }
}
