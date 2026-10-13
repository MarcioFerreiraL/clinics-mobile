import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/user_profile.dart';

/// Sessão do usuário: `null` significa visitante.
class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    ref.read(sessionEventsProvider).onExpired = () => state = const AsyncData(null);
    try {
      return await ref.read(authRepositoryProvider).restoreSession();
    } catch (_) {
      // Sem rede ao abrir o app: segue como visitante.
      return null;
    }
  }

  Future<void> login(String phone, String password) async {
    final user = await ref
        .read(authRepositoryProvider)
        .login(phone: phone, password: password);
    state = AsyncData(user);
  }

  Future<void> register(String fullName, String phone, String password) async {
    final user = await ref
        .read(authRepositoryProvider)
        .register(fullName: fullName, phone: phone, password: password);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Atualiza o perfil em memória depois de editar dados ou foto.
  void setUser(UserProfile user) => state = AsyncData(user);
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);
