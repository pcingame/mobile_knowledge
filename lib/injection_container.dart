import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/progress_local_data_source.dart';
import 'data/datasources/topic_local_data_source.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/topic_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';
import 'domain/repositories/topic_repository.dart';
import 'domain/usecases/get_topics.dart';

/// Everything [KnowledgeMobileApp] needs, wired up by [InjectionContainer.build].
class AppDependencies {
  const AppDependencies({required this.getTopics, required this.progressRepository});

  final GetTopics getTopics;
  final ProgressRepository progressRepository;
}

/// Manual composition root: wires each layer's concrete implementation
/// to the layer above it. No DI package needed for an app this size —
/// this is the single place that knows about every concrete class.
class InjectionContainer {
  InjectionContainer._();

  static Future<AppDependencies> build() async {
    final TopicLocalDataSource topicDataSource = TopicLocalDataSourceImpl();
    final TopicRepository topicRepository = TopicRepositoryImpl(topicDataSource);

    final prefs = await SharedPreferences.getInstance();
    final progressDataSource = ProgressLocalDataSource(prefs);
    final ProgressRepository progressRepository = ProgressRepositoryImpl(progressDataSource);
    await progressRepository.init();

    return AppDependencies(
      getTopics: GetTopics(topicRepository),
      progressRepository: progressRepository,
    );
  }
}
