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
import 'package:learn_craft/features/auth/domain/usecases/create_user_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/login_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/logout_use_case.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learn_craft/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final RouterNotifier _routerNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    _authBloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      createUserUseCase: CreateUserUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );
    _routerNotifier = RouterNotifier(_authBloc);
    _router = buildRouter(_routerNotifier);
  }

  @override
  void dispose() {
    _authBloc.close();
    _routerNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
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
