import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';

/// One topic row on the home screen: icon, title, and a small row of
/// count chips (flashcards / quiz / notes) instead of a single dense line.
class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.language,
    required this.onTap,
    required this.progressRepository,
  });

  final Topic topic;
  final AppLanguage language;
  final VoidCallback onTap;
  final ProgressRepository progressRepository;

  static const _icons = <String, IconData>{
    'flutter_dart': Icons.flutter_dash_rounded,
    'android': Icons.android_rounded,
    'ios': Icons.phone_iphone_rounded,
    'general': Icons.public_rounded,
    'system_design': Icons.account_tree_rounded,
    'git_workflow': Icons.merge_type_rounded,
  };

  /// Cycles through the color scheme's harmonious container tones so each
  /// topic reads distinctly without introducing off-brand hues.
  ({Color bg, Color fg}) _tone(ColorScheme scheme) {
    switch (topic.id) {
      case 'flutter_dart':
        return (bg: scheme.primaryContainer, fg: scheme.onPrimaryContainer);
      case 'android':
        return (bg: scheme.tertiaryContainer, fg: scheme.onTertiaryContainer);
      case 'ios':
        return (bg: scheme.secondaryContainer, fg: scheme.onSecondaryContainer);
      default:
        return (bg: scheme.surfaceContainerHighest, fg: scheme.onSurfaceVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = _tone(theme.colorScheme);
    final isEn = language == AppLanguage.en;

    return AnimatedBuilder(
      animation: progressRepository,
      builder: (context, _) {
        final best = progressRepository.bestQuizAttempt(topic.id);
        return _card(context, theme, tone, isEn, best);
      },
    );
  }

  Widget _card(
    BuildContext context,
    ThemeData theme,
    ({Color bg, Color fg}) tone,
    bool isEn,
    QuizAttempt? best,
  ) {
    return Material(
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(_icons[topic.id] ?? Icons.folder_rounded, color: tone.fg, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title.of(language), style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _CountChip(
                          icon: Icons.style_rounded,
                          label: isEn
                              ? '${topic.flashcards.length} ${topic.flashcards.length == 1 ? 'flashcard' : 'flashcards'}'
                              : '${topic.flashcards.length} flashcard',
                        ),
                        _CountChip(
                          icon: Icons.quiz_rounded,
                          label: isEn
                              ? '${topic.quiz.length} ${topic.quiz.length == 1 ? 'question' : 'questions'}'
                              : '${topic.quiz.length} câu quiz',
                        ),
                        _CountChip(
                          icon: Icons.notes_rounded,
                          label: isEn
                              ? '${topic.notes.length} ${topic.notes.length == 1 ? 'note' : 'notes'}'
                              : '${topic.notes.length} bài viết',
                        ),
                        if (best != null)
                          _CountChip(
                            icon: Icons.emoji_events_rounded,
                            label: isEn
                                ? 'Best ${best.score}/${best.total}'
                                : 'Tốt nhất ${best.score}/${best.total}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
