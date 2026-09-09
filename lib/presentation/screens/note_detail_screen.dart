import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/note.dart';
import '../theme/app_spacing.dart';
import '../widgets/note_body.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.note, required this.language});

  final Note note;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title.of(language))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
        child: NoteBody(content: note.content.of(language)),
      ),
    );
  }
}
