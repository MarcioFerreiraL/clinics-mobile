import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/admin_repository.dart';
import 'admin_widgets.dart';

/// Matriz de permissões: um cargo por vez, com checkbox para cada permissão.
class PermissionsTab extends ConsumerStatefulWidget {
  final bool canEdit;

  const PermissionsTab({super.key, required this.canEdit});

  @override
  ConsumerState<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends ConsumerState<PermissionsTab> {
  String? _positionId;
  // Permissões em gravação, para evitar toque duplo.
  final _saving = <String>{};

  Future<void> _toggle(
    AdminPosition position,
    AdminPermission permission,
    bool granted,
  ) async {
    final key = '${position.id}:${permission.id}';
    if (!_saving.add(key)) return;
    setState(() {});
    try {
      await ref
          .read(adminRepositoryProvider)
          .setPermission(position.id, permission.id, granted: granted);
      ref.invalidate(adminMatrixProvider);
      await ref.read(adminMatrixProvider.future);
      if (mounted) {
        showAdminToast(
          context,
          granted
              ? '"${permission.label}" concedida a ${position.name}.'
              : '"${permission.label}" retirada de ${position.name}.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) showAdminToast(context, e.message, error: true);
    } finally {
      _saving.remove(key);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = ref.watch(adminMatrixProvider);
    final theme = Theme.of(context);
    return matrix.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(adminMatrixProvider)),
      data: (m) {
        if (m.positions.isEmpty) {
          return const Center(child: Text('Nenhum cargo cadastrado.'));
        }
        final position = m.positions.firstWhere(
          (p) => p.id == _positionId,
          orElse: () => m.positions.first,
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminTitle('Gerir', 'Permissões'),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: m.positions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = m.positions[i];
                  return ChoiceChip(
                    label: Text(p.name),
                    selected: p.id == position.id,
                    selectedColor: AppColors.atmosphericBlue,
                    backgroundColor: AppColors.surfaceWhite,
                    side: BorderSide(
                      color: p.id == position.id
                          ? AppColors.primary
                          : AppColors.borderOutline,
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: p.id == position.id
                          ? AppColors.primary
                          : AppColors.slateSecondary,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _positionId = p.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AdminCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionTitle(position.name),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        AdminPill(
                          position.seesAllClinics
                              ? 'Todas as clínicas'
                              : 'Própria clínica',
                          tone: AdminPillTone.info,
                        ),
                        const SizedBox(width: 8),
                        AdminPill(
                          '${position.permissions.length} de ${m.permissions.length} permissões',
                          tone: AdminPillTone.success,
                        ),
                      ],
                    ),
                  ),
                  for (final perm in m.permissions)
                    _PermissionRow(
                      permission: perm,
                      granted: position.permissions.contains(perm.key),
                      busy: _saving.contains('${position.id}:${perm.id}'),
                      enabled: widget.canEdit,
                      onChanged: (v) => _toggle(position, perm, v),
                    ),
                ],
              ),
            ),
            if (!widget.canEdit)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Você pode ver a matriz, mas não alterá-la.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final AdminPermission permission;
  final bool granted;
  final bool busy;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PermissionRow({
    required this.permission,
    required this.granted,
    required this.busy,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderOutline)),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primary,
        value: granted,
        onChanged: enabled && !busy ? (v) => onChanged(v ?? false) : null,
        title: Text(
          permission.label,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(permission.key, style: theme.textTheme.bodySmall),
        secondary: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  }
}
