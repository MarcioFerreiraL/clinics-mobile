import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/exam_offer.dart';

class SearchQuery {
  final String query;
  final String category;
  final String sortBy;
  final double? lat;
  final double? lng;

  const SearchQuery({
    this.query = '',
    this.category = 'Todos',
    this.sortBy = 'price',
    this.lat,
    this.lng,
  });

  SearchQuery copyWith({
    String? query,
    String? category,
    String? sortBy,
    double? lat,
    double? lng,
  }) =>
      SearchQuery(
        query: query ?? this.query,
        category: category ?? this.category,
        sortBy: sortBy ?? this.sortBy,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.query == query &&
      other.category == category &&
      other.sortBy == sortBy &&
      other.lat == lat &&
      other.lng == lng;

  @override
  int get hashCode => Object.hash(query, category, sortBy, lat, lng);

  Map<String, dynamic> toParams(int page) => {
        if (query.trim().isNotEmpty) 'query': query.trim(),
        if (category != 'Todos') 'category': category,
        'sort_by': sortBy,
        if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
        'page': page,
        'size': 50,
      };
}

class SearchRepository {
  final Dio _dio;

  SearchRepository(this._dio);

  Future<Page<ExamOffer>> search(SearchQuery query, {int page = 0}) async {
    try {
      final res = await _dio.get('/exams/search', queryParameters: query.toParams(page));
      return Page.fromJson(res.data as Map<String, dynamic>, ExamOffer.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<TrendingExam>> trending() async {
    try {
      final res = await _dio.get('/exam-types/trending');
      return (res.data as List)
          .map((e) => TrendingExam.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final searchRepositoryProvider =
    Provider((ref) => SearchRepository(ref.watch(dioProvider)));

final searchResultsProvider =
    FutureProvider.autoDispose.family<Page<ExamOffer>, SearchQuery>(
  (ref, query) => ref.watch(searchRepositoryProvider).search(query),
);

final trendingProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(searchRepositoryProvider).trending(),
);
