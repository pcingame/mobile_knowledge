// End-to-end smoke test: the real composition root wires the real data
// source/repository/use case, and the home screen renders every bundled
// topic. Layer-specific behavior is covered by the tests under test/domain,
// test/data, and test/presentation.

import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/injection_container.dart';
import 'package:knowledge_mobile/main.dart';

void main() {
  testWidgets('Home screen lists all topics after loading', (WidgetTester tester) async {
    await tester.pumpWidget(KnowledgeMobileApp(getTopics: InjectionContainer.build()));

    // Assets load asynchronously; let the FutureBuilder resolve.
    await tester.pumpAndSettle();

    expect(find.text('Flutter & Dart'), findsOneWidget);
    expect(find.text('Android Native'), findsOneWidget);
    expect(find.text('iOS Native'), findsOneWidget);
    expect(find.text('Kiến thức chung Mobile'), findsOneWidget);
  });
}
