import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/note_model.dart';

void main() {
  test('fromJson parses bilingual title and content', () {
    final model = NoteModel.fromJson({
      'title': {'en': 'A note', 'vi': 'Một ghi chú'},
      'content': {'en': 'Some content.', 'vi': 'Nội dung nào đó.'},
    });

    expect(model.title.en, 'A note');
    expect(model.title.vi, 'Một ghi chú');
    expect(model.content.en, 'Some content.');
    expect(model.content.vi, 'Nội dung nào đó.');
  });
}
