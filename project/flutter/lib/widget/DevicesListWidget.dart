import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:polsl_nsi_engineering_thesis/widget/DeviceWidget.dart';

class DevicesListWidget extends StatefulWidget {
  const DevicesListWidget({Key? key}) : super(key: key);

  @override
  State<DevicesListWidget> createState() => _DevicesListWidgetState();
}

class _DevicesListWidgetState extends State<DevicesListWidget> {
  List<String> _devices = <String>[];

  @override
  void initState() {
    super.initState();
    _updateDevicesList();
  }

  Future<void> _updateDevicesList() async {
    setState(() {
      _devices = SerialPort.availablePorts;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];

    children = <Widget>[];

    for (var device in _devices) {
      children.add(ElevatedButton(
          onPressed: () {
            if (!SerialPort.availablePorts.contains(device)) {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Podane urządzenie jest niedostępne'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Urządzenie ' +
                                  device +
                                  ' jest odłączone. Odśwież listę urządzeń.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
              return;
            }

            SerialPort serialPort = new SerialPort(device);
            if (serialPort.isOpen) {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Port jest otwarty.'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Nie można otworzyć portu ' +
                                  device +
                                  '. Port jest już otwarty przez inny program. Odśwież listę urządzeń.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));

              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return new DeviceWidget(device: device);
                },
              ),
            );
          },
          child: Text(device)));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista urządzeń'),
          actions: [
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: _updateDevicesList,
              tooltip: 'Odśwież',
            ),
          ],
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(
                'Lista urządzeń:',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              )
            ])));
  }
}
