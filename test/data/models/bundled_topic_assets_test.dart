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
    test('assets/data/$id.json parses into a well-formed TopicModel', () async {
      final raw = await rootBundle.loadString('assets/data/$id.json');
      final topic = TopicModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      expect(topic.id, id);
      expect(topic.title, isNotEmpty);
      expect(topic.flashcards, isNotEmpty);
      expect(topic.quiz, isNotEmpty);
      expect(topic.notes, isNotEmpty);

      for (final q in topic.quiz) {
        expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
      }
    });
  }
}
