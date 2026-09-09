import 'package:flutter/material.dart';

import '../models/note.dart';
import 'note_detail_screen.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({super.key, required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text('Chưa có bài viết nào.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final note = notes[i];
        return Card(
          child: ListTile(
            title: Text(note.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
            ),
          ),
        );
      },
    );
  }
}
