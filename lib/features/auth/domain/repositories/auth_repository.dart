abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}
