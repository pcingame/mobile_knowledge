import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knowledge_mobile/domain/entities/localized_text.dart';
import 'package:knowledge_mobile/domain/entities/topic.dart';
import 'package:knowledge_mobile/domain/repositories/topic_repository.dart';
import 'package:knowledge_mobile/domain/usecases/get_topics.dart';

class MockTopicRepository extends Mock implements TopicRepository {}

void main() {
  late MockTopicRepository repository;
  late GetTopics usecase;

  setUp(() {
    repository = MockTopicRepository();
    usecase = GetTopics(repository);
  });

  test('returns exactly what the repository returns', () async {
    const topics = [
      Topic(
        id: 't1',
        title: LocalizedText(en: 'Topic 1', vi: 'Chủ đề 1'),
        flashcards: [],
        quiz: [],
        notes: [],
      ),
    ];
    when(() => repository.getTopics()).thenAnswer((_) async => topics);

    final result = await usecase();

    expect(result, same(topics));
    verify(() => repository.getTopics()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('propagates repository errors', () async {
    when(() => repository.getTopics()).thenThrow(Exception('boom'));

    expect(() => usecase(), throwsA(isA<Exception>()));
  });
}
