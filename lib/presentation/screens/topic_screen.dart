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
                    // Tab with both an icon and text needs Material's
                    // 72px intrinsic height, plus the padding below, plus
                    // a small buffer for this font's line-height metrics.
                    preferredSize: const Size.fromHeight(72 + AppSpacing.md + 8),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: TabBar(
                        splashBorderRadius: BorderRadius.circular(
                          AppRadius.pill,
                        ),
                        indicator: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: scheme.onPrimary,
                        unselectedLabelColor: scheme.onPrimary.withValues(
                          alpha: 0.6,
                        ),
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
                          Tab(
                            icon: Icon(Icons.style_rounded, size: 20),
                            text: 'Flashcard',
                          ),
                          Tab(
                            icon: Icon(Icons.quiz_rounded, size: 20),
                            text: 'Quiz',
                          ),
                          Tab(
                            icon: Icon(Icons.notes_rounded, size: 20),
                            text: 'Ghi chú',
                          ),
                        ],
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
