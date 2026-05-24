import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';
import 'package:learn_craft/features/quiz/domain/repositories/quiz_repository.dart';

class GetQuizUseCase {
  final QuizRepository _repository;
  GetQuizUseCase(this._repository);

  Future<QuizEntity?> call({
    required String courseId,
    required String lessonId,
  }) =>
      _repository.getQuiz(courseId: courseId, lessonId: lessonId);
}
