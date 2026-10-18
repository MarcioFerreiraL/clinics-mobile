/// URL base da API. O padrão é a produção (Cloudflare Tunnel, HTTPS).
/// Para desenvolvimento, sobrescreva com `--dart-define=API_BASE_URL=...`:
/// emulador Android `http://10.0.2.2:8080`; aparelho físico, o IP da máquina na rede local.
class ApiConfig {
  static const String host = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://clinics.marciodev.com',
  );

  static const String baseUrl = '$host/api/v1';

  /// Converte o caminho relativo de um arquivo (ex.: avatar) em URL completa.
  static String? fileUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$host${path.startsWith('/') ? '' : '/'}$path';
  }
}
