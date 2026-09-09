import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

/// Fetches every study topic. A thin wrapper around [TopicRepository],
/// kept as its own use case so the presentation layer never depends on
/// the repository interface directly and can be tested without one.
class GetTopics {
  final TopicRepository repository;

  const GetTopics(this.repository);

  // `async` guarantees callers always get a Future, even if a lower layer
  // ever throws synchronously instead of rejecting a Future — important
  // since the presentation layer awaits this inside a FutureBuilder.
  Future<List<Topic>> call() async => repository.getTopics();
}
