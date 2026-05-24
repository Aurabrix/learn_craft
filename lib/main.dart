import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/routes/app_routes.dart';
import 'package:learn_craft/core/routes/router_notifier.dart';

import 'package:learn_craft/core/theme/app_theme.dart';
import 'package:learn_craft/core/theme/cubit/theme_cubit.dart';
import 'package:learn_craft/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:learn_craft/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:learn_craft/features/auth/domain/usecases/check_username_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/create_user_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/login_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/logout_use_case.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learn_craft/features/course/data/datasources/course_remote_data_source_impl.dart';
import 'package:learn_craft/features/course/data/repositories/course_repository_impl.dart';
import 'package:learn_craft/features/course/domain/usecases/get_courses_use_case.dart';
import 'package:learn_craft/features/course/presentation/cubit/course_cubit.dart';
import 'package:learn_craft/features/profile/presentation/cubit/user_cubit.dart';
import 'package:learn_craft/core/services/feedback_service.dart';
import 'package:learn_craft/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Touch the singleton so WAV bytes are generated before first interaction
  FeedbackService.instance;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final UserCubit _userCubit;
  late final CourseCubit _courseCubit;
  late final RouterNotifier _routerNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Auth
    final authDataSource = AuthRemoteDataSourceImpl();
    final authRepository =
        AuthRepositoryImpl(remoteDataSource: authDataSource);
    _authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      createUserUseCase: CreateUserUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      checkUsernameUseCase: CheckUsernameUseCase(authRepository),
    );
    _userCubit = UserCubit(
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );

    // Course
    final courseDataSource = CourseRemoteDataSourceImpl();
    final courseRepository =
        CourseRepositoryImpl(remoteDataSource: courseDataSource);
    _courseCubit = CourseCubit(
      getCoursesUseCase: GetCoursesUseCase(courseRepository),
    );

    _routerNotifier = RouterNotifier(_authBloc);
    _router = buildRouter(_routerNotifier);
  }

  @override
  void dispose() {
    _authBloc.close();
    _userCubit.close();
    _courseCubit.close();
    _routerNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _userCubit),
        BlocProvider.value(value: _courseCubit),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: _router,
            title: 'Learn Craft',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
