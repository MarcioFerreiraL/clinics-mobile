import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/favorite_exam.dart';

class FavoritesRepository {
  final Dio _dio;

  FavoritesRepository(this._dio);

  Future<List<FavoriteExam>> list() async {
    try {
      final res = await _dio.get(
        '/me/favorites',
        queryParameters: {'size': 50},
      );
      return (res.data['data'] as List)
          .map((e) => FavoriteExam.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> set(String examTypeId, {required bool favorite}) async {
    try {
      final path = '/me/favorites/$examTypeId';
      favorite ? await _dio.put(path) : await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final favoritesRepositoryProvider = Provider(
  (ref) => FavoritesRepository(ref.watch(dioProvider)),
);

/// Favoritos do paciente logado (vazio para visitante).
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteExam>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends AsyncNotifier<List<FavoriteExam>> {
  @override
  Future<List<FavoriteExam>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];
    return ref.read(favoritesRepositoryProvider).list();
  }

  bool isFavorite(String examTypeId) =>
      state.value?.any((f) => f.examTypeId == examTypeId) ?? false;

  Future<void> toggle(String examTypeId) async {
    final favorite = !isFavorite(examTypeId);
    await ref
        .read(favoritesRepositoryProvider)
        .set(examTypeId, favorite: favorite);
    ref.invalidateSelf();
    await future;
  }
}
