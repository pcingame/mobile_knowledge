import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knowledge_mobile/domain/entities/app_language.dart';
import 'package:knowledge_mobile/domain/entities/flashcard.dart';
import 'package:knowledge_mobile/domain/entities/localized_text.dart';
import 'package:knowledge_mobile/domain/entities/quiz_attempt.dart';
import 'package:knowledge_mobile/domain/entities/topic.dart';
import 'package:knowledge_mobile/domain/repositories/progress_repository.dart';
import 'package:knowledge_mobile/domain/usecases/get_topics.dart';
import 'package:knowledge_mobile/presentation/screens/home_screen.dart';

class MockGetTopics extends Mock implements GetTopics {}

/// A no-op progress store — these tests only exercise topic loading/EN-VI
/// toggling, not bookmarking/scoring, which have their own tests.
class _FakeProgressRepository extends ChangeNotifier implements ProgressRepository {
  final _learned = <String>{};
  final _bookmarked = <String>{};

  @override
  Future<void> init() async {}

  @override
  bool isFlashcardLearned(String topicId, int flashcardIndex) =>
      _learned.contains('$topicId:$flashcardIndex');

  @override
  Future<void> toggleFlashcardLearned(String topicId, int flashcardIndex) async {
    final key = '$topicId:$flashcardIndex';
    if (!_learned.remove(key)) _learned.add(key);
    notifyListeners();
  }

  @override
  bool isFlashcardBookmarked(String topicId, int flashcardIndex) =>
      _bookmarked.contains('$topicId:$flashcardIndex');

  @override
  Future<void> toggleFlashcardBookmarked(String topicId, int flashcardIndex) async {
    final key = '$topicId:$flashcardIndex';
    if (!_bookmarked.remove(key)) _bookmarked.add(key);
    notifyListeners();
  }

  @override
  Set<String> get bookmarkedFlashcardKeys => Set.unmodifiable(_bookmarked);

  @override
  QuizAttempt? bestQuizAttempt(String topicId) => null;

  @override
  QuizAttempt? lastQuizAttempt(String topicId) => null;

  @override
  Future<void> recordQuizAttempt(String topicId, int score, int total) async {}
}

void main() {
  testWidgets('shows a loading indicator, then each topic with its counts', (tester) async {
    final getTopics = MockGetTopics();
    const topics = [
      Topic(
        id: 'flutter_dart',
        title: LocalizedText(en: 'Flutter & Dart', vi: 'Flutter & Dart'),
        flashcards: [
          Flashcard(
            question: LocalizedText(en: 'Q', vi: 'C'),
            answer: LocalizedText(en: 'A', vi: 'D'),
          ),
        ],
        quiz: [],
        notes: [],
      ),
    ];
    when(() => getTopics()).thenAnswer((_) async => topics);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        getTopics: getTopics,
        language: ValueNotifier(AppLanguage.en),
        progressRepository: _FakeProgressRepository(),
      ),
    ));

    // Before the future resolves: loading indicator only.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Flutter & Dart'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Flutter & Dart'), findsOneWidget);
    expect(find.textContaining('1 flashcard'), findsOneWidget);
  });

  testWidgets('shows an error message when loading fails', (tester) async {
    final getTopics = MockGetTopics();
    when(() => getTopics()).thenAnswer((_) => Future.error(Exception('network down')));

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        getTopics: getTopics,
        language: ValueNotifier(AppLanguage.en),
        progressRepository: _FakeProgressRepository(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Không tải được dữ liệu'), findsOneWidget);
  });

  testWidgets('the EN/VI toggle switches the displayed topic title', (tester) async {
    final getTopics = MockGetTopics();
    const topics = [
      Topic(
        id: 'general',
        title: LocalizedText(en: 'General Mobile Knowledge', vi: 'Kiến thức chung Mobile'),
        flashcards: [],
        quiz: [],
        notes: [],
      ),
    ];
    when(() => getTopics()).thenAnswer((_) async => topics);
    final language = ValueNotifier(AppLanguage.en);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        getTopics: getTopics,
        language: language,
        progressRepository: _FakeProgressRepository(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('General Mobile Knowledge'), findsOneWidget);

    await tester.tap(find.text('VI'));
    await tester.pumpAndSettle();

    expect(find.text('Kiến thức chung Mobile'), findsOneWidget);
    expect(language.value, AppLanguage.vi);
  });
}
