import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../clinic/domain/operating_hours.dart';
import '../../domain/exam_detail.dart';

/// "Local de atendimento": quem atende, onde fica, se está aberta e como chegar ou ligar.
class ClinicLocationCard extends StatelessWidget {
  final ExamClinic clinic;

  const ClinicLocationCard({super.key, required this.clinic});

  Future<void> _openRoute(BuildContext context) async {
    final query = clinic.latitude != null && clinic.longitude != null
        ? '${clinic.latitude},${clinic.longitude}'
        : Uri.encodeComponent('${clinic.address ?? clinic.name}, Surubim, PE');
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  Future<void> _call(BuildContext context) async {
    final digits = (clinic.phoneNumber ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    if (!await launchUrl(Uri.parse('tel:$digits')) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar a ligação.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = [
      if (clinic.address != null) clinic.address!,
      if (clinic.neighborhood != null) clinic.neighborhood!,
    ].join(' • ');
    final hours = OperatingHours.summarize(clinic.operatingHours).split(' • ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOutline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho em azul bem claro, com a clínica em destaque
          Container(
            color: AppColors.atmosphericBlue,
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: UserAvatar(name: clinic.name, radius: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCAL DE ATENDIMENTO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              clinic.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (clinic.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/clinic/${clinic.id}'),
                  child: const Text('Ver clínica'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      icon: clinic.openNow
                          ? Icons.check_circle
                          : Icons.schedule,
                      text: clinic.openNow ? 'Aberto agora' : 'Fechado agora',
                      background: clinic.openNow
                          ? AppColors.mintSoft
                          : AppColors.surfaceMuted,
                      foreground: clinic.openNow
                          ? AppColors.mintDeep
                          : AppColors.slateSecondary,
                    ),
                    _Pill(
                      icon: Icons.star_rounded,
                      text: clinic.reviewCount == 0
                          ? 'Sem avaliações'
                          : '${clinic.rating.toStringAsFixed(1).replaceAll('.', ',')} · ${clinic.reviewCount} '
                                '${clinic.reviewCount == 1 ? 'avaliação' : 'avaliações'}',
                      background: AppColors.warningBg,
                      foreground: AppColors.warningText,
                    ),
                  ],
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Endereço',
                    lines: [address, 'Surubim - PE'],
                  ),
                ],
                if (hours.isNotEmpty && clinic.operatingHours.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.access_time,
                    title: 'Horário de atendimento',
                    lines: hours,
                  ),
                ],
                if (clinic.phoneNumber != null) ...[
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    title: 'Telefone',
                    lines: [clinic.phoneNumber!],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.directions_outlined, size: 18),
                        label: const Text('Como chegar'),
                        onPressed: () => _openRoute(context),
                      ),
                    ),
                    if (clinic.phoneNumber != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.call_outlined, size: 18),
                          label: const Text('Ligar'),
                          onPressed: () => _call(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.atmosphericBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryDeep),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateSecondary,
                ),
              ),
              const SizedBox(height: 2),
              for (final line in lines)
                Text(
                  line,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateDeep,
                    height: 1.35,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
