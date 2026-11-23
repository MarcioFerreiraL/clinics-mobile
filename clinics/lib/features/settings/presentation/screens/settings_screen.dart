import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/device/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../search/presentation/widgets/neighborhood_picker.dart';
import '../../data/preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final service = ref.read(biometricServiceProvider);
    if (enable) {
      final messenger = ScaffoldMessenger.of(context);
      if (!await service.isAvailable()) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Configure biometria ou senha de tela no aparelho.'),
          ),
        );
        return;
      }
      // Confirma uma vez antes de ligar, para não trancar o usuário fora.
      if (!await service.authenticate('Confirme para ativar a biometria')) {
        return;
      }
    }
    await ref.read(biometricLockProvider.notifier).set(enable);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final neighborhood = ref.watch(selectedNeighborhoodProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context, 'CONTA'),
          _card([
            if (user != null) ...[
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                title: const Text('Meu perfil'),
                subtitle: Text(user.fullName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                ),
                title: const Text('Exames favoritos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/favorites'),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.login, color: AppColors.primary),
                title: const Text('Entrar ou criar conta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/login'),
              ),
          ]),
          const SizedBox(height: 20),
          _header(context, 'PREFERÊNCIAS'),
          _card([
            ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Meu bairro'),
              subtitle: Text(neighborhood ?? 'Todos os bairros'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showNeighborhoodPicker(context),
            ),
            if (user != null)
              SwitchListTile(
                secondary: const Icon(
                  Icons.fingerprint,
                  color: AppColors.primary,
                ),
                title: const Text('Entrar com biometria'),
                subtitle: const Text(
                  'Pede digital, rosto ou senha do aparelho ao abrir o app',
                ),
                value: ref.watch(biometricLockProvider),
                onChanged: (v) => _toggleBiometric(context, ref, v),
              ),
          ]),
          const SizedBox(height: 20),
          _header(context, 'SOBRE'),
          _card([
            const ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: Text('Clinics'),
              subtitle: Text('Versão 1.0.0 • Compare exames em Surubim, PE'),
            ),
            const ListTile(
              leading: Icon(Icons.code, color: AppColors.primary),
              title: Text('Desenvolvido por'),
              subtitle: Text('MárcioDev e Lucas'),
            ),
          ]),
          if (user != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sair da conta'),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.0,
        fontWeight: FontWeight.w700,
        color: AppColors.slateSecondary,
      ),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderOutline),
    ),
    child: Column(children: children),
  );
}
