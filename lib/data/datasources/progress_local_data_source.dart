import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Raw SharedPreferences access for study progress. Kept deliberately dumb
/// (get/set primitives only) — [ProgressRepositoryImpl] owns the actual
/// key-building and business logic on top of this.
class ProgressLocalDataSource {
  ProgressLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _learnedKey = 'progress_learned_flashcards';
  static const _bookmarkedKey = 'progress_bookmarked_flashcards';
  static const _historyKeyPrefix = 'progress_quiz_history_';

  Set<String> getLearned() => (_prefs.getStringList(_learnedKey) ?? const []).toSet();

  Future<void> setLearned(Set<String> keys) => _prefs.setStringList(_learnedKey, keys.toList());

  Set<String> getBookmarked() => (_prefs.getStringList(_bookmarkedKey) ?? const []).toSet();

  Future<void> setBookmarked(Set<String> keys) =>
      _prefs.setStringList(_bookmarkedKey, keys.toList());

  /// Each entry is a raw {score, total, takenAt} map, oldest first.
  List<Map<String, dynamic>> getQuizHistory(String topicId) {
    final raw = _prefs.getString('$_historyKeyPrefix$topicId');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> setQuizHistory(String topicId, List<Map<String, dynamic>> history) =>
      _prefs.setString('$_historyKeyPrefix$topicId', jsonEncode(history));
}
