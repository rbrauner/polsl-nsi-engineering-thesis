import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/widget/AboutAuthorWidget.dart';
import 'package:polsl_nsi_engineering_thesis/widget/DevicesListWidget.dart';

class HomepageWidget extends StatelessWidget {
  const HomepageWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'System pomiaru wilgotności gleby\nroślin doniczkowych',
              style: TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return new DevicesListWidget();
                    },
                  ),
                );
              },
              child: Text('Lista urządzeń'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return new AboutAuthorWidget();
                    },
                  ),
                );
              },
              child: Text('O autorze'),
            )
          ],
        ),
      ),
    );
  }
}
