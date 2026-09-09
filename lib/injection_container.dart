import 'data/datasources/topic_local_data_source.dart';
import 'data/repositories/topic_repository_impl.dart';
import 'domain/repositories/topic_repository.dart';
import 'domain/usecases/get_topics.dart';

/// Manual composition root: wires each layer's concrete implementation
/// to the layer above it. No DI package needed for an app this size —
/// this is the single place that knows about every concrete class.
class InjectionContainer {
  InjectionContainer._();

  static GetTopics build() {
    final TopicLocalDataSource dataSource = TopicLocalDataSourceImpl();
    final TopicRepository repository = TopicRepositoryImpl(dataSource);
    return GetTopics(repository);
  }
}
