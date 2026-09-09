import 'localized_text.dart';

/// A longer-form explanatory article used in the notes study mode.
class Note {
  final LocalizedText title;
  final LocalizedText content;

  const Note({required this.title, required this.content});
}
