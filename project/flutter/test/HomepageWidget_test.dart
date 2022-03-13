import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/widget/HomepageWidget.dart';

void main() {
  testWidgets('HomepageWidget', (WidgetTester tester) async {
    var testWidget = MaterialApp(
      home: const HomepageWidget(title: 'test'),
    );

    await tester.pumpWidget(testWidget);
    final widgetTitleFinder = find.text('test');
    final titleFinder =
        find.text('System pomiaru wilgotności gleby\nroślin doniczkowych');

    expect(widgetTitleFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
  });
}
