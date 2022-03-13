import 'package:flutter/material.dart';

class AboutAuthorWidget extends StatelessWidget {
  const AboutAuthorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O autorze'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'O autorze',
              style: TextStyle(fontSize: 28),
            ),
            SizedBox(height: 20),
            Text('Autor: Rafał Brauner', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Kierujący pracą: dr inż. Dariusz Myszor',
                style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
