import 'package:dio/dio.dart';

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/device/notification_service.dart';
import '../../../core/network/api_exception.dart';
import '../../search/domain/money.dart';
import '../../settings/data/preferences.dart';
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
    final items = await ref.read(favoritesRepositoryProvider).list();
    await _notifyPriceDrops(user.id, items);
    return items;
  }

  /// Compara o menor preço atual com o último visto e avisa se caiu.
  Future<void> _notifyPriceDrops(
    String userId,
    List<FavoriteExam> items,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'favorite_prices_$userId';
      final known = (jsonDecode(prefs.getString(key) ?? '{}') as Map)
          .cast<String, num>();
      for (final f in items) {
        final previous = known[f.examTypeId];
        if (ref.read(priceAlertsProvider) &&
            previous != null &&
            f.minPrice < previous) {
          await ref
              .read(notificationServiceProvider)
              .showPriceDrop(
                id: f.examTypeId.hashCode & 0x7fffffff,
                examName: f.name,
                newPrice: formatPrice(f.minPrice),
              );
        }
      }
      await prefs.setString(
        key,
        jsonEncode({for (final f in items) f.examTypeId: f.minPrice}),
      );
    } catch (_) {
      // Alertas são opcionais: falha aqui não deve afetar a lista.
    }
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
