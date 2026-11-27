import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/admin_repository.dart';
import 'admin_widgets.dart';

/// Resumo calculado só com o que a API de admin já entrega.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(adminAccountsProvider);
    final matrix = ref.watch(adminMatrixProvider);

    if (accounts.hasError || matrix.hasError) {
      return ErrorView(
        error: (accounts.error ?? matrix.error)!,
        onRetry: () {
          ref.invalidate(adminAccountsProvider);
          ref.invalidate(adminMatrixProvider);
        },
      );
    }
    if (!accounts.hasValue || !matrix.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = accounts.requireValue;
    final m = matrix.requireValue;
    final byPosition = <String, int>{};
    final byClinic = <String, int>{};
    for (final a in list) {
      byPosition.update(a.position ?? 'Sem cargo', (v) => v + 1, ifAbsent: () => 1);
      if (a.clinicName != null) {
        byClinic.update(a.clinicName!, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final positions = byPosition.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final clinics = byClinic.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminAccountsProvider);
        ref.invalidate(adminMatrixProvider);
        await ref.read(adminAccountsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminTitle('Visão', 'Geral'),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AdminStatCard(
                label: 'Contas internas',
                value: '${list.length}',
                color: AppColors.primary,
              ),
              AdminStatCard(
                label: 'Cargos',
                value: '${m.positions.length}',
              ),
              AdminStatCard(
                label: 'Permissões',
                value: '${m.permissions.length}',
              ),
              AdminStatCard(
                label: 'Clínicas com equipe',
                value: '${byClinic.length}',
                color: AppColors.successText,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Distribution(
            title: 'Contas por cargo',
            entries: positions,
            suffix: 'contas',
          ),
          const SizedBox(height: 16),
          _Distribution(
            title: 'Equipe por clínica',
            entries: clinics,
            suffix: 'contas',
            color: AppColors.mintDeep,
            empty: 'Nenhuma conta vinculada a clínicas.',
          ),
        ],
      ),
    );
  }
}

class _Distribution extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> entries;
  final String suffix;
  final Color color;
  final String empty;

  const _Distribution({
    required this.title,
    required this.entries,
    required this.suffix,
    this.color = AppColors.primary,
    this.empty = 'Sem dados suficientes.',
  });

  @override
  Widget build(BuildContext context) {
    final max = entries.fold<int>(1, (m, e) => e.value > m ? e.value : m);
    final theme = Theme.of(context);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(title),
          if (entries.isEmpty)
            Text(empty, style: theme.textTheme.bodySmall)
          else
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${e.value} $suffix',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AdminBar(fraction: e.value / max, color: color),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
