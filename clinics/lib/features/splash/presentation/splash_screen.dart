import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_logo.dart';

/// Duração da animação de abertura.
const splashDuration = Duration(milliseconds: 2400);

/// Vira `true` quando a animação de abertura termina; o roteador espera por isso para sair da abertura.
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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: splashDuration,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Segura o logo pronto por um instante antes de sair.
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) ref.read(splashFinishedProvider.notifier).finish();
        });
      }
    });
    // Só começa depois do primeiro quadro desenhado, para nenhuma etapa ser "pulada".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller.forward();
      });
    });
  }

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
