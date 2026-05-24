import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  const GetCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call(String uid) => repository.getCourses(uid);
}
