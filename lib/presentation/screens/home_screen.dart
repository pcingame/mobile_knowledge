import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/get_topics.dart';
import '../theme/app_spacing.dart';
import '../widgets/language_toggle.dart';
import '../widgets/topic_card.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'topic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.getTopics,
    required this.language,
    required this.progressRepository,
  });

  final GetTopics getTopics;
  final ValueNotifier<AppLanguage> language;
  final ProgressRepository progressRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Topic>> _topicsFuture = widget.getTopics();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.language,
      builder: (context, language, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ôn phỏng vấn Mobile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_rounded),
                tooltip: language == AppLanguage.en ? 'Favorites' : 'Yêu thích',
                onPressed: () async {
                  final topics = await _topicsFuture;
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FavoritesScreen(
                        topics: topics,
                        language: widget.language,
                        progressRepository: widget.progressRepository,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: language == AppLanguage.en ? 'Search' : 'Tìm kiếm',
                onPressed: () async {
                  final topics = await _topicsFuture;
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(
                        topics: topics,
                        language: widget.language,
                        progressRepository: widget.progressRepository,
                      ),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LanguageToggle(
                    language: language,
                    onChanged: (l) => widget.language.value = l,
                  ),
                ),
              ),
            ),
          ),
          body: FutureBuilder<List<Topic>>(
            future: _topicsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(message: '${snapshot.error}');
              }
              final topics = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        language == AppLanguage.en
                            ? 'Pick a topic to start reviewing.'
                            : 'Chọn một chủ đề để bắt đầu ôn tập.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.xxxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: topics.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final topic = topics[i];
                        return _StaggeredEntry(
                          index: i,
                          child: TopicCard(
                            topic: topic,
                            language: language,
                            progressRepository: widget.progressRepository,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TopicScreen(
                                  topic: topic,
                                  language: widget.language,
                                  progressRepository: widget.progressRepository,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Fades + slides each list item in with a short stagger, giving the list
/// a bit of life on first load without ever leaving content invisible.
class _StaggeredEntry extends StatelessWidget {
  const _StaggeredEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
        );
      },
      child: child,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text('Không tải được dữ liệu', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
