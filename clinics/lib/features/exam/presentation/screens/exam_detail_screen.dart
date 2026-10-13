import 'package:flutter/material.dart';

import '../../../../core/widgets/clinics_loader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../clinic/domain/operating_hours.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../search/domain/money.dart';
import '../../../../core/device/notification_service.dart';
import '../../data/exam_repository.dart';
import '../../domain/exam_detail.dart';
import '../open_exam_whatsapp.dart';

class ExamDetailScreen extends ConsumerWidget {
  final String examId;

  const ExamDetailScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exam = ref.watch(examDetailProvider(examId));
    return exam.when(
      data: (data) => _ExamBody(exam: data),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Exame')),
        body: const LoadingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Exame')),
        body: ErrorView(
          error: e,
          onRetry: () => ref.invalidate(examDetailProvider(examId)),
        ),
      ),
    );
  }
}

class _ExamBody extends ConsumerWidget {
  final ExamDetail exam;

  const _ExamBody({required this.exam});

  Future<void> _scheduleReminder(BuildContext context, WidgetRef ref) async {
    if (!NotificationService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembretes só funcionam no app instalado (Android).'),
        ),
      );
      return;
    }
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Dia do lembrete',
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      helpText: 'Horário do lembrete',
    );
    if (time == null) return;
    final when = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!when.isAfter(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escolha um horário no futuro.')),
        );
      }
      return;
    }
    await ref
        .read(notificationServiceProvider)
        .scheduleReminder(
          id: exam.id.hashCode & 0x7fffffff,
          examName: exam.examType.name,
          preparation: exam.preparation ?? 'Confira as orientações do exame.',
          when: when,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lembrete agendado.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clinic = exam.clinic;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Detalhes do Exame'),
        actions: [
          Builder(
            builder: (context) {
              final isFavorite =
                  ref
                      .watch(favoritesProvider)
                      .value
                      ?.any((f) => f.examTypeId == exam.examType.id) ??
                  false;
              return IconButton(
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () async {
                  if (ref.read(authProvider).value == null) {
                    context.push('/login');
                    return;
                  }
                  await ref
                      .read(favoritesProvider.notifier)
                      .toggle(exam.examType.id);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Title & Category
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.atmosphericBlue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          exam.examType.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.successText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Disponível',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.successText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exam.examType.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam.examType.description ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slateSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Price & Payment Breakdown Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlueLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.atmosphericBlue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor do Exame',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.slateSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatPrice(exam.price),
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (exam.bestPrice || exam.savings > 0) ...[
                        Text(
                          exam.bestPrice
                              ? 'Melhor preço • economia de ${formatPrice(exam.savings)}'
                              : 'Economize ${formatPrice(exam.savings)} (média ${formatPrice(exam.averagePrice)})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.successText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        exam.paymentMethods ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.slateDeep,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderOutline),
                    ),
                    child: const Icon(
                      Icons.price_check,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preparation & Guidelines Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Instruções e Preparo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildPrepItem(
                    icon: Icons.timer_outlined,
                    title: 'Preparo / Jejum',
                    detail: exam.preparation ?? 'Sem orientações específicas.',
                  ),
                  const SizedBox(height: 12),
                  _buildPrepItem(
                    icon: Icons.schedule,
                    title: 'Resultado & Laudo',
                    detail: 'Disponibilizado digitalmente via WhatsApp e portal da clínica.',
                  ),
                  const SizedBox(height: 12),
                  _buildPrepItem(
                    icon: Icons.badge_outlined,
                    title: 'Documentos Necessários',
                    detail: 'Documento com foto (RG ou CNH), CPF e Cartão SUS ou do Convênio.',
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                    ),
                    label: const Text('Lembrar do preparo'),
                    onPressed: () => _scheduleReminder(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Clinic Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOutline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Local de Atendimento',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/clinic/${clinic.id}'),
                        child: const Text('Ver Clínica'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.atmosphericBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    clinic.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (clinic.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.primaryLight,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (clinic.address != null) clinic.address!,
                                if (clinic.neighborhood != null)
                                  clinic.neighborhood!,
                              ].join(' • '),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.slateSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${clinic.openNow ? 'Aberto agora' : 'Fechado agora'} • ${OperatingHours.summarize(clinic.operatingHours)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderOutline)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whatsApp,
              foregroundColor: AppColors.mintDeep,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.chat, size: 20),
            label: const Text(
              'Agendar pelo WhatsApp',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () => openExamWhatsApp(context, ref, exam.id),
          ),
        ),
      ),
    );
  }

  Widget _buildPrepItem({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.slateDeep,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slateSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
