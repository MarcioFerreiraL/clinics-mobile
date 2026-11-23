import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_masks.dart';
import '../../../search/domain/money.dart';
import '../../data/exam_repository.dart';

/// Lista simples das últimas mudanças de preço do exame nesta clínica.
class PriceHistoryCard extends ConsumerWidget {
  final String examId;

  const PriceHistoryCard({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(priceHistoryProvider(examId));
    final theme = Theme.of(context);
    return history.maybeWhen(
      data: (points) {
        if (points.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOutline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico de preço',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < points.length; i++)
                _row(points[i], i + 1 < points.length ? points[i + 1] : null),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _row(PricePoint point, PricePoint? previous) {
    final diff = previous == null ? 0.0 : point.price - previous.price;
    final icon = diff > 0
        ? Icons.arrow_upward
        : diff < 0
        ? Icons.arrow_downward
        : Icons.remove;
    final color = diff > 0
        ? AppColors.error
        : diff < 0
        ? Colors.green
        : AppColors.slateSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(formatPrice(point.price)),
          const Spacer(),
          Text(
            formatBrDate(point.recordedAt),
            style: const TextStyle(color: AppColors.slateSecondary),
          ),
        ],
      ),
    );
  }
}
