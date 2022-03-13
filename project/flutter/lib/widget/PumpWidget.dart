import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/helper/const.dart';
import 'package:polsl_nsi_engineering_thesis/helper/curl.dart';
import 'package:polsl_nsi_engineering_thesis/object/Pump.dart';

class PumpWidget extends StatefulWidget {
  final String device;

  const PumpWidget({Key? key, required this.device}) : super(key: key);

  @override
  State<PumpWidget> createState() => _PumpWidgetState();
}

class _PumpWidgetState extends State<PumpWidget> {
  Curl _curl = new Curl();

  Pump _pump = new Pump();

  @override
  void initState() {
    super.initState();

    _curl.createCurl({"request": "GET /pump\n", "device": widget.device}).then(
        pumpGetCallback);
  }

  @override
  void deactivate() {
    super.deactivate();
    _curl.createCurl(
        {"request": String.fromCharCode(CANCEL_CHAR), "device": widget.device});
  }

  @override
  void dispose() {
    super.dispose();
    _curl.createCurl(
        {"request": String.fromCharCode(CANCEL_CHAR), "device": widget.device});
  }

  void pumpGetCallback(response) {
    var json = jsonDecode(response);
    if (json['code'] == 200) {
      setState(() {
        _pump.aviable = true;
        _pump.working = json['data']['working'] == 0 ? false : true;
        _pump.auto = json['data']['auto'] == 0 ? false : true;
        _pump.autoMin = double.parse(json['data']['auto_min']);
        _pump.autoMax = double.parse(json['data']['auto_max']);
      });
    } else {
      setState(() {
        _pump.aviable = false;
        _pump.working = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pompa urządzenia na porcie ' + widget.device),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(
                'Pompa',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  String request = _pump.working
                      ? "POST /pump/stop\n"
                      : "POST /pump/start\n";

                  _curl.createCurl({
                    "request": request,
                    "device": widget.device
                  }).then((response) {
                    var json = jsonDecode(response);
                    if (json['code'] == 200) {
                      _curl.createCurl({
                        "request": "GET /pump\n",
                        "device": widget.device
                      }).then(pumpGetCallback);
                    } else {
                      setState(() {
                        _pump.aviable = false;
                        _pump.working = false;
                      });
                    }
                  });
                },
                child: Text(_pump.working ? 'Stop' : 'Start'),
                style: ButtonStyle(
                    backgroundColor: _pump.working
                        ? MaterialStateProperty.all<Color>(Colors.red)
                        : null),
              ),
            ])));
  }
}
