import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/routes/router_notifier.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learn_craft/features/auth/presentation/ui/create_user_screen.dart';
import 'package:learn_craft/features/auth/presentation/ui/welcome_screen.dart';
import 'package:learn_craft/features/upload/presentation/ui/upload_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/splash_sreen.dart';
import '../../features/home/presentation/ui/home_screen.dart';

GoRouter buildRouter(RouterNotifier notifier) => GoRouter(
      refreshListenable: notifier,
      initialLocation: notifier.authState is AuthAuthenticated
          ? AppPaths.home
          : AppPaths.welcome,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final authState = notifier.authState;

        if (authState is AuthLoading) return null;

        final isOnAuthPage = location == AppPaths.welcome ||
            location == AppPaths.login ||
            location == AppPaths.createUser;

        if (authState is AuthAuthenticated && isOnAuthPage) return AppPaths.home;
        if (authState is AuthInitial && !isOnAuthPage) return AppPaths.welcome;

        return null;
      },
      routes: [
        GoRoute(
          path: AppPaths.initial,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppPaths.welcome,
          builder: (context, state) => const WelcomeScreen(),
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
          path: AppPaths.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppPaths.upload,
          builder: (context, state) => const UploadScreen(),
        ),
      ],
    );
