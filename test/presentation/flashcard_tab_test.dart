import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/domain/entities/app_language.dart';
import 'package:knowledge_mobile/domain/entities/flashcard.dart';
import 'package:knowledge_mobile/domain/entities/localized_text.dart';
import 'package:knowledge_mobile/domain/entities/quiz_attempt.dart';
import 'package:knowledge_mobile/domain/repositories/progress_repository.dart';
import 'package:knowledge_mobile/presentation/widgets/flashcard_tab.dart';

/// An in-memory [ProgressRepository] — real toggling behavior, no disk I/O,
/// so these widget tests can exercise the filter/toggle logic directly.
class _InMemoryProgressRepository extends ChangeNotifier implements ProgressRepository {
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
  const flashcards = [
    Flashcard(
      question: LocalizedText(en: 'Q1', vi: 'H1'),
      answer: LocalizedText(en: 'A1', vi: 'D1'),
    ),
    Flashcard(
      question: LocalizedText(en: 'Q2', vi: 'H2'),
      answer: LocalizedText(en: 'A2', vi: 'D2'),
    ),
    Flashcard(
      question: LocalizedText(en: 'Q3', vi: 'H3'),
      answer: LocalizedText(en: 'A3', vi: 'D3'),
    ),
  ];

  Widget buildTab(ProgressRepository repo) => MaterialApp(
        home: Scaffold(
          body: FlashcardTab(
            flashcards: flashcards,
            language: AppLanguage.en,
            topicId: 't1',
            progressRepository: repo,
          ),
        ),
      );

  testWidgets('shows the first card and the total count', (tester) async {
    await tester.pumpWidget(buildTab(_InMemoryProgressRepository()));

    expect(find.text('Q1'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('tapping the learned button marks the current card learned', (tester) async {
    final repo = _InMemoryProgressRepository();
    await tester.pumpWidget(buildTab(repo));

    expect(repo.isFlashcardLearned('t1', 0), isFalse);
    await tester.tap(find.byTooltip('Mark as learned'));
    await tester.pumpAndSettle();

    expect(repo.isFlashcardLearned('t1', 0), isTrue);
  });

  testWidgets('tapping the bookmark button bookmarks the current card', (tester) async {
    final repo = _InMemoryProgressRepository();
    await tester.pumpWidget(buildTab(repo));

    await tester.tap(find.byTooltip('Bookmark'));
    await tester.pumpAndSettle();

    expect(repo.bookmarkedFlashcardKeys, {'t1:0'});
  });

  testWidgets('the "show unlearned only" filter hides a learned card and updates the count', (
    tester,
  ) async {
    final repo = _InMemoryProgressRepository();
    await repo.toggleFlashcardLearned('t1', 0); // Q1 already learned before the tab even opens.
    await tester.pumpWidget(buildTab(repo));
    await tester.pumpAndSettle();

    // Filter off (default): all 3 cards, starting at Q1.
    expect(find.text('Q1'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.byTooltip('Show unlearned only'));
    await tester.pumpAndSettle();

    // Filter on: Q1 is skipped, Q2 is now first of 2 remaining.
    expect(find.text('Q2'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('marking the current card learned while filtered removes it from the deck', (
    tester,
  ) async {
    final repo = _InMemoryProgressRepository();
    await tester.pumpWidget(buildTab(repo));
    await tester.tap(find.byTooltip('Show unlearned only'));
    await tester.pumpAndSettle();

    expect(find.text('Q1'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark as learned'));
    await tester.pumpAndSettle();

    // Q1 dropped out of the filtered deck; Q2 takes its place.
    expect(find.text('Q2'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('shows a celebratory empty state once every card is learned, while filtered', (
    tester,
  ) async {
    final repo = _InMemoryProgressRepository();
    await repo.toggleFlashcardLearned('t1', 0);
    await repo.toggleFlashcardLearned('t1', 1);
    await repo.toggleFlashcardLearned('t1', 2);
    await tester.pumpWidget(buildTab(repo));
    await tester.tap(find.byTooltip('Show unlearned only'));
    await tester.pumpAndSettle();

    expect(find.text('0/0'), findsOneWidget);
    expect(find.textContaining('All caught up'), findsOneWidget);
  });
}
