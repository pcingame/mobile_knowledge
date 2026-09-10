import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_tab.dart';
import '../widgets/language_toggle.dart';
import '../widgets/notes_tab.dart';
import '../widgets/quiz_tab.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({
    super.key,
    required this.topic,
    required this.language,
    required this.progressRepository,
    this.initialTabIndex = 0,
  });

  final Topic topic;
  final ValueNotifier<AppLanguage> language;
  final ProgressRepository progressRepository;

  /// Which tab (0=Flashcard, 1=Quiz, 2=Notes) to open on — lets search
  /// results deep-link straight into the relevant tab.
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: language,
      builder: (context, lang, _) {
        return DefaultTabController(
          length: 3,
          initialIndex: initialTabIndex,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                  title: Text(topic.title.of(lang)),
                  titleTextStyle: TextStyle(
                    fontFamily: AppTheme.displayFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: scheme.onPrimary,
                  ),
                  actions: [
                    LanguageToggle(
                      language: lang,
                      onChanged: (l) => language.value = l,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(_kTabBarHeight + AppSpacing.sm + AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: _TopicTabBar(
                        onPrimary: scheme.onPrimary,
                        selectedLabelColor: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  FlashcardTab(
                    flashcards: topic.flashcards,
                    language: lang,
                    topicId: topic.id,
                    progressRepository: progressRepository,
                  ),
                  QuizTab(
                    questions: topic.quiz,
                    language: lang,
                    topicId: topic.id,
                    progressRepository: progressRepository,
                  ),
                  NotesTab(notes: topic.notes, language: lang),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const _kTabBarHeight = 44.0;

/// A compact pill-shaped segmented control for the Flashcard/Quiz/Notes
/// tabs — icon and label sit side by side instead of Material's default
/// stacked layout, so the whole bar reads as one tight, balanced group
/// instead of three tall, disconnected buttons.
class _TopicTabBar extends StatelessWidget {
  const _TopicTabBar({
    required this.onPrimary,
    required this.selectedLabelColor,
  });

  final Color onPrimary;
  final Color selectedLabelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kTabBarHeight,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: TabBar(
        splashBorderRadius: BorderRadius.circular(AppRadius.pill),
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: onPrimary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: selectedLabelColor,
        unselectedLabelColor: onPrimary.withValues(alpha: 0.75),
        labelStyle: const TextStyle(
          fontFamily: AppTheme.displayFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTheme.displayFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          _PillTab(icon: Icons.style_rounded, label: 'Flashcard'),
          _PillTab(icon: Icons.quiz_rounded, label: 'Quiz'),
          _PillTab(icon: Icons.notes_rounded, label: 'Ghi chú'),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: _kTabBarHeight - 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
