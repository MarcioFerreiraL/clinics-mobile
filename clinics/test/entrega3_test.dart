import 'package:clinics/core/storage/token_storage.dart';
import 'package:clinics/features/auth/data/auth_repository.dart';
import 'package:clinics/features/exam/data/exam_repository.dart';
import 'package:clinics/features/profile/data/profile_repository.dart';
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

/// Servidor falso que guarda o que o app enviou, para conferir o corpo das chamadas.
class _Fake {
  final calls = <String, Object?>{};

  Dio dio() {
    final dio = Dio(BaseOptions(baseUrl: 'http://fake/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls['${options.method} ${options.path}'] = options.data;
          Response<Object> ok(Object? data, [int code = 200]) =>
              Response(requestOptions: options, statusCode: code, data: data);
          switch ('${options.method} ${options.path}') {
            case 'GET /exams/e1/price-history':
              handler.resolve(
                ok([
                  {'price': 90.0, 'recorded_at': '2026-11-20T12:00:00Z'},
                  {'price': 95, 'recorded_at': '2026-10-20T12:00:00Z'},
                ]),
              );
            case 'GET /me/data':
              handler.resolve(ok({'profile': {'id': '1'}}));
            case 'POST /auth/register':
              handler.resolve(
                ok({
                  'token': 't',
                  'user': {
                    'id': '1',
                    'full_name': 'Maria',
                    'phone': '(81) 99876-5432',
                    'role': 'PATIENT',
                  },
                }),
              );
            case 'GET /me':
              handler.resolve(
                ok({
                  'id': '1',
                  'full_name': 'Maria',
                  'phone': '(81) 99876-5432',
                  'role': 'PATIENT',
                }),
              );
            default:
              handler.resolve(ok(null, 204));
          }
        },
      ),
    );
    return dio;
  }
}

void main() {
  test('recuperar senha: pede o código e redefine com o código', () async {
    final fake = _Fake();
    final repo = AuthRepository(fake.dio(), _MemoryTokenStorage());

    await repo.forgotPassword('81998765432');
    await repo.resetPassword('123456', 'NovaSenha99');

    expect(fake.calls['POST /auth/forgot-password'], {'phone': '81998765432'});
    expect(fake.calls['POST /auth/reset-password'], {
      'code': '123456',
      'new_password': 'NovaSenha99',
    });
  });

  test('cadastro envia o aceite dos termos (LGPD)', () async {
    final fake = _Fake();
    final repo = AuthRepository(fake.dio(), _MemoryTokenStorage());

    await repo.register(
      fullName: 'Maria',
      phone: '81998765432',
      cpf: '52998224725',
      email: 'maria@email.com',
      birthDate: '1990-05-20',
      password: 'Senha1234',
      acceptedTerms: true,
    );

    final body = fake.calls['POST /auth/register']! as Map;
    expect(body['accepted_terms'], true);
  });

  test('histórico de preço vem do mais recente para o mais antigo', () async {
    final repo = ExamRepository(_Fake().dio());

    final points = await repo.priceHistory('e1');

    expect(points.length, 2);
    expect(points.first.price, 90.0);
    expect(points.last.price, 95.0);
    expect(points.first.recordedAt.isAfter(points.last.recordedAt), isTrue);
  });

  test('exportar dados devolve JSON legível e excluir envia a senha', () async {
    final fake = _Fake();
    final repo = ProfileRepository(fake.dio());

    final json = await repo.exportData();
    await repo.deleteAccount('Senha1234');

    expect(json, contains('"profile"'));
    expect(fake.calls['DELETE /me'], {'password': 'Senha1234'});
  });
}
