part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

// ── Username check states ────────────────────────────────────
final class UsernameChecking extends AuthState {}

final class UsernameAvailable extends AuthState {
  final String username;

  UsernameAvailable(this.username);
}

final class UsernameUnavailable extends AuthState {
  final String username;

  UsernameUnavailable(this.username);
}
