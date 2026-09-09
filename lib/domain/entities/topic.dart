import 'flashcard.dart';
import 'note.dart';
import 'quiz_question.dart';

/// One top-level subject area (e.g. Flutter/Dart, Android, iOS) bundling
/// all three study modes for that subject.
class Topic {
  final String id;
  final String title;
  final List<Flashcard> flashcards;
  final List<QuizQuestion> quiz;
  final List<Note> notes;

  const Topic({
    required this.id,
    required this.title,
    required this.flashcards,
    required this.quiz,
    required this.notes,
  });
}
