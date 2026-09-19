import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/search/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/exam/presentation/screens/exam_detail_screen.dart';
import '../../features/clinic/presentation/screens/clinic_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
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
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
