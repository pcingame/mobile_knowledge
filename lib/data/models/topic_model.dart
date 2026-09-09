import '../../domain/entities/topic.dart';
import 'flashcard_model.dart';
import 'note_model.dart';
import 'quiz_question_model.dart';

class TopicModel extends Topic {
  const TopicModel({
    required super.id,
    required super.title,
    required super.flashcards,
    required super.quiz,
    required super.notes,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      flashcards: (json['flashcards'] as List)
          .map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List)
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List)
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
