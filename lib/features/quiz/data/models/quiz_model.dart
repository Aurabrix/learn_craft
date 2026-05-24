import 'package:learn_craft/features/quiz/data/models/question_model.dart';
import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.courseId,
    required super.lessonId,
    required super.title,
    required super.totalQuestions,
    required super.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'lessonId': lessonId,
      'title': title,
      'totalQuestions': totalQuestions,
      'questions': questions
          .cast<QuestionModel>()
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
