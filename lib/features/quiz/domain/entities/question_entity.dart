class QuestionEntity {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int xpPoints;
  final String difficulty;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.xpPoints,
    required this.difficulty,
  });
}
