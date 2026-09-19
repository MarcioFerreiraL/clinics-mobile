import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maria Silva',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '(81) 99876-5432',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.atmosphericBlue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Paciente',
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderOutline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.primary),
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
                    icon: Icons.local_hospital_outlined,
                    title: 'Clínicas Parceiras',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/clinic/clinic-1');
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
                  const Divider(color: AppColors.borderOutline, indent: 16, endIndent: 16),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Painel da Clínica (Gestão)',
                    subtitle: 'Acesso do gestor da clínica',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Acesso ao Painel da Clínica (Gestor).'),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Ajuda & Suporte',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Suporte Clinics: contato@clinics.com.br'),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: AppColors.surfaceMuted,
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      'Sair da Conta',
                      style: theme.textTheme.labelLarge?.copyWith(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/login');
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            )
          : null,
      onTap: onTap,
    );
  }
}
