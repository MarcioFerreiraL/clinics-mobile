import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/clinics_loader.dart';

/// Tela de abertura enquanto a sessão é restaurada.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const ClinicsLoader(size: 96),
            const SizedBox(height: 8),
            Text(
              'Clinics',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text('Compare exames em Surubim', style: theme.textTheme.bodySmall),
            const Spacer(),
            Text('por MárcioDev e Lucas', style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
