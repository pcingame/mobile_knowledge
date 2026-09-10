import '../../domain/entities/quiz_attempt.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';

/// Caps how many past attempts are kept per topic — enough to show a
/// meaningful trend without the stored history growing unbounded.
const int _maxHistoryPerTopic = 20;

class ProgressRepositoryImpl extends ProgressRepository {
  ProgressRepositoryImpl(this._dataSource);

  final ProgressLocalDataSource _dataSource;

  Set<String> _learned = {};
  Set<String> _bookmarked = {};
  final Map<String, List<QuizAttempt>> _history = {};

  String _flashcardKey(String topicId, int index) => '$topicId:$index';

  @override
  Future<void> init() async {
    _learned = _dataSource.getLearned();
    _bookmarked = _dataSource.getBookmarked();
  }

  @override
  bool isFlashcardLearned(String topicId, int flashcardIndex) =>
      _learned.contains(_flashcardKey(topicId, flashcardIndex));

  @override
  Future<void> toggleFlashcardLearned(String topicId, int flashcardIndex) async {
    final key = _flashcardKey(topicId, flashcardIndex);
    if (!_learned.remove(key)) _learned.add(key);
    await _dataSource.setLearned(_learned);
    notifyListeners();
  }

  @override
  bool isFlashcardBookmarked(String topicId, int flashcardIndex) =>
      _bookmarked.contains(_flashcardKey(topicId, flashcardIndex));

  @override
  Future<void> toggleFlashcardBookmarked(String topicId, int flashcardIndex) async {
    final key = _flashcardKey(topicId, flashcardIndex);
    if (!_bookmarked.remove(key)) _bookmarked.add(key);
    await _dataSource.setBookmarked(_bookmarked);
    notifyListeners();
  }

  @override
  Set<String> get bookmarkedFlashcardKeys => Set.unmodifiable(_bookmarked);

  List<QuizAttempt> _historyFor(String topicId) {
    return _history.putIfAbsent(topicId, () {
      return _dataSource.getQuizHistory(topicId).map((raw) {
        return QuizAttempt(
          score: raw['score'] as int,
          total: raw['total'] as int,
          takenAt: DateTime.parse(raw['takenAt'] as String),
        );
      }).toList();
    });
  }

  @override
  QuizAttempt? bestQuizAttempt(String topicId) {
    final history = _historyFor(topicId);
    if (history.isEmpty) return null;
    return history.reduce((best, next) => next.ratio > best.ratio ? next : best);
  }

  @override
  QuizAttempt? lastQuizAttempt(String topicId) {
    final history = _historyFor(topicId);
    return history.isEmpty ? null : history.last;
  }

  @override
  Future<void> recordQuizAttempt(String topicId, int score, int total) async {
    final history = _historyFor(topicId);
    history.add(QuizAttempt(score: score, total: total, takenAt: DateTime.now()));
    if (history.length > _maxHistoryPerTopic) {
      history.removeRange(0, history.length - _maxHistoryPerTopic);
    }
    await _dataSource.setQuizHistory(
      topicId,
      history
          .map((a) => {'score': a.score, 'total': a.total, 'takenAt': a.takenAt.toIso8601String()})
          .toList(),
    );
    notifyListeners();
  }
}
