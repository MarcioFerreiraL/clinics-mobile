import 'package:dio/dio.dart';

class FieldError {
  final String field;
  final String message;

  const FieldError(this.field, this.message);
}

/// Erro da API (RFC 9457) já traduzido para o app.
class ApiException implements Exception {
  final int? status;
  final String code;
  final String message;
  final List<FieldError> fieldErrors;

  const ApiException({
    this.status,
    required this.code,
    required this.message,
    this.fieldErrors = const [],
  });

  bool get isUnauthenticated => code == 'UNAUTHENTICATED';

  String? fieldMessage(String field) {
    for (final e in fieldErrors) {
      if (e.field == field) return e.message;
    }
    return null;
  }

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['code'] is String) {
      final errors =
          (data['errors'] as List?)
              ?.whereType<Map>()
              .map((m) => FieldError('${m['field']}', '${m['message']}'))
              .toList() ??
          const <FieldError>[];
      final code = data['code'] as String;
      return ApiException(
        status: e.response?.statusCode,
        code: code,
        message: _messages[code] ?? (data['detail'] as String?) ?? _generic,
        fieldErrors: errors,
      );
    }
    final offline =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    return ApiException(
      status: e.response?.statusCode,
      code: offline ? 'NETWORK_ERROR' : 'UNKNOWN',
      message: offline
          ? 'Não foi possível conectar ao servidor. Verifique sua internet.'
          : _generic,
    );
  }

  static const _generic = 'Algo deu errado. Tente novamente.';

  static const _messages = {
    'INVALID_CREDENTIALS': 'Telefone ou senha incorretos.',
    'PHONE_ALREADY_REGISTERED': 'Este telefone já possui cadastro.',
    'INVALID_CPF': 'CPF inválido. Confira os números.',
    'CPF_ALREADY_REGISTERED': 'Este CPF já possui cadastro.',
    'INVALID_EMAIL': 'Informe um e-mail válido.',
    'INVALID_BIRTH_DATE': 'Data de nascimento inválida.',
    'INVALID_PHONE': 'Telefone inválido. Use DDD + número.',
    'WEAK_PASSWORD':
        'A senha deve ter 8 ou mais caracteres, com letras e números.',
    'UNAUTHENTICATED': 'Sua sessão expirou. Entre novamente.',
    'EXAM_NOT_FOUND': 'Exame não encontrado.',
    'CLINIC_NOT_FOUND': 'Clínica não encontrada.',
    'REVIEW_NOT_FOUND': 'Avaliação não encontrada.',
    'EMAIL_ALREADY_IN_USE': 'Este e-mail já está em uso.',
    'INVALID_CURRENT_PASSWORD': 'A senha atual está incorreta.',
    'SAME_PASSWORD': 'A nova senha deve ser diferente da atual.',
    'INVALID_AVATAR': 'Envie uma imagem JPEG ou PNG de até 2 MB.',
    'CLINIC_WITHOUT_WHATSAPP': 'Esta clínica não possui WhatsApp cadastrado.',
  };
}
