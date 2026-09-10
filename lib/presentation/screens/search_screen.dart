import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/progress_repository.dart';
import '../theme/app_spacing.dart';
import 'topic_screen.dart';

/// One flashcard/quiz/note that matched the current search query.
class _SearchResult {
  const _SearchResult({
    required this.topic,
    required this.tabIndex,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Topic topic;
  final int tabIndex; // 0=flashcard, 1=quiz, 2=notes — for TopicScreen deep-link
  final IconData icon;
  final String title;
  final String subtitle;
}

/// Searches every flashcard question, quiz question, and note title/content
/// (in both languages) across all loaded topics, so a query matches
/// regardless of which language the content bank stores it under.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.topics,
    required this.language,
    required this.progressRepository,
  });

  final List<Topic> topics;
  final ValueNotifier<AppLanguage> language;
  final ProgressRepository progressRepository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SearchResult> _search(String query) {
    if (query.trim().isEmpty) return const [];
    final needle = query.toLowerCase();
    bool matches(String text) => text.toLowerCase().contains(needle);

    final results = <_SearchResult>[];
    for (final topic in widget.topics) {
      for (final fc in topic.flashcards) {
        if (matches(fc.question.en) || matches(fc.question.vi) || matches(fc.answer.en) || matches(fc.answer.vi)) {
          results.add(_SearchResult(
            topic: topic,
            tabIndex: 0,
            icon: Icons.style_rounded,
            title: fc.question.of(widget.language.value),
            subtitle: fc.answer.of(widget.language.value),
          ));
        }
      }
      for (final q in topic.quiz) {
        if (matches(q.question.en) || matches(q.question.vi)) {
          results.add(_SearchResult(
            topic: topic,
            tabIndex: 1,
            icon: Icons.quiz_rounded,
            title: q.question.of(widget.language.value),
            subtitle: q.explanation.of(widget.language.value),
          ));
        }
      }
      for (final note in topic.notes) {
        if (matches(note.title.en) || matches(note.title.vi) || matches(note.content.en) || matches(note.content.vi)) {
          results.add(_SearchResult(
            topic: topic,
            tabIndex: 2,
            icon: Icons.notes_rounded,
            title: note.title.of(widget.language.value),
            subtitle: note.content.of(widget.language.value),
          ));
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.language,
      builder: (context, language, _) {
        final isEn = language == AppLanguage.en;
        final results = _search(_query);
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isEn
                    ? 'Search flashcards, quiz, notes…'
                    : 'Tìm flashcard, quiz, ghi chú…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          body: _query.trim().isEmpty
              ? _Hint(isEn: isEn)
              : results.isEmpty
                  ? _NoResults(isEn: isEn)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = results[i];
                        return ListTile(
                          leading: Icon(r.icon, color: theme.colorScheme.primary),
                          title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${r.topic.title.of(language)} · ${r.subtitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TopicScreen(
                                topic: r.topic,
                                language: widget.language,
                                progressRepository: widget.progressRepository,
                                initialTabIndex: r.tabIndex,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              isEn
                  ? 'Search across every topic\'s flashcards, quiz, and notes.'
                  : 'Tìm kiếm xuyên suốt flashcard, quiz, và ghi chú của mọi chủ đề.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              isEn ? 'No results.' : 'Không có kết quả.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
