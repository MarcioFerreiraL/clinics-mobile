import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/branding/logo_mark.png', width: size, height: size);
}
