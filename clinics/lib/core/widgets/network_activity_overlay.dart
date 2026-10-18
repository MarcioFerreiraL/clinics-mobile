import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_activity.dart';
import '../theme/app_colors.dart';
import 'animated_logo.dart';

/// Mostra que o app está falando com o servidor, para ninguém achar que travou:
/// uma barra fina no topo (após 0,25 s) e um aviso com o pino pulando (após 0,8 s).
/// Não bloqueia toques.
class NetworkActivityOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const NetworkActivityOverlay({super.key, required this.child});

  @override
  ConsumerState<NetworkActivityOverlay> createState() =>
      _NetworkActivityOverlayState();
}

class _NetworkActivityOverlayState
    extends ConsumerState<NetworkActivityOverlay> {
  static const _barDelay = Duration(milliseconds: 250);
  static const _noticeDelay = Duration(milliseconds: 800);

  Timer? _barTimer;
  Timer? _noticeTimer;
  bool _showBar = false;
  bool _showNotice = false;
  bool _sending = false;

  @override
  void dispose() {
    _barTimer?.cancel();
    _noticeTimer?.cancel();
    super.dispose();
  }

  void _onActivity(NetworkActivity activity) {
    _sending = activity.sending;
    if (activity.busy) {
      _barTimer ??= Timer(_barDelay, () {
        if (mounted) setState(() => _showBar = true);
      });
      _noticeTimer ??= Timer(_noticeDelay, () {
        if (mounted) setState(() => _showNotice = true);
      });
    } else {
      _barTimer?.cancel();
      _noticeTimer?.cancel();
      _barTimer = _noticeTimer = null;
      if (_showBar || _showNotice) {
        setState(() => _showBar = _showNotice = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(networkActivityProvider, (_, next) => _onActivity(next));
    final bottom = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        widget.child,
        if (_showBar)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: AppColors.primarySoft,
              ),
            ),
          ),
        if (_showNotice)
          Positioned(
            bottom: 84 + bottom,
            left: 0,
            right: 0,
            child: IgnorePointer(
              // Entra subindo e aparecendo; só existe na árvore enquanto há demora.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - t)),
                    child: child,
                  ),
                ),
                child: Center(child: _Notice(sending: _sending)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final bool sending;

  const _Notice({required this.sending});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primarySoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 34, height: 40, child: _HoppingPin()),
            const SizedBox(width: 6),
            Text(
              sending ? 'Enviando…' : 'Carregando…',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Versão pequena do pino pulando (mesmo desenho do carregamento de tela cheia).
class _HoppingPin extends StatefulWidget {
  const _HoppingPin();

  @override
  State<_HoppingPin> createState() => _HoppingPinState();
}

class _HoppingPinState extends State<_HoppingPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
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
      builder: (context, _) => CustomPaint(
        painter: LogoPainter(
          bob: -Curves.easeOutQuad.transform(_controller.value) * 70,
          shadow: 1,
        ),
      ),
    );
  }
}
