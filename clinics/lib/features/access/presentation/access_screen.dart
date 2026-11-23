import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/access_repository.dart';

/// Mostra o cargo e as permissões da conta interna logada.
class AccessScreen extends ConsumerWidget {
  const AccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessProvider);
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Minhas permissões')),
      body: access.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Não foi possível carregar.')),
        data: (a) {
          if (a == null || !a.isInternal) {
            return const Center(
              child: Text('Esta área é só para contas da clínica.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Cargo'),
                subtitle: Text(a.position ?? a.role),
              ),
              const Divider(),
              if (a.permissions.isEmpty)
                const ListTile(title: Text('Nenhuma permissão concedida.'))
              else
                for (final p in a.permissions)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.check, color: AppColors.primary),
                    title: Text(p),
                  ),
            ],
          );
        },
      ),
    );
  }
}
