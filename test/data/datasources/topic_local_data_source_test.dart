import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knowledge_mobile/data/datasources/topic_local_data_source.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late MockAssetBundle bundle;
  late TopicLocalDataSourceImpl dataSource;

  setUp(() {
    bundle = MockAssetBundle();
    dataSource = TopicLocalDataSourceImpl(bundle: bundle);
  });

  String jsonFor(String id) => jsonEncode({
        'id': id,
        'title': 'Title for $id',
        'flashcards': [
          {'question': 'Q', 'answer': 'A'},
        ],
        'quiz': [],
        'notes': [],
      });

  test('loads and parses every bundled topic asset, in order', () async {
    for (final id in topicAssetIds) {
      when(() => bundle.loadString('assets/data/$id.json')).thenAnswer((_) async => jsonFor(id));
    }

    final topics = await dataSource.getTopics();

    expect(topics.map((t) => t.id).toList(), topicAssetIds);
    expect(topics.first.flashcards.single.question, 'Q');
    for (final id in topicAssetIds) {
      verify(() => bundle.loadString('assets/data/$id.json')).called(1);
    }
  });

  test('throws if an asset is missing', () async {
    for (final id in topicAssetIds) {
      when(() => bundle.loadString('assets/data/$id.json')).thenThrow(
        FlutterError('Unable to load asset'),
      );
    }

    expect(() => dataSource.getTopics(), throwsA(isA<FlutterError>()));
  });
}
