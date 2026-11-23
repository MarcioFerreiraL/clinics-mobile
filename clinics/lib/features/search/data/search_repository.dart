import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/exam_offer.dart';
import '../domain/search_filters.dart';

class SearchQuery {
  final String query;
  final String category;
  final String sortBy;
  final SearchFilters filters;

  const SearchQuery({
    this.query = '',
    this.category = 'Todos',
    this.sortBy = 'price',
    this.filters = SearchFilters.none,
  });

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.query == query &&
      other.category == category &&
      other.sortBy == sortBy &&
      other.filters == filters;

  @override
  int get hashCode => Object.hash(query, category, sortBy, filters);

  Map<String, dynamic> toParams(int page) => {
    if (query.trim().isNotEmpty) 'query': query.trim(),
    if (category != 'Todos') 'category': category,
    'sort_by': sortBy,
    ...filters.toParams(),
    'page': page,
    'size': 50,
  };
}

class SearchRepository {
  final Dio _dio;

  SearchRepository(this._dio);

  Future<Page<ExamOffer>> search(SearchQuery query, {int page = 0}) async {
    try {
      final res = await _dio.get(
        '/exams/search',
        queryParameters: query.toParams(page),
      );
      return Page.fromJson(
        res.data as Map<String, dynamic>,
        ExamOffer.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final searchRepositoryProvider = Provider(
  (ref) => SearchRepository(ref.watch(dioProvider)),
);

class Neighborhood {
  final String name;
  final int clinicsCount;

  const Neighborhood(this.name, this.clinicsCount);
}

final neighborhoodsProvider = FutureProvider.autoDispose<List<Neighborhood>>((
  ref,
) async {
  try {
    final res = await ref.watch(dioProvider).get('/neighborhoods');
    return (res.data as List)
        .map(
          (e) => Neighborhood(e['name'] as String, e['clinics_count'] as int),
        )
        .toList();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
});

final searchResultsProvider = FutureProvider.autoDispose
    .family<Page<ExamOffer>, SearchQuery>(
      (ref, query) => ref.watch(searchRepositoryProvider).search(query),
    );
