import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/widget/HomepageWidget.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System pomiaru wilgotności gleby roślin doniczkowych',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomepageWidget(
          title: 'System pomiaru wilgotności gleby roślin doniczkowych'),
    );
  }
}
