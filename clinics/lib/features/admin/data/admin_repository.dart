import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Conta interna listada em `GET /admin/accounts`.
class AdminAccount {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String? position;
  final String? clinicId;
  final String? clinicName;

  const AdminAccount({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.position,
    this.clinicId,
    this.clinicName,
  });

  factory AdminAccount.fromJson(Map<String, dynamic> json) => AdminAccount(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: (json['phone'] as String?) ?? '',
    role: json['role'] as String,
    position: json['position'] as String?,
    clinicId: json['clinic_id'] as String?,
    clinicName: json['clinic_name'] as String?,
  );
}

/// Cargo com as chaves de permissão concedidas (`GET /admin/positions`).
class AdminPosition {
  final String id;
  final String name;
  final String visibilityScope;
  final List<String> permissions;

  const AdminPosition({
    required this.id,
    required this.name,
    required this.visibilityScope,
    this.permissions = const [],
  });

  factory AdminPosition.fromJson(Map<String, dynamic> json) => AdminPosition(
    id: json['id'] as String,
    name: json['name'] as String,
    visibilityScope: json['visibility_scope'] as String,
    permissions: (json['permissions'] as List? ?? const [])
        .map((e) => e as String)
        .toList(),
  );

  /// Cargo que enxerga todas as clínicas não precisa de clínica vinculada.
  bool get seesAllClinics => visibilityScope == 'all';
}

class AdminPermission {
  final String id;
  final String key;
  final String label;

  const AdminPermission({
    required this.id,
    required this.key,
    required this.label,
  });

  factory AdminPermission.fromJson(Map<String, dynamic> json) =>
      AdminPermission(
        id: json['id'] as String,
        key: json['key'] as String,
        label: json['label'] as String,
      );
}

class AdminMatrix {
  final List<AdminPosition> positions;
  final List<AdminPermission> permissions;

  const AdminMatrix({required this.positions, required this.permissions});

  factory AdminMatrix.fromJson(Map<String, dynamic> json) => AdminMatrix(
    positions: (json['positions'] as List? ?? const [])
        .map((e) => AdminPosition.fromJson(e as Map<String, dynamic>))
        .toList(),
    permissions: (json['permissions'] as List? ?? const [])
        .map((e) => AdminPermission.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<List<AdminAccount>> accounts() async {
    try {
      final res = await _dio.get('/admin/accounts');
      return (res.data as List)
          .map((e) => AdminAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AdminMatrix> matrix() async {
    try {
      final res = await _dio.get('/admin/positions');
      return AdminMatrix.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> changePosition(
    String userId,
    String positionId, {
    String? clinicId,
  }) async {
    try {
      await _dio.put(
        '/admin/accounts/$userId/position',
        data: {'position_id': positionId, 'clinic_id': clinicId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> setPermission(
    String positionId,
    String permissionId, {
    required bool granted,
  }) async {
    final path = '/admin/positions/$positionId/permissions/$permissionId';
    try {
      if (granted) {
        await _dio.put(path);
      } else {
        await _dio.delete(path);
      }
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final adminRepositoryProvider = Provider(
  (ref) => AdminRepository(ref.watch(dioProvider)),
);

final adminAccountsProvider = FutureProvider.autoDispose<List<AdminAccount>>(
  (ref) => ref.watch(adminRepositoryProvider).accounts(),
);

final adminMatrixProvider = FutureProvider.autoDispose<AdminMatrix>(
  (ref) => ref.watch(adminRepositoryProvider).matrix(),
);
