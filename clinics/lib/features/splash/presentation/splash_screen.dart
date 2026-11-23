import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

/// Tempo que a abertura fica na tela.
const splashDuration = Duration(milliseconds: 1200);

/// Vira `true` quando a abertura termina; o roteador espera por isso para sair dela.
class SplashFinished extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() => state = true;
}

final splashFinishedProvider = NotifierProvider<SplashFinished, bool>(
  SplashFinished.new,
);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(splashDuration, () {
      if (mounted) ref.read(splashFinishedProvider.notifier).finish();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              const AppLogo(size: 160),
              const SizedBox(height: 12),
              Text(
                'Clinics',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Compare exames em Surubim',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slateSecondary,
                ),
              ),
              const Spacer(flex: 6),
              Text('por MárcioDev e Lucas', style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
