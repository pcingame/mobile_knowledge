import '../../domain/entities/localized_text.dart';

class LocalizedTextModel extends LocalizedText {
  const LocalizedTextModel({required super.en, required super.vi});

  factory LocalizedTextModel.fromJson(Map<String, dynamic> json) {
    return LocalizedTextModel(
      en: json['en'] as String,
      vi: json['vi'] as String,
    );
  }
}
