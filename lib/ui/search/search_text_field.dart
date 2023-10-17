import 'package:async_test_sample/ui/search/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchTextField extends HookConsumerWidget {
  const SearchTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: "keyword");
    onSubmit() {
      final keyword = controller.value.text;
      ref.read(searchWordProvider.notifier).state = keyword;
    }

    return IntrinsicHeight(
      // TextFieldとButtonの高さ揃える
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            // Buttonの横幅確保して残りの幅いっぱいまで広げる
            child: TextField(
              controller: controller,
              obscureText: false,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Put keyword",
              ),
              // キーボードのEnterでも検索できるようにする
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}
