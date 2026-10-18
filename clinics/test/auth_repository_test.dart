import 'package:clinics/core/storage/token_storage.dart';
import 'package:clinics/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokenStorage extends TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

/// Servidor falso: login/cadastro devolvem só o resumo; `/me` devolve o perfil completo.
Dio _fakeApi() {
  final dio = Dio(BaseOptions(baseUrl: 'http://fake/api/v1'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        Response<Object> ok(Object data) =>
            Response(requestOptions: options, statusCode: 200, data: data);
        if (options.path == '/auth/register' || options.path == '/auth/login') {
          handler.resolve(
            ok({
              'token': 'abc',
              'user': {
                'id': '1',
                'full_name': 'Maria Silva',
                'phone': '(81) 99876-5432',
                'role': 'PATIENT',
              },
            }),
          );
        } else if (options.path == '/me') {
          handler.resolve(
            ok({
              'id': '1',
              'full_name': 'Maria Silva',
              'phone': '(81) 99876-5432',
              'role': 'PATIENT',
              'cpf': '529.982.247-25',
              'email': 'maria@email.com',
              'birth_date': '1990-05-20',
            }),
          );
        } else {
          handler.reject(DioException(requestOptions: options));
        }
      },
    ),
  );
  return dio;
}

void main() {
  test(
    'cadastro já devolve o perfil completo (CPF, e-mail e nascimento)',
    () async {
      final storage = _MemoryTokenStorage();
      final repo = AuthRepository(_fakeApi(), storage);

      final user = await repo.register(
        fullName: 'Maria Silva',
        phone: '81998765432',
        cpf: '52998224725',
        email: 'maria@email.com',
        birthDate: '1990-05-20',
        password: 'Senha1234',
      );

      expect(user.cpf, '529.982.247-25');
      expect(user.email, 'maria@email.com');
      expect(user.birthDate, DateTime(1990, 5, 20));
      expect(storage.token, 'abc');
    },
  );

  test('login também devolve o perfil completo', () async {
    final repo = AuthRepository(_fakeApi(), _MemoryTokenStorage());

    final user = await repo.login(phone: '81998765432', password: 'Senha1234');

    expect(user.cpf, isNotNull);
    expect(user.email, 'maria@email.com');
    expect(user.birthDate, isNotNull);
  });
}
