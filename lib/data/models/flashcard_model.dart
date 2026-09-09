import '../../domain/entities/flashcard.dart';
import 'localized_text_model.dart';

class FlashcardModel extends Flashcard {
  const FlashcardModel({required super.question, required super.answer});

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      question: LocalizedTextModel.fromJson(json['question'] as Map<String, dynamic>),
      answer: LocalizedTextModel.fromJson(json['answer'] as Map<String, dynamic>),
    );
  }
}
