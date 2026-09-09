import 'package:flutter/material.dart';

import 'domain/entities/app_language.dart';
import 'domain/usecases/get_topics.dart';
import 'injection_container.dart';
import 'presentation/screens/home_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: HomeScreen(getTopics: getTopics, language: language),
    );
  }
}
