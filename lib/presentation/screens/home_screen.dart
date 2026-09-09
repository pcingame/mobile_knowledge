import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/topic.dart';
import '../../domain/usecases/get_topics.dart';
import '../widgets/language_toggle.dart';
import 'topic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.getTopics, required this.language});

  final GetTopics getTopics;
  final ValueNotifier<AppLanguage> language;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Topic>> _topicsFuture = widget.getTopics();

  static const _icons = <String, IconData>{
    'flutter_dart': Icons.flutter_dash,
    'android': Icons.android,
    'ios': Icons.phone_iphone,
    'general': Icons.public,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.language,
      builder: (context, language, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ôn phỏng vấn Mobile'),
            actions: [
              LanguageToggle(
                language: language,
                onChanged: (l) => widget.language.value = l,
              ),
            ],
          ),
          body: FutureBuilder<List<Topic>>(
            future: _topicsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Không tải được dữ liệu: ${snapshot.error}'));
              }
              final topics = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: topics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final topic = topics[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(_icons[topic.id] ?? Icons.folder, size: 32),
                      title: Text(topic.title.of(language), style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                        '${topic.flashcards.length} flashcard · ${topic.quiz.length} câu quiz · ${topic.notes.length} bài viết',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopicScreen(topic: topic, language: widget.language),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
