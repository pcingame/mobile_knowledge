// End-to-end smoke test: the real composition root wires the real data
// source/repository/use case, and the home screen renders every bundled
// topic. Layer-specific behavior is covered by the tests under test/domain,
// test/data, and test/presentation.
//
// The real topics are loaded once in setUpAll (a plain async zone) rather
// than inside testWidgets: awaiting rootBundle.loadString for this app's
// full (Vietnamese-heavy, ~70KB per file) bundled content directly inside
// a testWidgets callback hangs indefinitely in this Flutter SDK's test
// harness — a harness-only quirk (the real app loads the same assets in
// well under a second on-device, verified manually) — so the widget test
// itself is pumped with the already-loaded data instead of re-triggering
// that asset read inside the widget tree.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowledge_mobile/domain/entities/topic.dart';
import 'package:knowledge_mobile/domain/repositories/progress_repository.dart';
import 'package:knowledge_mobile/domain/repositories/topic_repository.dart';
import 'package:knowledge_mobile/domain/usecases/get_topics.dart';
import 'package:knowledge_mobile/injection_container.dart';
import 'package:knowledge_mobile/main.dart';

class _PreloadedRepository implements TopicRepository {
  const _PreloadedRepository(this.topics);
  final List<Topic> topics;
  @override
  Future<List<Topic>> getTopics() async => topics;
}

void main() {
  late List<Topic> topics;
  late ProgressRepository progressRepository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final deps = await InjectionContainer.build();
    topics = await deps.getTopics();
    progressRepository = deps.progressRepository;
  });

  testWidgets('Home screen lists all topics after loading', (WidgetTester tester) async {
    final getTopics = GetTopics(_PreloadedRepository(topics));
    await tester.pumpWidget(
      KnowledgeMobileApp(getTopics: getTopics, progressRepository: progressRepository),
    );

    // The future resolves asynchronously; let the FutureBuilder settle.
    await tester.pumpAndSettle();

    expect(find.text('Flutter & Dart'), findsOneWidget);
    expect(find.text('Android Native'), findsOneWidget);
    expect(find.text('iOS Native'), findsOneWidget);
    // Default language is English; the general topic's title differs per language.
    expect(find.text('General Mobile Knowledge'), findsOneWidget);

    // Toggling to Vietnamese re-renders every topic title in Vietnamese.
    await tester.tap(find.text('VI'));
    await tester.pumpAndSettle();
    expect(find.text('Kiến thức chung Mobile'), findsOneWidget);
  });
}
