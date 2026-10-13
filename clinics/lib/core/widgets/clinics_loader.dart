import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'animated_logo.dart';

/// Carregamento da marca: o pino pula e a sombra no chão acompanha. Animação 2D simples.
class ClinicsLoader extends StatefulWidget {
  final double size;
  final String? message;

  const ClinicsLoader({super.key, this.size = 72, this.message});

  @override
  State<ClinicsLoader> createState() => _ClinicsLoaderState();
}

class _ClinicsLoaderState extends State<ClinicsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // Sobe desacelerando e desce acelerando, como um pulinho.
            final lift = Curves.easeOutQuad.transform(_controller.value);
            return CustomPaint(
              size: Size.square(widget.size),
              painter: LogoPainter(bob: -lift * 70, shadow: 1),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 8),
          Text(widget.message!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Estado de carregamento de tela inteira.
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) =>
      Center(child: ClinicsLoader(size: 56, message: message));
}

/// Bloco "esqueleto" que pulsa suavemente enquanto o conteúdo carrega.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.atmosphericBlue,
            AppColors.surfaceMuted,
            _controller.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Lista de cards "esqueleto" no formato do resultado de busca.
class SkeletonCards extends StatelessWidget {
  final int count;

  const SkeletonCards({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderOutline),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 150, height: 16),
            SizedBox(height: 8),
            SkeletonBox(width: 100),
            SizedBox(height: 18),
            SkeletonBox(height: 20),
            SizedBox(height: 10),
            SkeletonBox(width: 200),
            SizedBox(height: 18),
            SkeletonBox(height: 40, radius: 10),
          ],
        ),
      ),
    );
  }
}
