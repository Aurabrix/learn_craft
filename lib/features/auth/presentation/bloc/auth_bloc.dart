import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/features/auth/domain/usecases/check_username_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/create_user_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/login_use_case.dart';
import 'package:learn_craft/features/auth/domain/usecases/logout_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final CreateUserUseCase _createUser;
  final LogoutUseCase _logout;
  final CheckUsernameUseCase _checkUsername;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required CreateUserUseCase createUserUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckUsernameUseCase checkUsernameUseCase,
  })  : _login = loginUseCase,
        _createUser = createUserUseCase,
        _logout = logoutUseCase,
        _checkUsername = checkUsernameUseCase,
        super(
          FirebaseAuth.instance.currentUser != null
              ? AuthAuthenticated()
              : AuthInitial(),
        ) {
    on<LoginRequested>(_onLogin);
    on<CreateUserRequested>(_onCreateUser);
    on<CheckUsernameRequested>(_onCheckUsername);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _login(email: event.email, password: event.password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCreateUser(
    CreateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _createUser(
        name: event.name,
        email: event.email,
        password: event.password,
        avatarUrl: event.avatarUrl,
      );
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCheckUsername(
    CheckUsernameRequested event,
    Emitter<AuthState> emit,
  ) async {
    final username = event.username.trim();
    if (username.isEmpty) return;

    emit(UsernameChecking());
    try {
      final available = await _checkUsername(username);
      if (available) {
        emit(UsernameAvailable(username));
      } else {
        emit(UsernameUnavailable(username));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
