import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/entities/user_profile.dart';
import '../domain/savings.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserProfile> updateProfile({
    required String fullName,
    String? email,
    DateTime? birthDate,
  }) => _call(() async {
    final res = await _dio.put(
      '/me',
      data: {
        'full_name': fullName,
        'email': email ?? '',
        if (birthDate != null)
          'birth_date': birthDate.toIso8601String().substring(0, 10),
      },
    );
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  });

  Future<UserProfile> uploadAvatar(String path) => _call(() async {
    final isPng = path.toLowerCase().endsWith('.png');
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: isPng ? 'avatar.png' : 'avatar.jpg',
        contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
      ),
    });
    final res = await _dio.put('/me/avatar', data: form);
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  });

  Future<void> changePassword(String current, String next) => _call(
    () => _dio.put(
      '/me/password',
      data: {'current_password': current, 'new_password': next},
    ),
  );

  Future<Savings> savings() => _call(() async {
    final res = await _dio.get('/me/savings');
    return Savings.fromJson(res.data as Map<String, dynamic>);
  });
}

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);

final savingsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(profileRepositoryProvider).savings(),
);
