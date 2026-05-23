import 'package:learn_craft/features/auth/domain/repositories/auth_repository.dart';

class CreateUserUseCase {
  final AuthRepository repository;

  const CreateUserUseCase(this.repository);

  Future<void> call({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  }) =>
      repository.createUser(
        name: name,
        email: email,
        password: password,
        avatarUrl: avatarUrl,
      );
}
