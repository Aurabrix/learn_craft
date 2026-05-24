import 'package:learn_craft/features/course/data/models/course_model.dart';
import 'package:learn_craft/features/course/data/models/lesson_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses(String uid);
  Future<CourseModel?> getCourseById(String courseId);
  Future<List<LessonModel>> getLessons(String courseId);
}
