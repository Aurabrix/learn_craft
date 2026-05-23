abstract class AuthRemoteDataSource {
  Future<void> login({required String email, required String password});

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  });

  Future<bool> isUsernameAvailable(String username);

  Future<void> logout();
}
