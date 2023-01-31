import 'package:async_test_sample/ui/search/search_result_list.dart';
import 'package:async_test_sample/ui/search/search_text_field.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TestSampleApp"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: const [
            SearchTextField(),
            SizedBox(height: 20),
            Expanded(
              child: SearchResultList(),
            ),
          ],
        ),
      ),
    );
  }
}
