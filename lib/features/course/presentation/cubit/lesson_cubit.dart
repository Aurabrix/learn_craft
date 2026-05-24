import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';
import 'package:learn_craft/features/course/domain/usecases/get_lessons_use_case.dart';

// ── States ──────────────────────────────────────────────────
sealed class LessonState {}

final class LessonInitial extends LessonState {}

final class LessonLoading extends LessonState {}

final class LessonLoaded extends LessonState {
  final List<LessonEntity> lessons;
  LessonLoaded(this.lessons);
}

final class LessonError extends LessonState {
  final String message;
  LessonError(this.message);
}

// ── Cubit ───────────────────────────────────────────────────
class LessonCubit extends Cubit<LessonState> {
  final GetLessonsUseCase _getLessons;

  LessonCubit({required GetLessonsUseCase getLessonsUseCase})
      : _getLessons = getLessonsUseCase,
        super(LessonInitial());

  Future<void> loadLessons(String courseId) async {
    emit(LessonLoading());
    try {
      final lessons = await _getLessons(courseId);
      final sorted = List<LessonEntity>.from(lessons)
        ..sort((a, b) => a.order.compareTo(b.order));
      emit(LessonLoaded(sorted));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }
}
