import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_logo.dart';

/// Tempo mínimo da abertura, para a animação do logo terminar mesmo se a sessão carregar rápido.
const splashMinDuration = Duration(milliseconds: 2400);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: splashMinDuration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Aparece com fade e sobe levemente entre [begin] e [end] (0 a 1 da animação).
  Widget _reveal(double begin, double end, Widget child) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 5),
              AnimatedLogo(animation: _controller, size: 170),
              const SizedBox(height: 12),
              _reveal(
                0.62,
                0.85,
                Text(
                  'Clinics',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 38,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _reveal(
                0.72,
                0.95,
                Text(
                  'Compare exames em Surubim',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slateSecondary,
                  ),
                ),
              ),
              const Spacer(flex: 6),
              _reveal(
                0.8,
                1.0,
                Text('por MárcioDev e Lucas', style: theme.textTheme.bodySmall),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
