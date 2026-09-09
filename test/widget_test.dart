// Basic smoke test: the home screen loads and lists all 4 topics.

import 'package:flutter_test/flutter_test.dart';

import 'package:knowledge_mobile/main.dart';

void main() {
  testWidgets('Home screen lists all topics after loading', (WidgetTester tester) async {
    await tester.pumpWidget(const KnowledgeMobileApp());

    // Assets load asynchronously; let the FutureBuilder resolve.
    await tester.pumpAndSettle();

    expect(find.text('Flutter & Dart'), findsOneWidget);
    expect(find.text('Android Native'), findsOneWidget);
    expect(find.text('iOS Native'), findsOneWidget);
    expect(find.text('Kiến thức chung Mobile'), findsOneWidget);
  });
}
