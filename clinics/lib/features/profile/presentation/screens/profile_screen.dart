import 'package:flutter/material.dart';

import '../../../../core/widgets/user_avatar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_masks.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../search/domain/money.dart';
import '../../data/profile_repository.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Reduz a imagem para caber no limite de 2 MB da API.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file == null) return;

    try {
      final user = await ref.read(profileRepositoryProvider).uploadAvatar(file);
      ref.read(authProvider.notifier).setUser(user);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();
    final avatar = ApiConfig.fileUrl(user.avatarUrl);
    final savings = ref.watch(savingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickAvatar(context, ref),
                    child: Stack(
                      children: [
                        UserAvatar(
                          name: user.fullName,
                          imageUrl: avatar,
                          radius: 40,
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
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.phone, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlueLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.atmosphericBlue),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total economizado',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          savings.when(
                            data: (s) => formatPrice(s.total),
                            loading: () => '...',
                            error: (_, _) => '—',
                          ),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        if (savings.hasValue)
                          Text(
                            '${savings.value!.contactsCount} contato(s) com clínicas',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader(context, 'DADOS DA CONTA'),
            const SizedBox(height: 8),
            _card(
              children: [
                _tile(Icons.badge_outlined, 'Nome Completo', user.fullName),
                _tile(Icons.phone_android, 'WhatsApp', user.phone),
                _tile(Icons.badge, 'CPF', user.cpf ?? 'Não informado'),
                _tile(
                  Icons.email_outlined,
                  'E-mail',
                  user.email ?? 'Não informado',
                ),
                _tile(Icons.cake_outlined, 'Nascimento', _birth(user)),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Editar dados',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.slateSecondary,
                  ),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => EditProfileSheet(user: user),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionHeader(context, 'MINHA CONTA'),
            const SizedBox(height: 8),
            _card(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Exames favoritos',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.slateSecondary,
                  ),
                  onTap: () => context.push('/favorites'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Alterar senha',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.slateSecondary,
                  ),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const ChangePasswordSheet(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _birth(UserProfile user) {
    final d = user.birthDate;
    return d == null ? 'Não informado' : formatBrDate(d);
  }

  Widget _sectionHeader(BuildContext context, String title) => Align(
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

  Widget _card({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderOutline),
    ),
    child: Column(children: children),
  );

  Widget _tile(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 22),
    title: Text(
      label,
      style: const TextStyle(fontSize: 11, color: AppColors.slateSecondary),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.slateDeep,
      ),
    ),
  );
}
