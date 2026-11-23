import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Papel, cargo e permissões da conta logada (`GET /me/access`).
class Access {
  final String role;
  final String? position;
  final String? clinicId;
  final List<String> permissions;

  const Access({
    required this.role,
    this.position,
    this.clinicId,
    this.permissions = const [],
  });

  factory Access.fromJson(Map<String, dynamic> json) => Access(
    role: json['role'] as String,
    position: json['position'] as String?,
    clinicId: json['clinic_id'] as String?,
    permissions: (json['permissions'] as List? ?? const [])
        .map((e) => e as String)
        .toList(),
  );

  /// Conta interna (gerente, atendente ou administrador). Paciente não tem cargo.
  bool get isInternal => role != 'PATIENT' || position != null;

  /// O servidor decide de verdade; o app só usa isto para esconder menus e botões.
  bool can(String permission) => permissions.contains(permission);
}

class AccessRepository {
  final Dio _dio;

  AccessRepository(this._dio);

  Future<Access> me() async {
    try {
      final res = await _dio.get('/me/access');
      return Access.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final accessRepositoryProvider = Provider(
  (ref) => AccessRepository(ref.watch(dioProvider)),
);

/// Acesso da conta logada; `null` para visitante ou se não der para consultar.
final accessProvider = FutureProvider<Access?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  try {
    return await ref.read(accessRepositoryProvider).me();
  } catch (_) {
    return null;
  }
});
