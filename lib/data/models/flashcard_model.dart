import '../../domain/entities/flashcard.dart';

class FlashcardModel extends Flashcard {
  const FlashcardModel({required super.question, required super.answer});

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}
