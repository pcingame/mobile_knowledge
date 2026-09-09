import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/models/note_model.dart';

void main() {
  test('fromJson parses title and content', () {
    final model = NoteModel.fromJson({'title': 'A note', 'content': 'Some content.'});

    expect(model.title, 'A note');
    expect(model.content, 'Some content.');
  });
}
