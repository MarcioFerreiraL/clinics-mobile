import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/admin_repository.dart';
import 'admin_widgets.dart';

/// Lista de contas internas com cargo e clínica; gestor com permissão troca o cargo.
class AccountsTab extends ConsumerWidget {
  final bool canManage;

  const AccountsTab({super.key, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(adminAccountsProvider);
    return accounts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(adminAccountsProvider)),
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminAccountsProvider);
          await ref.read(adminAccountsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminTitle('Gerir', 'Contas'),
            AdminCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminSectionTitle('Equipe atual'),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Nenhuma conta interna cadastrada.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  else
                    for (final a in list)
                      _AccountTile(account: a, canManage: canManage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  final AdminAccount account;
  final bool canManage;

  const _AccountTile({required this.account, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderOutline)),
      ),
      child: Row(
        children: [
          UserAvatar(name: account.fullName, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(account.phone, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    AdminPill(
                      account.position ?? 'Sem cargo',
                      tone: account.position == null
                          ? AdminPillTone.warning
                          : AdminPillTone.info,
                    ),
                    if (account.clinicName != null)
                      AdminPill(account.clinicName!),
                  ],
                ),
              ],
            ),
          ),
          if (canManage)
            IconButton(
              tooltip: 'Alterar cargo',
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.slateSecondary,
              style: IconButton.styleFrom(
                side: const BorderSide(color: AppColors.borderOutline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _changePosition(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _changePosition(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(adminRepositoryProvider);
    AdminMatrix matrix;
    try {
      matrix = await ref.read(adminMatrixProvider.future);
    } catch (_) {
      if (context.mounted) {
        showAdminToast(context, 'Não foi possível carregar os cargos.', error: true);
      }
      return;
    }
    if (!context.mounted) return;
    final chosen = await showModalBottomSheet<AdminPosition>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PositionPicker(account: account, positions: matrix.positions),
    );
    if (chosen == null || chosen.name == account.position) return;
    if (!chosen.seesAllClinics && account.clinicId == null) {
      if (context.mounted) {
        showAdminToast(
          context,
          'Este cargo exige uma clínica e a conta não tem nenhuma vinculada.',
          error: true,
        );
      }
      return;
    }
    try {
      await repo.changePosition(
        account.id,
        chosen.id,
        clinicId: chosen.seesAllClinics ? null : account.clinicId,
      );
      ref.invalidate(adminAccountsProvider);
      if (context.mounted) {
        showAdminToast(context, 'Cargo de ${account.fullName} atualizado!');
      }
    } on ApiException catch (e) {
      if (context.mounted) showAdminToast(context, e.message, error: true);
    }
  }
}

class _PositionPicker extends StatelessWidget {
  final AdminAccount account;
  final List<AdminPosition> positions;

  const _PositionPicker({required this.account, required this.positions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar cargo',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(account.fullName, style: theme.textTheme.bodySmall),
            const SizedBox(height: 14),
            for (final p in positions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context, p),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.name == account.position
                          ? AppColors.atmosphericBlue
                          : AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: p.name == account.position
                            ? AppColors.primary
                            : AppColors.borderOutline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AdminPill(
                          p.seesAllClinics ? 'Todas as clínicas' : 'Própria clínica',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
