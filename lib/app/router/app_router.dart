import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soul_script_reader/presentation/draw/draw_page.dart';
import 'package:soul_script_reader/presentation/history/history_page.dart';
import 'package:soul_script_reader/presentation/main/main_page.dart';
import 'package:soul_script_reader/presentation/splash/splash_page.dart';

/// go_router 인스턴스 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: '/draw',
        builder: (context, state) => const DrawPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
    ],
  );
});
