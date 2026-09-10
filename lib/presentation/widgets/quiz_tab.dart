import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

class QuizTab extends StatefulWidget {
  const QuizTab({
    super.key,
    required this.questions,
    required this.language,
    required this.topicId,
    required this.progressRepository,
  });

  final List<QuizQuestion> questions;
  final AppLanguage language;
  final String topicId;
  final ProgressRepository progressRepository;

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  bool get _isEn => widget.language == AppLanguage.en;
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
      widget.progressRepository.recordQuizAttempt(widget.topicId, _score, widget.questions.length);
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
      return Center(
        child: Text(
          'Chưa có câu hỏi trắc nghiệm nào.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    if (_finished) {
      return _QuizResult(
        score: _score,
        total: widget.questions.length,
        isEn: _isEn,
        onRestart: _restart,
        best: widget.progressRepository.bestQuizAttempt(widget.topicId),
      );
    }

    final theme = Theme.of(context);
    final answered = _selected != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / widget.questions.length,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${_index + 1}/${widget.questions.length}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _current.question.of(widget.language),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < _current.options.length; i++) ...[
            _OptionTile(
              letter: String.fromCharCode(65 + i),
              text: _current.options[i].of(widget.language),
              state: !answered
                  ? _OptionState.idle
                  : i == _current.answerIndex
                  ? _OptionState.correct
                  : i == _selected
                  ? _OptionState.wrong
                  : _OptionState.disabled,
              onTap: () => _selectOption(i),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (answered) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _current.explanation.of(widget.language),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  _index == widget.questions.length - 1
                      ? (_isEn ? 'See results' : 'Xem kết quả')
                      : (_isEn ? 'Next question' : 'Câu tiếp theo'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, disabled }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color badgeBg;
    Color badgeFg;
    Color borderColor;
    IconData? trailing;
    switch (state) {
      case _OptionState.idle:
        badgeBg = scheme.surfaceContainerHighest;
        badgeFg = scheme.onSurfaceVariant;
        borderColor = scheme.outlineVariant;
        trailing = null;
      case _OptionState.correct:
        badgeBg = scheme.primary;
        badgeFg = scheme.onPrimary;
        borderColor = scheme.primary;
        trailing = Icons.check_circle_rounded;
      case _OptionState.wrong:
        badgeBg = scheme.error;
        badgeFg = scheme.onError;
        borderColor = scheme.error;
        trailing = Icons.cancel_rounded;
      case _OptionState.disabled:
        badgeBg = scheme.surfaceContainerHighest;
        badgeFg = scheme.onSurfaceVariant.withValues(alpha: 0.5);
        borderColor = scheme.outlineVariant.withValues(alpha: 0.5);
        trailing = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor,
          width: state == _OptionState.idle ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: badgeBg,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontFamily: AppTheme.displayFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: badgeFg,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: state == _OptionState.disabled
                          ? scheme.onSurface.withValues(alpha: 0.5)
                          : null,
                    ),
                  ),
                ),
                if (trailing != null)
                  Icon(
                    trailing,
                    size: 20,
                    color: state == _OptionState.correct
                        ? scheme.primary
                        : scheme.error,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizResult extends StatelessWidget {
  const _QuizResult({
    required this.score,
    required this.total,
    required this.isEn,
    required this.onRestart,
    required this.best,
  });

  final int score;
  final int total;
  final bool isEn;
  final VoidCallback onRestart;
  final QuizAttempt? best;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ratio = total == 0 ? 0.0 : score / total;
    final percent = (ratio * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$percent%', style: theme.textTheme.headlineMedium),
                      Text(
                        '$score/$total',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              isEn ? 'Quiz complete' : 'Hoàn thành quiz',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isEn
                  ? (ratio >= 0.8
                        ? 'Great work — you know this well.'
                        : 'Review the misses and try again.')
                  : (ratio >= 0.8
                        ? 'Rất tốt — bạn nắm chắc phần này.'
                        : 'Xem lại câu sai rồi làm lại nhé.'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (best != null && (best!.score != score || best!.total != total)) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                isEn
                    ? 'Best score: ${best!.score}/${best!.total}'
                    : 'Điểm tốt nhất: ${best!.score}/${best!.total}',
                style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isEn ? 'Retry' : 'Làm lại'),
            ),
          ],
        ),
      ),
    );
  }
}
