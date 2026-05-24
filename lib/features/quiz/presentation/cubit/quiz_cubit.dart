import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';
import 'package:learn_craft/features/quiz/domain/usecases/get_quiz_use_case.dart';

// ── States ──────────────────────────────────────────────────
sealed class QuizState {}

final class QuizInitial extends QuizState {}

final class QuizLoading extends QuizState {}

final class QuizLoaded extends QuizState {
  final QuizEntity quiz;
  QuizLoaded(this.quiz);
}

final class QuizNotFound extends QuizState {}

final class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}

// ── Cubit ────────────────────────────────────────────────────
class QuizCubit extends Cubit<QuizState> {
  final GetQuizUseCase _getQuiz;

  QuizCubit({required GetQuizUseCase getQuizUseCase})
      : _getQuiz = getQuizUseCase,
        super(QuizInitial());

  Future<void> loadQuiz({
    required String courseId,
    required String lessonId,
  }) async {
    emit(QuizLoading());
    try {
      final quiz = await _getQuiz(courseId: courseId, lessonId: lessonId);
      if (quiz == null || quiz.questions.isEmpty) {
        emit(QuizNotFound());
      } else {
        emit(QuizLoaded(quiz));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }
}
