import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../search/domain/exam_offer.dart';
import '../domain/clinic_detail.dart';

class ClinicRepository {
  final Dio _dio;

  ClinicRepository(this._dio);

  Future<ClinicDetail> getClinic(String id) async {
    try {
      final res = await _dio.get('/clinics/$id');
      return ClinicDetail.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Page<Review>> getReviews(String clinicId, {int page = 0}) async {
    try {
      final res = await _dio.get(
        '/clinics/$clinicId/reviews',
        queryParameters: {'page': page, 'size': 20},
      );
      return Page.fromJson(res.data as Map<String, dynamic>, Review.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Minha avaliação da clínica, ou null se ainda não avaliei.
  Future<Review?> getMyReview(String clinicId) async {
    try {
      final res = await _dio.get('/clinics/$clinicId/reviews/me');
      return Review.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = ApiException.fromDio(e);
      if (error.code == 'REVIEW_NOT_FOUND') return null;
      throw error;
    }
  }

  Future<void> saveMyReview(
    String clinicId,
    int rating,
    String? comment,
  ) async {
    try {
      await _dio.put(
        '/clinics/$clinicId/reviews/me',
        data: {
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final clinicRepositoryProvider = Provider(
  (ref) => ClinicRepository(ref.watch(dioProvider)),
);

final clinicDetailProvider = FutureProvider.autoDispose
    .family<ClinicDetail, String>(
      (ref, id) => ref.watch(clinicRepositoryProvider).getClinic(id),
    );

final clinicReviewsProvider = FutureProvider.autoDispose
    .family<Page<Review>, String>(
      (ref, id) => ref.watch(clinicRepositoryProvider).getReviews(id),
    );
