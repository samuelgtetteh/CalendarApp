import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:queuemaster/main.dart';

void main() {
  testWidgets('Calendar screen renders month grid and add button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalendarApp());

    expect(find.byType(CalendarApp), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
