import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/flashcard_model.dart';

void main() {
  test('fromJson parses bilingual question and answer', () {
    final model = FlashcardModel.fromJson({
      'question': {'en': 'What is Q?', 'vi': 'Q là gì?'},
      'answer': {'en': 'This is A.', 'vi': 'Đây là A.'},
    });

    expect(model.question.en, 'What is Q?');
    expect(model.question.vi, 'Q là gì?');
    expect(model.answer.en, 'This is A.');
    expect(model.answer.vi, 'Đây là A.');
  });
}
