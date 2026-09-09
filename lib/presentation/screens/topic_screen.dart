import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/topic.dart';
import '../widgets/flashcard_tab.dart';
import '../widgets/language_toggle.dart';
import '../widgets/notes_tab.dart';
import '../widgets/quiz_tab.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key, required this.topic, required this.language});

  final Topic topic;
  final ValueNotifier<AppLanguage> language;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: language,
      builder: (context, lang, _) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(topic.title.of(lang)),
              actions: [
                LanguageToggle(language: lang, onChanged: (l) => language.value = l),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Flashcard', icon: Icon(Icons.style)),
                  Tab(text: 'Quiz', icon: Icon(Icons.quiz)),
                  Tab(text: 'Ghi chú', icon: Icon(Icons.notes)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                FlashcardTab(flashcards: topic.flashcards, language: lang),
                QuizTab(questions: topic.quiz, language: lang),
                NotesTab(notes: topic.notes, language: lang),
              ],
            ),
          ),
        );
      },
    );
  }
}
