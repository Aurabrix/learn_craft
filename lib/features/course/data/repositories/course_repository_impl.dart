import 'package:learn_craft/features/course/data/datasources/course_remote_data_source.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';
import 'package:learn_craft/features/course/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CourseEntity>> getCourses(String uid) =>
      remoteDataSource.getCourses(uid);

  @override
  Future<CourseEntity?> getCourseById(String courseId) =>
      remoteDataSource.getCourseById(courseId);

  @override
  Future<List<LessonEntity>> getLessons(String courseId) =>
      remoteDataSource.getLessons(courseId);
}
