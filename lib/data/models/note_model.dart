import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({required super.title, required super.content});

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
