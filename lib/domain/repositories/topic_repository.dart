import '../entities/topic.dart';

/// Contract for fetching study topics, implemented by the data layer.
/// The domain layer only knows about this interface, never about JSON
/// or where the data actually comes from.
abstract class TopicRepository {
  Future<List<Topic>> getTopics();
}
