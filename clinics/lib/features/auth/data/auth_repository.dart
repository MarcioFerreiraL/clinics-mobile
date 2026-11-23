import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/entities/user_profile.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserProfile> login({
    required String phone,
    required String password,
  }) => _authenticate('/auth/login', {'phone': phone, 'password': password});

  Future<UserProfile> register({
    required String fullName,
    required String phone,
    required String cpf,
    required String email,
    required String birthDate,
    required String password,
    required bool acceptedTerms,
  }) => _authenticate('/auth/register', {
    'full_name': fullName,
    'phone': phone,
    'cpf': cpf,
    'email': email,
    'birth_date': birthDate,
    'password': password,
    'accepted_terms': acceptedTerms,
  });

  /// Recupera a sessão salva; devolve null se não houver token válido.
  Future<UserProfile?> restoreSession() async {
    if (await _storage.read() == null) return null;
    try {
      final res = await _dio.get('/me');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = ApiException.fromDio(e);
      if (error.code == 'NETWORK_ERROR') rethrow;
      await _storage.clear();
      return null;
    }
  }

  /// Pede o código de redefinição; a resposta é igual exista ou não a conta.
  Future<void> forgotPassword(String phone) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> resetPassword(String code, String newPassword) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'code': code, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout() => _storage.clear();

  Future<UserProfile> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _dio.post(path, data: body);
      final data = res.data as Map<String, dynamic>;
      await _storage.save(data['token'] as String);
      final summary = UserProfile.fromJson(
        data['user'] as Map<String, dynamic>,
      );
      // A resposta de login/cadastro traz só um resumo (sem CPF, e-mail e nascimento):
      // busca o perfil completo para o app já abrir com todos os dados.
      try {
        final me = await _dio.get('/me');
        return UserProfile.fromJson(me.data as Map<String, dynamic>);
      } on DioException {
        return summary;
      }
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final authRepositoryProvider = Provider(
  (ref) =>
      AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider)),
);
