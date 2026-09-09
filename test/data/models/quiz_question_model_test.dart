import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/quiz_question_model.dart';

void main() {
  test('fromJson parses question, options, answerIndex, and explanation', () {
    final model = QuizQuestionModel.fromJson({
      'question': 'Which one?',
      'options': ['A', 'B', 'C'],
      'answerIndex': 2,
      'explanation': 'Because C.',
    });

    expect(model.question, 'Which one?');
    expect(model.options, ['A', 'B', 'C']);
    expect(model.answerIndex, 2);
    expect(model.explanation, 'Because C.');
  });
}
