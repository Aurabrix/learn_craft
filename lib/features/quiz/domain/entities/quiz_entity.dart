import 'package:learn_craft/features/quiz/domain/entities/question_entity.dart';

class QuizEntity {
  final String id;
  final String courseId;
  final String lessonId;
  final String title;
  final int totalQuestions;
  final List<QuestionEntity> questions;

  const QuizEntity({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.totalQuestions,
    required this.questions,
  });
}
