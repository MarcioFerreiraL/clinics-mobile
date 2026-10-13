import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/network_activity_overlay.dart';
import 'features/settings/data/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ClinicsApp(),
    ),
  );
}

class ClinicsApp extends ConsumerWidget {
  const ClinicsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Clinics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          NetworkActivityOverlay(child: child ?? const SizedBox.shrink()),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
