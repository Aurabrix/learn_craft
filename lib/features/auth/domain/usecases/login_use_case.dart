import 'package:learn_craft/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<void> call({required String email, required String password}) =>
      repository.login(email: email, password: password);
}
