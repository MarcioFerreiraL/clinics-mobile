/// URL base da API. Em emulador Android use `http://10.0.2.2:8080`;
/// em aparelho físico, o IP da máquina na rede local.
class ApiConfig {
  static const String host = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String baseUrl = '$host/api/v1';

  /// Converte o caminho relativo de um arquivo (ex.: avatar) em URL completa.
  static String? fileUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$host${path.startsWith('/') ? '' : '/'}$path';
  }
}
