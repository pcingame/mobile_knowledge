// Parses every bundled assets/data/*.json file through TopicModel.fromJson
// to catch a malformed content file before it ships.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/data/datasources/topic_local_data_source.dart' show topicAssetIds;
import 'package:knowledge_mobile/data/models/topic_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final id in topicAssetIds) {
    test('assets/data/$id.json parses into a well-formed, bilingual TopicModel', () async {
      final raw = await rootBundle.loadString('assets/data/$id.json');
      final topic = TopicModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      expect(topic.id, id);
      expect(topic.title.en, isNotEmpty);
      expect(topic.title.vi, isNotEmpty);
      expect(topic.flashcards, isNotEmpty);
      expect(topic.quiz, isNotEmpty);
      expect(topic.notes, isNotEmpty);

      for (final fc in topic.flashcards) {
        expect(fc.question.en, isNotEmpty);
        expect(fc.question.vi, isNotEmpty);
        expect(fc.answer.en, isNotEmpty);
        expect(fc.answer.vi, isNotEmpty);
      }

      for (final q in topic.quiz) {
        expect(q.question.en, isNotEmpty);
        expect(q.question.vi, isNotEmpty);
        expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
        for (final option in q.options) {
          expect(option.en, isNotEmpty);
          expect(option.vi, isNotEmpty);
        }
      }

      for (final note in topic.notes) {
        expect(note.title.en, isNotEmpty);
        expect(note.title.vi, isNotEmpty);
        expect(note.content.en, isNotEmpty);
        expect(note.content.vi, isNotEmpty);
      }
    });
  }
}
