import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/domain/usecases/get_courses_use_case.dart';

// ── States ──────────────────────────────────────────────────
sealed class CourseState {}

final class CourseInitial extends CourseState {}

final class CourseLoading extends CourseState {}

final class CourseLoaded extends CourseState {
  final List<CourseEntity> courses;
  CourseLoaded(this.courses);
}

final class CourseError extends CourseState {
  final String message;
  CourseError(this.message);
}

// ── Cubit ───────────────────────────────────────────────────
class CourseCubit extends Cubit<CourseState> {
  final GetCoursesUseCase _getCourses;

  CourseCubit({required GetCoursesUseCase getCoursesUseCase})
      : _getCourses = getCoursesUseCase,
        super(CourseInitial());

  Future<void> loadCourses() async {
    emit(CourseLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final courses = await _getCourses(uid);
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}
