import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/flashcard.dart';
import '../theme/app_spacing.dart';

class FlashcardTab extends StatefulWidget {
  const FlashcardTab({super.key, required this.flashcards, required this.language});

  final List<Flashcard> flashcards;
  final AppLanguage language;

  @override
  State<FlashcardTab> createState() => _FlashcardTabState();
}

class _FlashcardTabState extends State<FlashcardTab> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _showAnswer = false;

  bool get _isEn => widget.language == AppLanguage.en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return const _EmptyTab(icon: Icons.style_outlined, message: 'Chưa có flashcard nào.');
    }
    final theme = Theme.of(context);
    final progress = (_index + 1) / widget.flashcards.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(value: progress, minHeight: 6),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('${_index + 1}/${widget.flashcards.length}', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.flashcards.length,
            onPageChanged: (i) => setState(() {
              _index = i;
              _showAnswer = false;
            }),
            itemBuilder: (context, i) {
              final card = widget.flashcards[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _showAnswer = !_showAnswer),
                  child: _FlippingFace(
                    showAnswer: _showAnswer,
                    question: card.question.of(widget.language),
                    answer: card.answer.of(widget.language),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 15, color: theme.colorScheme.outline),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _isEn
                    ? 'Tap to flip · swipe to move on'
                    : 'Chạm để lật ${_showAnswer ? "câu hỏi" : "đáp án"} · vuốt để chuyển thẻ',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A 3D-ish flip between the question and answer faces, driven by
/// [showAnswer] so PageView swipes (which rebuild this widget fresh)
/// never fight the animation.
class _FlippingFace extends StatelessWidget {
  const _FlippingFace({required this.showAnswer, required this.question, required this.answer});

  final bool showAnswer;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: showAnswer ? 1 : 0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
      builder: (context, t, _) {
        final angle = t * math.pi;
        final showingBack = angle > math.pi / 2;
        final display = showingBack
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _FlashcardFace(text: answer, isAnswer: true),
              )
            : _FlashcardFace(text: question, isAnswer: false);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: display,
        );
      },
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({required this.text, required this.isAnswer});

  final String text;
  final bool isAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: isAnswer
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
              )
            : null,
        color: isAnswer ? null : scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: isAnswer ? 0 : 0.5)),
        boxShadow: [
          BoxShadow(
            color: (isAnswer ? scheme.primary : Colors.black).withValues(alpha: isAnswer ? 0.28 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAnswer ? Icons.check_circle_rounded : Icons.help_rounded,
                    color: isAnswer ? scheme.onPrimary : scheme.primary,
                    size: 26,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isAnswer ? scheme.onPrimary : scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
