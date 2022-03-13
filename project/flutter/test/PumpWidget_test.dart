import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/widget/PumpWidget.dart';

void main() {
  testWidgets('PumpWidget', (WidgetTester tester) async {
    var testWidget = MaterialApp(
      home: const PumpWidget(device: "COM1"),
    );

    await tester.pumpWidget(testWidget);
    final widgetTitleFinder = find.text('Pompa urządzenia na porcie COM1');
    final titleFinder = find.text('Pompa');
    final buttonFinder = find.text('Start');

    expect(widgetTitleFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);
  });
}
