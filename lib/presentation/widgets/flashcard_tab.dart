import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';

class FlashcardTab extends StatefulWidget {
  const FlashcardTab({
    super.key,
    required this.flashcards,
    required this.language,
    required this.topicId,
    required this.progressRepository,
  });

  final List<Flashcard> flashcards;
  final AppLanguage language;
  final String topicId;
  final ProgressRepository progressRepository;

  @override
  State<FlashcardTab> createState() => _FlashcardTabState();
}

class _FlashcardTabState extends State<FlashcardTab> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _showAnswer = false;
  bool _hideLearned = false;

  /// Indices into [widget.flashcards] currently shown, in order. Equal to
  /// every index unless [_hideLearned] is on, in which case it's just the
  /// not-yet-learned ones — recomputed whenever learned-state changes.
  late List<int> _visibleIndices = _computeVisibleIndices();

  bool get _isEn => widget.language == AppLanguage.en;

  @override
  void initState() {
    super.initState();
    widget.progressRepository.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.progressRepository.removeListener(_onProgressChanged);
    _controller.dispose();
    super.dispose();
  }

  List<int> _computeVisibleIndices() {
    if (!_hideLearned) return List.generate(widget.flashcards.length, (i) => i);
    return [
      for (var i = 0; i < widget.flashcards.length; i++)
        if (!widget.progressRepository.isFlashcardLearned(widget.topicId, i)) i,
    ];
  }

  /// Marking the current card learned while filtered should drop it from
  /// the deck immediately, naturally advancing to the next unlearned one.
  void _onProgressChanged() {
    if (!_hideLearned || !mounted) return;
    final newVisible = _computeVisibleIndices();
    setState(() {
      _visibleIndices = newVisible;
      if (_index >= _visibleIndices.length) {
        _index = _visibleIndices.isEmpty ? 0 : _visibleIndices.length - 1;
      }
      _showAnswer = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients && _visibleIndices.isNotEmpty) _controller.jumpToPage(_index);
    });
  }

  void _toggleHideLearned() {
    final currentActual = _visibleIndices.isEmpty ? null : _visibleIndices[_index];
    setState(() {
      _hideLearned = !_hideLearned;
      _visibleIndices = _computeVisibleIndices();
      final restored = currentActual == null ? -1 : _visibleIndices.indexOf(currentActual);
      _index = restored >= 0 ? restored : 0;
      _showAnswer = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients && _visibleIndices.isNotEmpty) _controller.jumpToPage(_index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return const _EmptyTab(icon: Icons.style_outlined, message: 'Chưa có flashcard nào.');
    }
    final theme = Theme.of(context);
    final total = _visibleIndices.length;
    final progress = total == 0 ? 1.0 : (_index + 1) / total;

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
              Text(total == 0 ? '0/0' : '${_index + 1}/$total', style: theme.textTheme.labelMedium),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _hideLearned
                    ? (_isEn ? 'Show all cards' : 'Hiện tất cả thẻ')
                    : (_isEn ? 'Show unlearned only' : 'Chỉ hiện thẻ chưa thuộc'),
                icon: Icon(
                  _hideLearned ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                  size: 20,
                  color: _hideLearned ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
                onPressed: _toggleHideLearned,
              ),
              if (total > 0)
                AnimatedBuilder(
                  animation: widget.progressRepository,
                  builder: (context, _) {
                    final actual = _visibleIndices[_index];
                    final learned = widget.progressRepository.isFlashcardLearned(widget.topicId, actual);
                    final bookmarked =
                        widget.progressRepository.isFlashcardBookmarked(widget.topicId, actual);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: _isEn ? 'Mark as learned' : 'Đánh dấu đã thuộc',
                          icon: Icon(
                            learned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                            size: 20,
                            color: learned ? theme.colorScheme.primary : theme.colorScheme.outline,
                          ),
                          onPressed: () =>
                              widget.progressRepository.toggleFlashcardLearned(widget.topicId, actual),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: _isEn ? 'Bookmark' : 'Đánh dấu yêu thích',
                          icon: Icon(
                            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 20,
                            color: bookmarked ? theme.colorScheme.primary : theme.colorScheme.outline,
                          ),
                          onPressed: () =>
                              widget.progressRepository.toggleFlashcardBookmarked(widget.topicId, actual),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: total == 0
              ? _EmptyTab(
                  icon: Icons.celebration_rounded,
                  message: _isEn
                      ? 'All caught up — every card here is marked learned.'
                      : 'Đã ôn hết — mọi thẻ ở đây đều đã được đánh dấu thuộc.',
                )
              : PageView.builder(
                  controller: _controller,
                  itemCount: total,
                  onPageChanged: (i) => setState(() {
                    _index = i;
                    _showAnswer = false;
                  }),
                  itemBuilder: (context, i) {
                    final card = widget.flashcards[_visibleIndices[i]];
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
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
