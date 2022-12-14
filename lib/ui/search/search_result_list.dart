import 'package:async_test_sample/ui/search/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchResultList extends ConsumerWidget {
  const SearchResultList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchViewModelProvider);
    return state.map(
      empty: (_) => const _EmptyBody(),
      loading: (s) => _ListBody(results: s.previousHits, isLoading: true),
      data: (s) => _ListBody(results: s.hits),
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
            Icons.warning_amber_outlined,
            size: 80,
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
    this.isLoading = false,
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
