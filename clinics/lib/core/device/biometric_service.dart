import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Desbloqueio por biometria ou senha do aparelho (recurso de dispositivo).
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// O aparelho tem biometria, PIN, padrão ou senha configurados?
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometria indisponível: $e');
      return false;
    }
  }

  /// Pede a biometria (ou a senha do aparelho). `false` se falhar ou for cancelado.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (e) {
      debugPrint('Falha na autenticação do aparelho: $e');
      return false;
    }
  }
}

final biometricServiceProvider = Provider((ref) => BiometricService());
