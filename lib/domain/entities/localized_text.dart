import 'app_language.dart';

/// A piece of question-bank text available in both supported languages.
class LocalizedText {
  final String en;
  final String vi;

  const LocalizedText({required this.en, required this.vi});

  String of(AppLanguage language) => switch (language) {
        AppLanguage.en => en,
        AppLanguage.vi => vi,
      };
}
