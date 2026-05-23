import 'package:learn_craft/features/auth/domain/repositories/auth_repository.dart';

class CheckUsernameUseCase {
  final AuthRepository repository;

  const CheckUsernameUseCase(this.repository);

  Future<bool> call(String username) =>
      repository.isUsernameAvailable(username);
}
