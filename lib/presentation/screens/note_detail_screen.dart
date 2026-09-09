import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';
import '../widgets/note_body.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: NoteBody(content: note.content),
      ),
    );
  }
}
