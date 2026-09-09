import 'localized_text.dart';

/// A multiple-choice question used in the quiz study mode.
class QuizQuestion {
  final LocalizedText question;
  final List<LocalizedText> options;
  final int answerIndex;
  final LocalizedText explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });
}
