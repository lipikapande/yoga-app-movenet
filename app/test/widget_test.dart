import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoga/main.dart';

void main() {
  testWidgets('Yoga app dashboard loads', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(YogaAssistantApp());

    // Verify that the dashboard title appears
    expect(find.text('Yoga Assistant'), findsOneWidget);

    // Verify that all 4 buttons exist
    expect(find.text('Practice Now'), findsOneWidget);
    expect(find.text('Poses Library'), findsOneWidget);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
  });
}
