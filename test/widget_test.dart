import 'package:flutter_test/flutter_test.dart';

import 'package:gem_quest/main.dart';

void main() {
  testWidgets('Gem Quest home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GemQuestApp());

    expect(find.text('GEM QUEST'), findsOneWidget);
    expect(find.text('PLAY GAME'), findsOneWidget);
  });
}
