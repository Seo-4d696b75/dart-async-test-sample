import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.empty() = SearchStateEmpty;

  const factory SearchState.loading({
    required String keyword,
  }) = SearchStateLoading;

  const factory SearchState.data({
    required String keyword,
    required List<String> hits,
  }) = SearchStateData;

  const SearchState._();

  bool get isLoading => this is SearchStateLoading;
}
