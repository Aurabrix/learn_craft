import 'package:learn_craft/features/auth/domain/entities/user_e.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  });

  Future<bool> isUsernameAvailable(String username);

  Future<UserEntity?> getCurrentUser();

  Future<void> logout();
}
