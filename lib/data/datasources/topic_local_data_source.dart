import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/topic_model.dart';

/// File names (without extension) of the bundled topic JSON assets,
/// in the order they should be displayed.
const List<String> topicAssetIds = [
  'flutter_dart',
  'android',
  'ios',
  'general',
  'system_design',
  'git_workflow',
];

abstract class TopicLocalDataSource {
  Future<List<TopicModel>> getTopics();
}

class TopicLocalDataSourceImpl implements TopicLocalDataSource {
  final AssetBundle bundle;

  /// [bundle] defaults to Flutter's [rootBundle] but can be overridden
  /// (e.g. with a fake) in tests.
  TopicLocalDataSourceImpl({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  @override
  Future<List<TopicModel>> getTopics() {
    return Future.wait(topicAssetIds.map(_loadOne));
  }

  Future<TopicModel> _loadOne(String assetId) async {
    final raw = await bundle.loadString('assets/data/$assetId.json');
    return TopicModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
