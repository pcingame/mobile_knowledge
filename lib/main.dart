import 'package:flutter/material.dart';

import 'domain/entities/app_language.dart';
import 'domain/repositories/progress_repository.dart';
import 'domain/usecases/get_topics.dart';
import 'injection_container.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await InjectionContainer.build();
  runApp(KnowledgeMobileApp(getTopics: deps.getTopics, progressRepository: deps.progressRepository));
}

class KnowledgeMobileApp extends StatelessWidget {
  KnowledgeMobileApp({
    super.key,
    required this.getTopics,
    required this.progressRepository,
    ValueNotifier<AppLanguage>? language,
  }) : language = language ?? ValueNotifier(AppLanguage.en);

  final GetTopics getTopics;
  final ProgressRepository progressRepository;
  final ValueNotifier<AppLanguage> language;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ôn phỏng vấn Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomeScreen(
        getTopics: getTopics,
        language: language,
        progressRepository: progressRepository,
      ),
    );
  }
}
