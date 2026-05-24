import 'package:learn_craft/features/auth/domain/entities/user_e.dart';
import 'package:learn_craft/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() => repository.getCurrentUser();
}
