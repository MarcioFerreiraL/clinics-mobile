import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/exam_detail.dart';

class ExamRepository {
  final Dio _dio;

  ExamRepository(this._dio);

  Future<ExamDetail> getExam(String id, {double? lat, double? lng}) async {
    try {
      final res = await _dio.get(
        '/exams/$id',
        queryParameters: {
          if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
        },
      );
      return ExamDetail.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Registra o contato e devolve o link do WhatsApp (UC07).
  Future<ContactResult> registerContact(String examId) async {
    try {
      final res = await _dio.post('/exams/$examId/contacts');
      return ContactResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final examRepositoryProvider = Provider(
  (ref) => ExamRepository(ref.watch(dioProvider)),
);

final examDetailProvider = FutureProvider.autoDispose
    .family<ExamDetail, String>(
      (ref, id) => ref.watch(examRepositoryProvider).getExam(id),
    );
