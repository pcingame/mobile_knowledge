import '../../domain/entities/note.dart';
import 'localized_text_model.dart';

class NoteModel extends Note {
  const NoteModel({required super.title, required super.content});

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
      content: LocalizedTextModel.fromJson(json['content'] as Map<String, dynamic>),
    );
  }
}
