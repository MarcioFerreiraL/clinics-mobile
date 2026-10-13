import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Foto do usuário; sem foto (ou se ela falhar), mostra a inicial do nome em um tom pastel.
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double radius;

  const UserAvatar({super.key, this.name, this.imageUrl, this.radius = 24});

  static const _tones = <(Color, Color)>[
    (AppColors.primarySoft, AppColors.primaryDeep),
    (AppColors.mintSoft, AppColors.mintDeep),
    (AppColors.atmosphericBlue, AppColors.primaryDeep),
    (AppColors.whatsApp, AppColors.mintDeep),
  ];

  String get _initial {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // O tom depende do nome, então cada pessoa mantém sempre a mesma cor.
    final tone =
        _tones[(name ?? '').runes.fold(0, (a, b) => a + b) % _tones.length];
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: tone.$1,
      foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onForegroundImageError: hasImage ? (_, _) {} : null,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
          color: tone.$2,
        ),
      ),
    );
  }
}
