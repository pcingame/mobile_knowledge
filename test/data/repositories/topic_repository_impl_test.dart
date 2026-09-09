import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knowledge_mobile/data/datasources/topic_local_data_source.dart';
import 'package:knowledge_mobile/data/models/topic_model.dart';
import 'package:knowledge_mobile/data/repositories/topic_repository_impl.dart';

class MockTopicLocalDataSource extends Mock implements TopicLocalDataSource {}

void main() {
  late MockTopicLocalDataSource dataSource;
  late TopicRepositoryImpl repository;

  setUp(() {
    dataSource = MockTopicLocalDataSource();
    repository = TopicRepositoryImpl(dataSource);
  });

  test('delegates getTopics to the local data source', () async {
    const models = [
      TopicModel(id: 't1', title: 'Topic 1', flashcards: [], quiz: [], notes: []),
    ];
    when(() => dataSource.getTopics()).thenAnswer((_) async => models);

    final result = await repository.getTopics();

    expect(result, same(models));
    verify(() => dataSource.getTopics()).called(1);
  });

  test('propagates data source errors', () async {
    when(() => dataSource.getTopics()).thenThrow(Exception('read failed'));

    expect(() => repository.getTopics(), throwsA(isA<Exception>()));
  });
}
