import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<QuizEntity?> getQuiz({
    required String courseId,
    required String lessonId,
  });
}
