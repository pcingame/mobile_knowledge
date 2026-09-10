import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knowledge_mobile/data/datasources/progress_local_data_source.dart';
import 'package:knowledge_mobile/data/repositories/progress_repository_impl.dart';

class MockProgressLocalDataSource extends Mock implements ProgressLocalDataSource {}

void main() {
  late MockProgressLocalDataSource dataSource;
  late ProgressRepositoryImpl repository;

  setUp(() async {
    dataSource = MockProgressLocalDataSource();
    when(() => dataSource.getLearned()).thenReturn({});
    when(() => dataSource.getBookmarked()).thenReturn({});
    when(() => dataSource.getQuizHistory(any())).thenReturn([]);
    when(() => dataSource.setLearned(any())).thenAnswer((_) async {});
    when(() => dataSource.setBookmarked(any())).thenAnswer((_) async {});
    when(() => dataSource.setQuizHistory(any(), any())).thenAnswer((_) async {});

    repository = ProgressRepositoryImpl(dataSource);
    await repository.init();
  });

  test('a flashcard is not learned or bookmarked before any toggle', () {
    expect(repository.isFlashcardLearned('t1', 0), isFalse);
    expect(repository.isFlashcardBookmarked('t1', 0), isFalse);
  });

  test('toggleFlashcardLearned flips state, persists it, and notifies listeners', () async {
    var notified = 0;
    repository.addListener(() => notified++);

    await repository.toggleFlashcardLearned('t1', 2);
    expect(repository.isFlashcardLearned('t1', 2), isTrue);
    expect(notified, 1);
    verify(() => dataSource.setLearned({'t1:2'})).called(1);

    await repository.toggleFlashcardLearned('t1', 2);
    expect(repository.isFlashcardLearned('t1', 2), isFalse);
    expect(notified, 2);
  });

  test('toggling one flashcard does not affect another', () async {
    await repository.toggleFlashcardLearned('t1', 0);
    expect(repository.isFlashcardLearned('t1', 1), isFalse);
    expect(repository.isFlashcardLearned('t2', 0), isFalse);
  });

  test('toggleFlashcardBookmarked flips state and appears in bookmarkedFlashcardKeys', () async {
    await repository.toggleFlashcardBookmarked('android', 5);
    expect(repository.isFlashcardBookmarked('android', 5), isTrue);
    expect(repository.bookmarkedFlashcardKeys, {'android:5'});

    await repository.toggleFlashcardBookmarked('android', 5);
    expect(repository.bookmarkedFlashcardKeys, isEmpty);
  });

  test('bestQuizAttempt and lastQuizAttempt are null before any attempt', () {
    expect(repository.bestQuizAttempt('t1'), isNull);
    expect(repository.lastQuizAttempt('t1'), isNull);
  });

  test('recordQuizAttempt updates lastQuizAttempt and persists history', () async {
    await repository.recordQuizAttempt('t1', 7, 10);

    final last = repository.lastQuizAttempt('t1');
    expect(last?.score, 7);
    expect(last?.total, 10);
    verify(() => dataSource.setQuizHistory('t1', any())).called(1);
  });

  test('bestQuizAttempt picks the highest-ratio attempt, lastQuizAttempt picks the most recent', () async {
    await repository.recordQuizAttempt('t1', 5, 10); // 50%
    await repository.recordQuizAttempt('t1', 9, 10); // 90% — best
    await repository.recordQuizAttempt('t1', 6, 10); // 60% — most recent

    expect(repository.bestQuizAttempt('t1')?.score, 9);
    expect(repository.lastQuizAttempt('t1')?.score, 6);
  });

  test('quiz history is capped at 20 attempts per topic', () async {
    for (var i = 0; i < 25; i++) {
      await repository.recordQuizAttempt('t1', i, 25);
    }

    final captured = verify(() => dataSource.setQuizHistory('t1', captureAny())).captured;
    final lastPersisted = captured.last as List<Map<String, dynamic>>;
    expect(lastPersisted.length, 20);
    // The oldest 5 attempts (score 0-4) should have been dropped.
    expect(lastPersisted.first['score'], 5);
    expect(lastPersisted.last['score'], 24);
  });
}
