import 'package:flutter/foundation.dart';

import '../entities/quiz_attempt.dart';

/// Tracks a user's local study progress: which flashcards are marked
/// learned, which are bookmarked, and quiz attempt history — all purely
/// on-device (there's no backend, so local storage is the only source of
/// truth). Extends [ChangeNotifier] so widgets can rebuild on change the
/// same way they already listen to the EN/VI language toggle.
abstract class ProgressRepository extends ChangeNotifier {
  /// Loads persisted progress from disk. Must complete before any other
  /// member is read.
  Future<void> init();

  bool isFlashcardLearned(String topicId, int flashcardIndex);
  Future<void> toggleFlashcardLearned(String topicId, int flashcardIndex);

  bool isFlashcardBookmarked(String topicId, int flashcardIndex);
  Future<void> toggleFlashcardBookmarked(String topicId, int flashcardIndex);

  /// Every bookmarked flashcard, as "topicId:index" keys — the presentation
  /// layer resolves these back to actual [Flashcard]s from the loaded topics.
  Set<String> get bookmarkedFlashcardKeys;

  /// The highest-scoring attempt recorded for [topicId], or null if the
  /// quiz has never been completed.
  QuizAttempt? bestQuizAttempt(String topicId);

  /// The most recently recorded attempt for [topicId], or null.
  QuizAttempt? lastQuizAttempt(String topicId);

  Future<void> recordQuizAttempt(String topicId, int score, int total);
}
