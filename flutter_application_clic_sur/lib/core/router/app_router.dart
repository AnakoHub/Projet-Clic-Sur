import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/lessons/presentation/lesson_content_screen.dart';
import '../../features/lessons/presentation/lessons_screen.dart';
import '../../features/levels/presentation/level_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/quiz/presentation/level_intro_screen.dart';
import '../../features/quiz/presentation/quiz_map_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import 'go_router_refresh_stream.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = Supabase.instance.client.auth;
  final refresh = GoRouterRefreshStream(auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    // Sans session, tout renvoie vers /login ; avec session, /login renvoie à l'accueil.
    redirect: (context, state) {
      final loggedIn = auth.currentSession != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/lessons', builder: (context, state) => const LessonsScreen()),
      GoRoute(
        path: '/lessons/:lessonId',
        builder: (context, state) => LessonContentScreen(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        path: '/levels/:themeId',
        builder: (context, state) => LevelScreen(themeId: state.pathParameters['themeId']!),
      ),
      GoRoute(path: '/quiz-map', builder: (context, state) => const QuizMapScreen()),
      // Intro de niveau : atteinte depuis la Quiz Map, l'accueil ou les leçons.
      GoRoute(
        path: '/quiz/:levelId/intro',
        builder: (context, state) => LevelIntroScreen(levelId: state.pathParameters['levelId']!),
      ),
      // Écran de jeu (questions Vrai/Faux + transitions).
      GoRoute(
        path: '/quiz/:levelId',
        builder: (context, state) => QuizScreen(levelId: state.pathParameters['levelId']!),
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
});
