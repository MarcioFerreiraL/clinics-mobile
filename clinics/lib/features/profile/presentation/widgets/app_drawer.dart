import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).value;
    final avatar = ApiConfig.fileUrl(user?.avatarUrl);

    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.atmosphericBlueLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderOutline),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.atmosphericBlue,
                        backgroundImage: avatar == null ? null : NetworkImage(avatar),
                        child: avatar == null
                            ? const Icon(Icons.person, size: 32, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Visitante',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.phone ?? 'Entre para favoritar e avaliar',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.atmosphericBlue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                user == null ? 'Visitante' : 'Paciente',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderOutline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Surubim, PE • Centro',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slateDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    title: 'Início',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.search,
                    title: 'Buscar e Comparar',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/search');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.favorite_border,
                    title: 'Exames Favoritos',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/favorites');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Meu Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  const Divider(
                    color: AppColors.borderOutline,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Ajuda & Suporte',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Suporte Clinics: contato@clinics.com.br',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer / Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: AppColors.surfaceMuted,
                    leading: Icon(
                      user == null ? Icons.login : Icons.logout,
                      color: user == null ? AppColors.primary : AppColors.error,
                    ),
                    title: Text(
                      user == null ? 'Entrar' : 'Sair da Conta',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: user == null ? AppColors.primary : AppColors.error,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Clinics v1.0.0 • Surubim, PE',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 11),
            )
          : null,
      onTap: onTap,
    );
  }
}
