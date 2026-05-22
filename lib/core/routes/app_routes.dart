import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/splash_sreen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: AppPaths.initial,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppPaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
