import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações de conta.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.atmosphericBlue,
                        child: Icon(Icons.person, size: 44, color: AppColors.primary),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Maria da Silva',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(81) 99876-5432 • maria.silva@email.com',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.atmosphericBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Paciente Cadastrado',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Information
            _buildSectionHeader(context, 'DADOS DA CONTA'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.badge_outlined,
                    label: 'Nome Completo',
                    value: 'Maria da Silva',
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderOutline),
                  _buildProfileTile(
                    icon: Icons.phone_android,
                    label: 'WhatsApp',
                    value: '(81) 99876-5432',
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderOutline),
                  _buildProfileTile(
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    value: 'maria.silva@email.com',
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderOutline),
                  _buildProfileTile(
                    icon: Icons.location_city,
                    label: 'Cidade de Referência',
                    value: 'Surubim, PE',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Preferences
            _buildSectionHeader(context, 'PREFERÊNCIAS'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none, color: AppColors.primary),
                    title: const Text('Notificações de Preços', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Receber alertas de ofertas e novos exames', style: TextStyle(fontSize: 11)),
                    value: true,
                    onChanged: (val) {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderOutline),
                  ListTile(
                    leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                    title: const Text('Privacidade e Termos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.slateSecondary),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppColors.error,
                elevation: 0,
                side: const BorderSide(color: AppColors.borderOutline),
              ),
              icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
              label: const Text(
                'Sair da Conta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
              color: AppColors.slateSecondary,
            ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateSecondary)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slateDeep),
      ),
    );
  }
}
