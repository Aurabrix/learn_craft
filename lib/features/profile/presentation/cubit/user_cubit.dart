import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/features/auth/domain/entities/user_e.dart';
import 'package:learn_craft/features/auth/domain/usecases/get_current_user_use_case.dart';

// ── States ──────────────────────────────────────────────────
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final UserEntity user;
  UserLoaded(this.user);
}

final class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// ── Cubit ───────────────────────────────────────────────────
class UserCubit extends Cubit<UserState> {
  final GetCurrentUserUseCase _getCurrentUser;

  UserCubit({required GetCurrentUserUseCase getCurrentUserUseCase})
      : _getCurrentUser = getCurrentUserUseCase,
        super(UserInitial());

  Future<void> loadUser() async {
    emit(UserLoading());
    try {
      final user = await _getCurrentUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
