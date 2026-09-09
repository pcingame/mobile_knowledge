class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answerIndex: json['answerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }
}
