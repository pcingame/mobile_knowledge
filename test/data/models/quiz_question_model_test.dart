import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/quiz_question_model.dart';

void main() {
  test('fromJson parses bilingual question, options, answerIndex, and explanation', () {
    final model = QuizQuestionModel.fromJson({
      'question': {'en': 'Which one?', 'vi': 'Cái nào?'},
      'options': [
        {'en': 'A', 'vi': 'A'},
        {'en': 'B', 'vi': 'B'},
        {'en': 'C', 'vi': 'C'},
      ],
      'answerIndex': 2,
      'explanation': {'en': 'Because C.', 'vi': 'Vì C.'},
    });

    expect(model.question.en, 'Which one?');
    expect(model.question.vi, 'Cái nào?');
    expect(model.options.map((o) => o.en).toList(), ['A', 'B', 'C']);
    expect(model.answerIndex, 2);
    expect(model.explanation.en, 'Because C.');
    expect(model.explanation.vi, 'Vì C.');
  });
}
