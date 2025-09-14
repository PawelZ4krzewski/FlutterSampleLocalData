// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_sample_local_data/main.dart';

void main() {
  testWidgets('Home screen displays storage options', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Storage Demo'), findsOneWidget);
    expect(find.text('Choose Storage Type'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('JSON File'), findsOneWidget);
    expect(find.text('SQLite'), findsOneWidget);
  });
}
