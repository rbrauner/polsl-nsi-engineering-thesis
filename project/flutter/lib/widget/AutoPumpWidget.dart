import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/helper/const.dart';
import 'package:polsl_nsi_engineering_thesis/helper/curl.dart';
import 'package:polsl_nsi_engineering_thesis/object/Pump.dart';

class AutoPumpWidget extends StatefulWidget {
  final String device;

  const AutoPumpWidget({Key? key, required this.device}) : super(key: key);

  @override
  State<AutoPumpWidget> createState() => _AutoPumpWidgetState();
}

class _AutoPumpWidgetState extends State<AutoPumpWidget> {
  Curl _curl = new Curl();

  Pump _pump = new Pump();
  RangeLabels _rangeLabels = new RangeLabels("1", "100");

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
                'Automatyczne podlewanie',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Włączone',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Checkbox(
                value: _pump.auto,
                onChanged: (value) {
                  setState(() {
                    _pump.auto = value == true ? true : false;

                    String request =
                        "POST /pump/auto-pump?auto=${value == true ? 1 : 0}\n";

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
                  });
                },
              ),
              SizedBox(height: 20),
              Tooltip(
                message:
                    'Zakres wilgotności gleby w jakim pompa zostaje włączona/wyłączona. (przedział: 1-100%)',
                child: Text(
                  'Zakres wilgotności gleby',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              RangeSlider(
                values: RangeValues(_pump.autoMin, _pump.autoMax),
                divisions: 100,
                labels: _rangeLabels,
                min: 1,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _pump.autoMin =
                        double.parse(value.start.toInt().toString());
                    _pump.autoMax = double.parse(value.end.toInt().toString());

                    _rangeLabels = RangeLabels(value.start.toInt().toString(),
                        value.end.toInt().toString());
                  });
                },
                onChangeEnd: (value) {
                  String request =
                      "POST /pump/auto-pump-range?min=${value.start.toInt()}&max=${value.end.toInt()}\n";

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
              )
            ])));
  }
}
