import 'package:flutter/material.dart';

import '../../domain/entities/quiz_question.dart';

class QuizTab extends StatefulWidget {
  const QuizTab({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  QuizQuestion get _current => widget.questions[_index];

  void _selectOption(int optionIndex) {
    if (_selected != null) return; // already answered this question
    setState(() {
      _selected = optionIndex;
      if (optionIndex == _current.answerIndex) _score++;
    });
  }

  void _next() {
    if (_index == widget.questions.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Center(child: Text('Chưa có câu hỏi trắc nghiệm nào.'));
    }
    if (_finished) {
      return _QuizResult(
        score: _score,
        total: widget.questions.length,
        onRestart: _restart,
      );
    }

    final theme = Theme.of(context);
    final answered = _selected != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu ${_index + 1}/${widget.questions.length}', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(_current.question, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          for (var i = 0; i < _current.options.length; i++) _buildOption(context, i),
          if (answered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_current.explanation, style: theme.textTheme.bodySmall),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Text(_index == widget.questions.length - 1 ? 'Xem kết quả' : 'Câu tiếp theo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, int i) {
    final theme = Theme.of(context);
    final option = _current.options[i];
    final answered = _selected != null;

    Color? tileColor;
    IconData? trailingIcon;
    if (answered) {
      if (i == _current.answerIndex) {
        tileColor = Colors.green.withValues(alpha: 0.15);
        trailingIcon = Icons.check_circle;
      } else if (i == _selected) {
        tileColor = Colors.red.withValues(alpha: 0.15);
        trailingIcon = Icons.cancel;
      }
    }

    return Card(
      color: tileColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => _selectOption(i),
        title: Text(option),
        trailing: trailingIcon != null
            ? Icon(trailingIcon, color: i == _current.answerIndex ? Colors.green : Colors.red)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class _QuizResult extends StatelessWidget {
  const _QuizResult({required this.score, required this.total, required this.onRestart});

  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total == 0 ? 0 : (score / total * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Bạn đúng $score/$total câu ($percent%)', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm lại'),
            ),
          ],
        ),
      ),
    );
  }
}
