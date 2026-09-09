import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/topic.dart';

/// File names (without extension) of the bundled topic JSON assets,
/// in the order they should be displayed.
const List<String> topicAssetIds = [
  'flutter_dart',
  'android',
  'ios',
  'general',
];

class TopicRepository {
  Future<List<Topic>> loadAll() async {
    return Future.wait(topicAssetIds.map(_loadOne));
  }

  Future<Topic> _loadOne(String assetId) async {
    final raw = await rootBundle.loadString('assets/data/$assetId.json');
    return Topic.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
