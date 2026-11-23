import 'package:flutter/material.dart';

/// Estado de carregamento de tela inteira: indicador de progresso padrão.
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!),
        ],
      ],
    ),
  );
}
