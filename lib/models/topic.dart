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

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      flashcards: (json['flashcards'] as List)
          .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
