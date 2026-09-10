/// One completed run through a topic's quiz, recorded locally so a user
/// can see their best/most recent score without a backend.
class QuizAttempt {
  final int score;
  final int total;
  final DateTime takenAt;

  const QuizAttempt({required this.score, required this.total, required this.takenAt});

  double get ratio => total == 0 ? 0 : score / total;
}
