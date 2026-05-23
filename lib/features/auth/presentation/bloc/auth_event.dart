part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

final class CreateUserRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  CreateUserRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

final class LogoutRequested extends AuthEvent {}
