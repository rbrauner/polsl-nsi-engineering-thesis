import 'package:flutter_test/flutter_test.dart';
import 'package:polsl_nsi_engineering_thesis/Application.dart';

void main() {
  testWidgets('Application', (WidgetTester tester) async {
    await tester.pumpWidget(const Application());
    final widgetTitleFinder =
        find.text('System pomiaru wilgotności gleby roślin doniczkowych');

    expect(widgetTitleFinder, findsOneWidget);
  });
}
