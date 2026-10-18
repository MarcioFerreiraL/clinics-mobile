import 'package:clinics/core/network/api_client.dart';
import 'package:clinics/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DioException error(
    DioExceptionType type, {
    Object? reason,
    Map<String, dynamic>? body,
    int? status,
  }) {
    final options = RequestOptions(path: '/x');
    return DioException(
      requestOptions: options,
      type: type,
      error: reason,
      response: body == null
          ? null
          : Response(requestOptions: options, data: body, statusCode: status),
    );
  }

  test('requisição que estoura o limite total vira erro de rede com mensagem amigável', () {
    final e = ApiException.fromDio(
      error(DioExceptionType.cancel, reason: deadlineMessage),
    );
    expect(e.code, 'NETWORK_ERROR');
    expect(e.message, contains('conectar'));
  });

  test('falha de conexão e timeouts do Dio também são erro de rede', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(ApiException.fromDio(error(type)).code, 'NETWORK_ERROR');
    }
  });

  test('erro da API (RFC 9457) usa o code e a mensagem em português', () {
    final e = ApiException.fromDio(
      error(
        DioExceptionType.badResponse,
        status: 401,
        body: {'code': 'INVALID_CREDENTIALS', 'detail': 'x'},
      ),
    );
    expect(e.code, 'INVALID_CREDENTIALS');
    expect(e.message, 'Telefone ou senha incorretos.');
  });

  test('erros de validação expõem a mensagem por campo', () {
    final e = ApiException.fromDio(
      error(
        DioExceptionType.badResponse,
        status: 400,
        body: {
          'code': 'VALIDATION_ERROR',
          'errors': [
            {'field': 'cpf', 'message': 'Informe seu CPF.'},
          ],
        },
      ),
    );
    expect(e.fieldMessage('cpf'), 'Informe seu CPF.');
    expect(e.fieldMessage('email'), isNull);
  });
}
