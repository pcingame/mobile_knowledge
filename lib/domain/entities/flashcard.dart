import 'localized_text.dart';

/// A question/answer pair used in the flashcard study mode.
class Flashcard {
  final LocalizedText question;
  final LocalizedText answer;

  const Flashcard({required this.question, required this.answer});
}
