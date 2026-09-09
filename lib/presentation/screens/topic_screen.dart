import 'package:flutter/material.dart';

import '../../domain/entities/topic.dart';
import '../widgets/flashcard_tab.dart';
import '../widgets/notes_tab.dart';
import '../widgets/quiz_tab.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(topic.title),
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
            FlashcardTab(flashcards: topic.flashcards),
            QuizTab(questions: topic.quiz),
            NotesTab(notes: topic.notes),
          ],
        ),
      ),
    );
  }
}
