import 'package:learn_craft/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> login({required String email, required String password});

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  });

  Future<bool> isUsernameAvailable(String username);

  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}
