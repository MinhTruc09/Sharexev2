import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple widget and verify it works
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Hello World'))),
    );

    // Verify that our widget is displayed.
    expect(find.text('Hello World'), findsOneWidget);
  });
}
