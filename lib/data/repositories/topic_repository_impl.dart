import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../datasources/topic_local_data_source.dart';

class TopicRepositoryImpl implements TopicRepository {
  final TopicLocalDataSource localDataSource;

  const TopicRepositoryImpl(this.localDataSource);

  @override
  Future<List<Topic>> getTopics() => localDataSource.getTopics();
}
