import 'package:learn_craft/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';
import 'package:learn_craft/features/quiz/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource dataSource;

  QuizRepositoryImpl({required this.dataSource});

  @override
  Future<QuizEntity?> getQuiz({
    required String courseId,
    required String lessonId,
  }) =>
      dataSource.getQuiz(courseId: courseId, lessonId: lessonId);
}
