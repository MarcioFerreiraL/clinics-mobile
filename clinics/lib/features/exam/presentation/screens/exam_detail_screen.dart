import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../search/data/mock_data.dart';
import '../../../search/domain/entities/exam.dart';

class ExamDetailScreen extends StatelessWidget {
  final String examId;

  const ExamDetailScreen({super.key, required this.examId});

  Exam get _exam {
    return MockData.exams.firstWhere(
      (e) => e.id == examId,
      orElse: () => MockData.exams.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exam = _exam;
    final clinic = exam.clinic;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Detalhes do Exame'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link do exame copiado!')),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.atmosphericBlue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          exam.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: AppColors.successText),
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
                    exam.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam.description,
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
                        exam.formattedPrice,
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exam.paymentMethods,
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
                    child: const Icon(Icons.price_check, size: 36, color: AppColors.primary),
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
                      const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
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
                    detail: exam.preparation,
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Clinic Information Card
            if (clinic != null)
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
                          child: const Icon(Icons.local_hospital, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    clinic.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: AppColors.primaryLight),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(clinic.address, style: theme.textTheme.bodySmall),
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
                          const Icon(Icons.access_time, size: 16, color: AppColors.slateSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              clinic.operatingHours,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
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
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat, size: 20),
            label: const Text(
              'Agendar pelo WhatsApp',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (clinic != null) {
                WhatsAppHelper.openChat(
                  context: context,
                  phone: clinic.whatsappNumber,
                  message: 'Olá! Gostaria de agendar o exame ${exam.title} por ${exam.formattedPrice} na ${clinic.name}.',
                );
              }
            },
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
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.slateDeep),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(fontSize: 12, color: AppColors.slateSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
