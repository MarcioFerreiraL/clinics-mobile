import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../settings/data/preferences.dart';
import '../../data/search_repository.dart';

/// Abre a lista de bairros e guarda a escolha do paciente.
Future<void> showNeighborhoodPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _NeighborhoodSheet(),
  );
}

class _NeighborhoodSheet extends ConsumerWidget {
  const _NeighborhoodSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNeighborhoodProvider);
    final neighborhoods = ref.watch(neighborhoodsProvider);

    Future<void> choose(String? name) async {
      await ref.read(selectedNeighborhoodProvider.notifier).select(name);
      if (context.mounted) Navigator.pop(context);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha seu bairro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Mostramos primeiro as clínicas do bairro escolhido.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            neighborhoods.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(neighborhoodsProvider),
              ),
              data: (items) => Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _option(
                      context,
                      'Todos os bairros',
                      null,
                      selected == null,
                      () => choose(null),
                    ),
                    for (final n in items)
                      _option(
                        context,
                        n.name,
                        '${n.clinicsCount} ${n.clinicsCount == 1 ? 'clínica' : 'clínicas'}',
                        selected == n.name,
                        () => choose(n.name),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    String? subtitle,
    bool selected,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : AppColors.slateSecondary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: onTap,
    );
  }
}
