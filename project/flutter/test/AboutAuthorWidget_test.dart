import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/widget/AboutAuthorWidget.dart';

void main() {
  testWidgets('AboutAuthorWidget', (WidgetTester tester) async {
    var testWidget = MaterialApp(
      home: const AboutAuthorWidget(),
    );

    await tester.pumpWidget(testWidget);
    final titleFinder = find.text('O autorze');
    final authorFinder = find.text('Autor: Rafał Brauner');
    final promoterFinder = find.text('Kierujący pracą: dr inż. Dariusz Myszor');

    expect(titleFinder, findsNWidgets(2));
    expect(authorFinder, findsOneWidget);
    expect(promoterFinder, findsOneWidget);
  });
}
