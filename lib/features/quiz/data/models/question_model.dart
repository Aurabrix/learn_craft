import 'package:learn_craft/features/quiz/domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.questionText,
    required super.options,
    required super.correctOptionIndex,
    required super.explanation,
    required super.xpPoints,
    required super.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      xpPoints: json['xpPoints'] ?? 10,
      difficulty: json['difficulty'] ?? 'Easy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'xpPoints': xpPoints,
      'difficulty': difficulty,
    };
  }
}
