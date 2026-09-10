import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';

class _BookmarkedCard {
  const _BookmarkedCard({required this.topic, required this.index, required this.flashcard});

  final Topic topic;
  final int index;
  final Flashcard flashcard;
}

/// Every flashcard the user has bookmarked, across all topics — resolved
/// from [ProgressRepository]'s "topicId:index" keys back to actual content.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.topics,
    required this.language,
    required this.progressRepository,
  });

  final List<Topic> topics;
  final ValueNotifier<AppLanguage> language;
  final ProgressRepository progressRepository;

  List<_BookmarkedCard> _resolve() {
    final topicsById = {for (final t in topics) t.id: t};
    final cards = <_BookmarkedCard>[];
    for (final key in progressRepository.bookmarkedFlashcardKeys) {
      final parts = key.split(':');
      if (parts.length != 2) continue;
      final topic = topicsById[parts[0]];
      final index = int.tryParse(parts[1]);
      if (topic == null || index == null || index >= topic.flashcards.length) continue;
      cards.add(_BookmarkedCard(topic: topic, index: index, flashcard: topic.flashcards[index]));
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: language,
      builder: (context, lang, _) {
        final isEn = lang == AppLanguage.en;
        return Scaffold(
          appBar: AppBar(title: Text(isEn ? 'Favorites' : 'Yêu thích')),
          body: AnimatedBuilder(
            animation: progressRepository,
            builder: (context, _) {
              final cards = _resolve();
              if (cards.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 40, color: theme.colorScheme.outline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isEn
                              ? 'Bookmark flashcards to see them here.'
                              : 'Đánh dấu yêu thích flashcard để xem lại ở đây.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final c = cards[i];
                  return Card(
                    child: ExpansionTile(
                      title: Text(c.flashcard.question.of(lang)),
                      subtitle: Text(c.topic.title.of(lang), style: theme.textTheme.labelSmall),
                      trailing: IconButton(
                        icon: Icon(Icons.bookmark_rounded, color: theme.colorScheme.primary),
                        tooltip: isEn ? 'Remove bookmark' : 'Bỏ đánh dấu',
                        onPressed: () =>
                            progressRepository.toggleFlashcardBookmarked(c.topic.id, c.index),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(c.flashcard.answer.of(lang)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
