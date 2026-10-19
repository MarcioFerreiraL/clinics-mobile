import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class ClinicDashboard {
  final String clinicName;
  final int activeExams;
  final int examViews;
  final int whatsappClicks;
  final int periodDays;

  const ClinicDashboard({
    required this.clinicName,
    required this.activeExams,
    required this.examViews,
    required this.whatsappClicks,
    required this.periodDays,
  });

  factory ClinicDashboard.fromJson(Map<String, dynamic> json) =>
      ClinicDashboard(
        clinicName: json['clinic_name'] as String,
        activeExams: json['active_exams'] as int,
        examViews: json['exam_views'] as int,
        whatsappClicks: json['whatsapp_clicks'] as int,
        periodDays: json['period_days'] as int,
      );
}

class ClinicExamType {
  final String id;
  final String name;
  final String category;
  final String? description;

  const ClinicExamType({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  factory ClinicExamType.fromJson(Map<String, dynamic> json) => ClinicExamType(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    description: json['description'] as String?,
  );
}

class ManagedClinicExam {
  final String id;
  final ClinicExamType examType;
  final double price;
  final String? description;
  final String? preparation;
  final String? paymentMethods;
  final bool available;

  const ManagedClinicExam({
    required this.id,
    required this.examType,
    required this.price,
    this.description,
    this.preparation,
    this.paymentMethods,
    required this.available,
  });

  factory ManagedClinicExam.fromJson(Map<String, dynamic> json) =>
      ManagedClinicExam(
        id: json['id'] as String,
        examType: ClinicExamType.fromJson(
          json['exam_type'] as Map<String, dynamic>,
        ),
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String?,
        preparation: json['preparation'] as String?,
        paymentMethods: json['payment_methods'] as String?,
        available: json['available'] as bool,
      );
}

class ClinicManagementRepository {
  final Dio _dio;

  ClinicManagementRepository(this._dio);

  Future<ClinicDashboard> getDashboard() async {
    try {
      final response = await _dio.get('/clinic/me/dashboard');
      return ClinicDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<ClinicExamType>> getCatalog() async {
    try {
      final response = await _dio.get('/clinic/me/exam-catalog');
      return (response.data as List)
          .map(
            (item) => ClinicExamType.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<ManagedClinicExam>> getExams() async {
    try {
      final response = await _dio.get('/clinic/me/exams');
      final data = response.data as Map<String, dynamic>;
      return (data['exams'] as List)
          .map(
            (item) => ManagedClinicExam.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> saveExam({
    String? id,
    required String examTypeId,
    required double price,
    required String description,
    required String preparation,
    required String paymentMethods,
    required bool available,
  }) async {
    try {
      final data = {
        'exam_type_id': examTypeId,
        'price': price,
        'description': description,
        'preparation': preparation,
        'payment_methods': paymentMethods,
        'available': available,
      };
      if (id == null) {
        await _dio.post('/clinic/me/exams', data: data);
      } else {
        await _dio.put('/clinic/me/exams/$id', data: data);
      }
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> deactivateExam(String id) async {
    try {
      await _dio.delete('/clinic/me/exams/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

final clinicManagementRepositoryProvider = Provider(
  (ref) => ClinicManagementRepository(ref.watch(dioProvider)),
);

final clinicDashboardProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(clinicManagementRepositoryProvider).getDashboard(),
);

final clinicExamCatalogProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(clinicManagementRepositoryProvider).getCatalog(),
);

final managedClinicExamsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(clinicManagementRepositoryProvider).getExams(),
);
