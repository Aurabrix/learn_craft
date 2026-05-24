import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';
import 'package:learn_craft/features/course/domain/repositories/course_repository.dart';

class GetLessonsUseCase {
  final CourseRepository repository;

  const GetLessonsUseCase(this.repository);

  Future<List<LessonEntity>> call(String courseId) =>
      repository.getLessons(courseId);
}
