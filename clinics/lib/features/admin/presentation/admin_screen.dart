import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../access/data/access_repository.dart';
import 'widgets/accounts_tab.dart';
import 'widgets/overview_tab.dart';
import 'widgets/permissions_tab.dart';

/// Painel administrativo: Visão Geral, Contas e Permissões.
/// O servidor valida cada chamada; aqui só escondemos o que a conta não pode ver.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessProvider);
    return access.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _Blocked(),
      data: (a) {
        if (a == null || !a.can('conta.listar')) return const _Blocked();
        final tabs = <_Tab>[
          _Tab('Visão Geral', Icons.dashboard_outlined, Icons.dashboard,
              const OverviewTab(), a.can('permissao.gerenciar')),
          _Tab('Contas', Icons.groups_outlined, Icons.groups,
              AccountsTab(canManage: a.can('conta.gerenciar')), true),
          _Tab('Permissões', Icons.lock_outline, Icons.lock,
              PermissionsTab(canEdit: a.can('permissao.gerenciar')),
              a.can('permissao.gerenciar')),
        ].where((t) => t.visible).toList();
        final current = _index.clamp(0, tabs.length - 1);
        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          appBar: AppBar(
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Painel '),
                  TextSpan(
                    text: 'Admin',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Controle total do sistema',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: IndexedStack(
                  index: current,
                  children: [for (final t in tabs) t.body],
                ),
              ),
            ),
          ),
          bottomNavigationBar: tabs.length < 2
              ? null
              : NavigationBar(
                  selectedIndex: current,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  backgroundColor: AppColors.surfaceWhite,
                  indicatorColor: AppColors.atmosphericBlue,
                  destinations: [
                    for (final t in tabs)
                      NavigationDestination(
                        icon: Icon(t.icon),
                        selectedIcon: Icon(t.selectedIcon, color: AppColors.primary),
                        label: t.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
  final bool visible;

  _Tab(this.label, this.icon, this.selectedIcon, this.body, this.visible);
}

class _Blocked extends StatelessWidget {
  const _Blocked();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel Admin')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você não tem permissão para acessar esta área.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
