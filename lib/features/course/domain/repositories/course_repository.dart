import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses(String uid);
  Future<CourseEntity?> getCourseById(String courseId);
  Future<List<LessonEntity>> getLessons(String courseId);
}
