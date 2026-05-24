import 'package:learn_craft/features/quiz/data/models/quiz_model.dart';

abstract class QuizRemoteDataSource {
  /// Fetches the first quiz under courses/{courseId}/lessons/{lessonId}/quizzes
  Future<QuizModel?> getQuiz({
    required String courseId,
    required String lessonId,
  });
}
