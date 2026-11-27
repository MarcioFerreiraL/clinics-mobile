import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Título de página no estilo do painel: a segunda palavra ganha a cor da marca.
class AdminTitle extends StatelessWidget {
  final String first;
  final String highlight;

  const AdminTitle(this.first, this.highlight, {super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w800,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderOutline)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$first '),
            TextSpan(
              text: highlight,
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        style: base,
      ),
    );
  }
}

/// Cartão branco com borda e cantos de 16px, igual aos painéis do admin web.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOutline),
      ),
      child: child,
    );
  }
}

/// Título de seção com a bolinha colorida à esquerda.
class AdminSectionTitle extends StatelessWidget {
  final String text;

  const AdminSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rótulo pequeno em maiúsculas com espaçamento, usado em indicadores e campos.
class AdminLabel extends StatelessWidget {
  final String text;

  const AdminLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Indicador numérico grande (Visão Geral).
class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminLabel(label),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.slateDeep,
            ),
          ),
        ],
      ),
    );
  }
}

enum AdminPillTone { info, success, warning, neutral }

/// Pílula de status (cargo, escopo etc.).
class AdminPill extends StatelessWidget {
  final String text;
  final AdminPillTone tone;

  const AdminPill(this.text, {super.key, this.tone = AdminPillTone.neutral});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      AdminPillTone.info => (AppColors.atmosphericBlue, AppColors.primary),
      AdminPillTone.success => (AppColors.successBg, AppColors.successText),
      AdminPillTone.warning => (AppColors.warningBg, AppColors.warningText),
      AdminPillTone.neutral => (AppColors.surfaceMuted, AppColors.slateSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Barra horizontal de proporção, como os gráficos da Visão Geral web.
class AdminBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const AdminBar({super.key, required this.fraction, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1).toDouble(),
        minHeight: 12,
        backgroundColor: AppColors.surfaceMuted,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Aviso de feedback (equivalente ao toast do admin web).
void showAdminToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.slateDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
