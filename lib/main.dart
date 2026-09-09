import 'package:flutter/material.dart';

import 'domain/entities/app_language.dart';
import 'domain/usecases/get_topics.dart';
import 'injection_container.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(KnowledgeMobileApp(getTopics: InjectionContainer.build()));
}

class KnowledgeMobileApp extends StatelessWidget {
  KnowledgeMobileApp({super.key, required this.getTopics, ValueNotifier<AppLanguage>? language})
      : language = language ?? ValueNotifier(AppLanguage.en);

  final GetTopics getTopics;
  final ValueNotifier<AppLanguage> language;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ôn phỏng vấn Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomeScreen(getTopics: getTopics, language: language),
    );
  }
}
