import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/routes/router_notifier.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learn_craft/features/auth/presentation/ui/create_user_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/splash_sreen.dart';
import '../../features/home/presentation/ui/home_screen.dart';

GoRouter buildRouter(RouterNotifier notifier) => GoRouter(
      refreshListenable: notifier,
      // initialLocation is determined from bloc's initial state (already resolved
      // synchronously from FirebaseAuth.currentUser), so no flash on first render.
      initialLocation: notifier.authState is AuthAuthenticated
          ? AppPaths.home
          : AppPaths.login,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final authState = notifier.authState;

        // Never redirect while an operation is in progress
        if (authState is AuthLoading) return null;

        final isOnAuthPage = location == AppPaths.login ||
            location == AppPaths.createUser;

        if (authState is AuthAuthenticated && isOnAuthPage) return AppPaths.home;
        if (authState is AuthInitial && !isOnAuthPage) return AppPaths.login;

        return null;
      },
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
          path: AppPaths.home,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
