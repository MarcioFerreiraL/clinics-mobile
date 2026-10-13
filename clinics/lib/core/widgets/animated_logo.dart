import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Desenha o logo (pino azul, cruz branca e selo menta) por partes, para poder animar cada uma.
/// Usa as mesmas coordenadas de `tool/generate_logo.py` (espaço de 1024 x 1024).
class LogoPainter extends CustomPainter {
  /// 0 = pino fora de cena (acima), 1 = pino no lugar.
  final double pinDrop;
  final double crossScale;
  final double badgeScale;
  final double checkProgress;

  /// Deslocamento vertical em unidades do logo (pulinho do carregamento).
  final double bob;

  /// Sombra no chão; 0 desliga.
  final double shadow;

  const LogoPainter({
    this.pinDrop = 1,
    this.crossScale = 1,
    this.badgeScale = 1,
    this.checkProgress = 1,
    this.bob = 0,
    this.shadow = 0,
  });

  static const _blue = Color(0xFF0284C7);
  static const _mint = Color(0xFF8FD9B6);

  static const _center = Offset(512, 430);
  static const _radius = 255.0;
  static const _tip = Offset(512, 880);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 1024;
    canvas.save();
    canvas.scale(s);

    if (shadow > 0) {
      final w = 300 * (1 - 0.35 * bob.abs() / 40) * shadow;
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(512, 905), width: w, height: 34),
        Paint()
          ..color = const Color(0xFF0284C7).withValues(alpha: 0.16 * shadow),
      );
    }

    final drop = (1 - pinDrop) * -520;
    canvas.translate(0, drop + bob);
    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withValues(alpha: pinDrop.clamp(0, 1)),
    );

    canvas.drawPath(_pinPath(), Paint()..color = _blue);

    if (crossScale > 0) {
      canvas.save();
      canvas.translate(_center.dx, _center.dy);
      canvas.scale(crossScale);
      final p = Paint()..color = Colors.white;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-150, -50, 150, 50),
          const Radius.circular(24),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-50, -150, 50, 150),
          const Radius.circular(24),
        ),
        p,
      );
      canvas.restore();
    }

    if (badgeScale > 0) {
      canvas.save();
      canvas.translate(712, 712);
      canvas.scale(badgeScale);
      canvas.drawCircle(Offset.zero, 136, Paint()..color = Colors.white);
      canvas.drawCircle(Offset.zero, 118, Paint()..color = _mint);
      if (checkProgress > 0) {
        final check = Path()
          ..moveTo(-52, 4)
          ..lineTo(-14, 44)
          ..lineTo(56, -40);
        final metric = check.computeMetrics().first;
        canvas.drawPath(
          metric.extractPath(0, metric.length * checkProgress),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 26
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
      canvas.restore();
    }

    canvas.restore();
    canvas.restore();
  }

  static Path _pinPath() {
    final dist = _tip.dy - _center.dy;
    final a = math.asin(_radius / dist);
    final tx = _radius * math.cos(a);
    final ty = _radius * math.sin(a);
    final circle = Path()
      ..addOval(Rect.fromCircle(center: _center, radius: _radius));
    final cone = Path()
      ..moveTo(_center.dx - tx, _center.dy + ty)
      ..lineTo(_center.dx + tx, _center.dy + ty)
      ..lineTo(_tip.dx, _tip.dy)
      ..close();
    return Path.combine(PathOperation.union, circle, cone);
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.pinDrop != pinDrop ||
      old.crossScale != crossScale ||
      old.badgeScale != badgeScale ||
      old.checkProgress != checkProgress ||
      old.bob != bob ||
      old.shadow != shadow;
}

/// Entrada do logo: o pino cai e quica, a cruz "pipoca", o selo aparece e o "ok" é desenhado.
class AnimatedLogo extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const AnimatedLogo({super.key, required this.animation, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        double stage(double begin, double end, Curve curve) => curve.transform(
          ((animation.value - begin) / (end - begin)).clamp(0.0, 1.0),
        );
        return CustomPaint(
          size: Size.square(size),
          painter: LogoPainter(
            pinDrop: stage(0.0, 0.40, Curves.bounceOut),
            crossScale: stage(0.34, 0.58, Curves.elasticOut),
            badgeScale: stage(0.52, 0.72, Curves.easeOutBack),
            checkProgress: stage(0.70, 0.90, Curves.easeOut),
          ),
        );
      },
    );
  }
}
