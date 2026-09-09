import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/topic_model.dart';

void main() {
  test('fromJson parses id, title, and nested flashcards/quiz/notes', () {
    final json = {
      'id': 'flutter_dart',
      'title': 'Flutter & Dart',
      'flashcards': [
        {'question': 'Q1', 'answer': 'A1'},
      ],
      'quiz': [
        {
          'question': 'Which?',
          'options': ['A', 'B'],
          'answerIndex': 1,
          'explanation': 'Because B.',
        },
      ],
      'notes': [
        {'title': 'Note title', 'content': 'Note content'},
      ],
    };

    final topic = TopicModel.fromJson(json);

    expect(topic.id, 'flutter_dart');
    expect(topic.title, 'Flutter & Dart');

    expect(topic.flashcards, hasLength(1));
    expect(topic.flashcards.first.question, 'Q1');
    expect(topic.flashcards.first.answer, 'A1');

    expect(topic.quiz, hasLength(1));
    expect(topic.quiz.first.options, ['A', 'B']);
    expect(topic.quiz.first.answerIndex, 1);
    expect(topic.quiz.first.explanation, 'Because B.');

    expect(topic.notes, hasLength(1));
    expect(topic.notes.first.title, 'Note title');
    expect(topic.notes.first.content, 'Note content');
  });

  test('fromJson handles empty flashcards/quiz/notes lists', () {
    final topic = TopicModel.fromJson({
      'id': 'general',
      'title': 'General',
      'flashcards': [],
      'quiz': [],
      'notes': [],
    });

    expect(topic.flashcards, isEmpty);
    expect(topic.quiz, isEmpty);
    expect(topic.notes, isEmpty);
  });
}
