import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/exam_detail.dart';

class ExamRepository {
  final Dio _dio;

  ExamRepository(this._dio);

  Future<ExamDetail> getExam(String id) async {
    try {
      final res = await _dio.get('/exams/$id');
      return ExamDetail.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Últimas mudanças de preço da oferta, da mais recente para a mais antiga.
  Future<List<PricePoint>> priceHistory(String id) async {
    try {
      final res = await _dio.get('/exams/$id/price-history');
      return (res.data as List)
          .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Pede o link do WhatsApp da clínica com a mensagem pronta.
  Future<ContactResult> whatsappLink(String examId) async {
    try {
      final res = await _dio.post('/exams/$examId/contacts');
      return ContactResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class PricePoint {
  final double price;
  final DateTime recordedAt;

  const PricePoint(this.price, this.recordedAt);

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
    double.parse('${json['price']}'),
    DateTime.parse(json['recorded_at'] as String).toLocal(),
  );
}

final examRepositoryProvider = Provider(
  (ref) => ExamRepository(ref.watch(dioProvider)),
);

final examDetailProvider = FutureProvider.autoDispose
    .family<ExamDetail, String>(
      (ref, id) => ref.watch(examRepositoryProvider).getExam(id),
    );

final priceHistoryProvider = FutureProvider.autoDispose
    .family<List<PricePoint>, String>(
      (ref, id) => ref.watch(examRepositoryProvider).priceHistory(id),
    );
