import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/widget/DeviceWidget.dart';

void main() {
  testWidgets('DeviceWidget', (WidgetTester tester) async {
    var testWidget = MaterialApp(
      home: const DeviceWidget(device: "COM1"),
    );

    await tester.pumpWidget(testWidget);
    final widgetTitleFinder = find.text('Urządzenie na porcie COM1');
    final titleFinder =
        find.text('Urządzenie na porcie COM1.\nDostępne opcje:');
    final sensorsFinder = find.text('Czujniki');
    final pumpFinder = find.text('Pompa');
    final autoPumpFinder = find.text('Automatyczna pompa');

    expect(widgetTitleFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
    expect(sensorsFinder, findsOneWidget);
    expect(pumpFinder, findsOneWidget);
    expect(autoPumpFinder, findsOneWidget);
  });
}
