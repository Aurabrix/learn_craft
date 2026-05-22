import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/features/auth/presentation/ui/create_user_screen.dart';
import 'package:learn_craft/features/auth/presentation/ui/otp_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/splash_sreen.dart';

final GoRouter router = GoRouter(
  initialLocation: AppPaths.initial,
  routes: [
    GoRoute(
      path: AppPaths.initial,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppPaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPaths.createUser,
      builder: (context, state) => const CreateUserScreen(),
    ),
    GoRoute(
      path: AppPaths.otp,
      builder: (context, state) => OtpScreen(
        email: state.extra as String? ?? '',
      ),
    ),
  ],
);
