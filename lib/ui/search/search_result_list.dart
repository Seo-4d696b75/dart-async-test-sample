import 'package:async_test_sample/ui/search/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchResultList extends HookConsumerWidget {
  const SearchResultList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchResultProvider);

    final messenger = ScaffoldMessenger.of(context);

    useEffect(() {
      if (state.hasError &&
          state.hasValue &&
          state.requireValue.isNotEmpty &&
          !state.isLoading) {
        Future.microtask(() {
          const snackBar = SnackBar(
            content: Text("Error, please retry."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          );
          messenger.showSnackBar(snackBar);
        });
      }
      return null;
    }, [state]);

    return state.mapWithList(
      firstLoading: () => const _FirstLoadingBody(),
      error: (_) => const _ErrorBody(),
      empty: () => const _EmptyBody(),
      list: (list, isLoading) => _ListBody(results: list, isLoading: isLoading),
    );
  }
}

extension MapWithListExtension<E> on AsyncValue<List<E>> {
  R mapWithList<R>({
    required R Function() firstLoading,
    required R Function(Object) error,
    required R Function() empty,
    required R Function(List<E>, bool) list,
  }) {
    if (hasValue && requireValue.isNotEmpty) {
      return list(requireValue, isLoading);
    }
    if (isLoading) {
      return firstLoading();
    }
    if (hasError) {
      return error(this.error!);
    }
    return empty();
  }
}

class _FirstLoadingBody extends StatelessWidget {
  const _FirstLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          Text("Error"),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Colors.blueGrey,
          ),
          Text("No Result"),
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.results,
    required this.isLoading,
  });

  final List<String> results;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final result = results[index];
                  return Card(
                    child: ListTile(
                      title: Text(result),
                    ),
                  );
                },
                childCount: results.length,
              ),
            ),
          ],
        ),
        Visibility(
          visible: isLoading,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
