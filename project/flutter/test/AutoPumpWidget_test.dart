import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/widget/AutoPumpWidget.dart';

void main() {
  testWidgets('AutoPumpWidget', (WidgetTester tester) async {
    var testWidget = MaterialApp(
      home: const AutoPumpWidget(device: "COM1"),
    );

    await tester.pumpWidget(testWidget);
    final widgetTitleFinder = find.text('Pompa urządzenia na porcie COM1');
    final titleFinder = find.text('Automatyczne podlewanie');
    final activeFinder = find.text('Włączone');
    final rangeSliderFinder = find.text('Zakres wilgotności gleby');
    final rangeSliderTooltipFinder = find.byTooltip(
        'Zakres wilgotności gleby w jakim pompa zostaje włączona/wyłączona. (przedział: 1-100%)');

    expect(widgetTitleFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
    expect(activeFinder, findsOneWidget);
    expect(rangeSliderFinder, findsOneWidget);
    expect(rangeSliderTooltipFinder, findsOneWidget);
  });
}
