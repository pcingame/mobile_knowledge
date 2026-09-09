import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/flashcard_model.dart';

void main() {
  test('fromJson parses question and answer', () {
    final model = FlashcardModel.fromJson({'question': 'What is Q?', 'answer': 'This is A.'});

    expect(model.question, 'What is Q?');
    expect(model.answer, 'This is A.');
  });
}
