import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/note.dart';
import '../theme/app_spacing.dart';
import '../screens/note_detail_screen.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({super.key, required this.notes, required this.language});

  final List<Note> notes;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Text('Chưa có bài viết nào.', style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final note = notes[i];
        return Material(
          color: Theme.of(context).cardTheme.color,
          shape: Theme.of(context).cardTheme.shape,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note, language: language)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.article_rounded, size: 20, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(note.title.of(language), style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
