import '../../domain/entities/quiz_question.dart';
import 'localized_text_model.dart';

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.question,
    required super.options,
    required super.answerIndex,
    required super.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      question: LocalizedTextModel.fromJson(json['question'] as Map<String, dynamic>),
      options: (json['options'] as List)
          .map((e) => LocalizedTextModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      answerIndex: json['answerIndex'] as int,
      explanation: LocalizedTextModel.fromJson(json['explanation'] as Map<String, dynamic>),
    );
  }
}
