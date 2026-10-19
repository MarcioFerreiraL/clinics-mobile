import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/app_drawer.dart';
import '../../data/clinic_management_repository.dart';

class ClinicDashboardScreen extends ConsumerWidget {
  const ClinicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(clinicDashboardProvider);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Abrir menu',
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
        ),
        title: const Text('Painel da clínica'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref.invalidate(clinicDashboardProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is ApiException
              ? error.message
              : 'Não foi possível carregar o painel.',
          onRetry: () => ref.invalidate(clinicDashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(clinicDashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Olá, ${data.clinicName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Resumo dos últimos ${data.periodDays} dias',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slateSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _MetricCard(
                icon: Icons.chat_outlined,
                label: 'Cliques para o WhatsApp',
                value: data.whatsappClicks,
                color: AppColors.mintDeep,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                icon: Icons.visibility_outlined,
                label: 'Aberturas de exames',
                value: data.examViews,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                icon: Icons.medical_services_outlined,
                label: 'Exames ativos',
                value: data.activeExams,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/clinic-exams'),
                icon: const Icon(Icons.edit_note),
                label: const Text('Gerenciar exames'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    ),
  );
}
