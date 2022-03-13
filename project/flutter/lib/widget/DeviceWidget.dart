import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/widget/AutoPumpWidget.dart';
import 'package:polsl_nsi_engineering_thesis/widget/PumpWidget.dart';
import 'package:polsl_nsi_engineering_thesis/widget/SensorsWidget.dart';

class DeviceWidget extends StatelessWidget {
  final String device;

  const DeviceWidget({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Urządzenie na porcie ' + device),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Urządzenie na porcie ' + device + '.\nDostępne opcje:',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return new SensorsWidget(device: device);
                    },
                  ),
                );
              },
              child: Text('Czujniki'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return new PumpWidget(device: device);
                    },
                  ),
                );
              },
              child: Text('Pompa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return new AutoPumpWidget(device: device);
                    },
                  ),
                );
              },
              child: Text('Automatyczna pompa'),
            ),
          ],
        ),
      ),
    );
  }
}
