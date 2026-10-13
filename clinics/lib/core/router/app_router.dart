import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/search/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/exam/presentation/screens/exam_detail_screen.dart';
import '../../features/clinic/presentation/screens/clinic_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

const _protectedRoutes = ['/profile', '/favorites'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  // Mantém a abertura na tela pelo menos o tempo da animação do logo.
  var splashDone = false;
  final timer = Timer(splashMinDuration, () {
    splashDone = true;
    refresh.value++;
  });
  ref.onDispose(timer.cancel);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final path = state.matchedLocation;
      if (auth.isLoading || !splashDone) return path == '/' ? null : '/';
      final loggedIn = auth.value != null;
      if (path == '/') return loggedIn ? '/home' : '/login';
      if (!loggedIn && _protectedRoutes.contains(path)) return '/login';
      return null;
    },
    routes: _routes,
  );
});

final _routes = <RouteBase>[
  GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  GoRoute(
    path: '/search',
    builder: (context, state) {
      final query = state.uri.queryParameters['query'] ?? '';
      final category = state.uri.queryParameters['category'] ?? 'Todos';
      return SearchResultsScreen(
        initialQuery: query,
        initialCategory: category,
      );
    },
  ),
  GoRoute(
    path: '/exam/:id',
    builder: (context, state) {
      final examId = state.pathParameters['id'] ?? '';
      return ExamDetailScreen(examId: examId);
    },
  ),
  GoRoute(
    path: '/clinic/:id',
    builder: (context, state) {
      final clinicId = state.pathParameters['id'] ?? '';
      return ClinicProfileScreen(clinicId: clinicId);
    },
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/favorites',
    builder: (context, state) => const FavoritesScreen(),
  ),
  GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
];
