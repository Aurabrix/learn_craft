import 'package:learn_craft/features/auth/domain/repositories/auth_repository.dart';

import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> login({required String email, required String password}) =>
      remoteDataSource.login(email: email, password: password);

  @override
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  }) =>
      remoteDataSource.createUser(
        name: name,
        email: email,
        password: password,
        avatarUrl: avatarUrl,
      );

  @override
  Future<bool> isUsernameAvailable(String username) =>
      remoteDataSource.isUsernameAvailable(username);

  @override
  Future<void> logout() => remoteDataSource.logout();
}
