import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/topic_model.dart';

void main() {
  test('fromJson parses id, bilingual title, and nested flashcards/quiz/notes', () {
    final json = {
      'id': 'flutter_dart',
      'title': {'en': 'Flutter & Dart', 'vi': 'Flutter & Dart'},
      'flashcards': [
        {
          'question': {'en': 'Q1', 'vi': 'C1'},
          'answer': {'en': 'A1', 'vi': 'D1'},
        },
      ],
      'quiz': [
        {
          'question': {'en': 'Which?', 'vi': 'Cái nào?'},
          'options': [
            {'en': 'A', 'vi': 'A'},
            {'en': 'B', 'vi': 'B'},
          ],
          'answerIndex': 1,
          'explanation': {'en': 'Because B.', 'vi': 'Vì B.'},
        },
      ],
      'notes': [
        {
          'title': {'en': 'Note title', 'vi': 'Tiêu đề ghi chú'},
          'content': {'en': 'Note content', 'vi': 'Nội dung ghi chú'},
        },
      ],
    };

    final topic = TopicModel.fromJson(json);

    expect(topic.id, 'flutter_dart');
    expect(topic.title.en, 'Flutter & Dart');

    expect(topic.flashcards, hasLength(1));
    expect(topic.flashcards.first.question.en, 'Q1');
    expect(topic.flashcards.first.answer.vi, 'D1');

    expect(topic.quiz, hasLength(1));
    expect(topic.quiz.first.options.map((o) => o.en).toList(), ['A', 'B']);
    expect(topic.quiz.first.answerIndex, 1);
    expect(topic.quiz.first.explanation.vi, 'Vì B.');

    expect(topic.notes, hasLength(1));
    expect(topic.notes.first.title.en, 'Note title');
    expect(topic.notes.first.content.vi, 'Nội dung ghi chú');
  });

  test('fromJson handles empty flashcards/quiz/notes lists', () {
    final topic = TopicModel.fromJson({
      'id': 'general',
      'title': {'en': 'General', 'vi': 'Chung'},
      'flashcards': [],
      'quiz': [],
      'notes': [],
    });

    expect(topic.flashcards, isEmpty);
    expect(topic.quiz, isEmpty);
    expect(topic.notes, isEmpty);
  });
}
