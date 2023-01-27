import 'package:hooks_riverpod/hooks_riverpod.dart';

extension ViewModelExt<T> on StateNotifier<T> {
  /// wait until the emitted state from [StateNotifier]'s stream
  /// is instanceOf the passed type param.
  ///
  /// Note: if no state change emitted, calling this will block forever!
  Future<void> waitUntil<S extends T>() async {
    await for (final state in stream) {
      if (state is S) break;
    }
  }
}
