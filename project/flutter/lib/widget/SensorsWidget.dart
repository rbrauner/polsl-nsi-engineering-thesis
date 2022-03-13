import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polsl_nsi_engineering_thesis/helper/const.dart';
import 'package:polsl_nsi_engineering_thesis/helper/curl.dart';
import 'package:polsl_nsi_engineering_thesis/object/Humidity.dart';
import 'package:polsl_nsi_engineering_thesis/object/Moisture.dart';
import 'package:polsl_nsi_engineering_thesis/object/Temperature.dart';

class SensorsWidget extends StatefulWidget {
  final String device;

  const SensorsWidget({Key? key, required this.device}) : super(key: key);

  @override
  State<SensorsWidget> createState() => _SensorsWidgetState();
}

class _SensorsWidgetState extends State<SensorsWidget> {
  Curl _curl = new Curl();
  late Timer _timer;

  Moisture _moisture = new Moisture();
  Humidity _humidity = new Humidity();
  Temperature _temperature = new Temperature();

  @override
  void initState() {
    super.initState();

    _setTimer();
  }

  void _setTimer() {
    var callback = (Timer timer) {
      var temperatureOnValue = (response) {
        var json = jsonDecode(response);
        if (json['code'] == 200) {
          setState(() {
            _temperature.aviable = true;
            _temperature.value = double.parse(json['data']['value']);
            _temperature.min = double.parse(json['data']['min']);
            _temperature.max = double.parse(json['data']['max']);
          });
        } else {
          setState(() {
            _temperature.aviable = false;
          });
        }
      };

      var humidityOnValue = (response) {
        var json = jsonDecode(response);
        if (json['code'] == 200) {
          setState(() {
            _humidity.aviable = true;
            _humidity.value = double.parse(json['data']['value']);
            _humidity.min = double.parse(json['data']['min']);
            _humidity.max = double.parse(json['data']['max']);
          });
        } else {
          setState(() {
            _humidity.aviable = false;
          });
        }
      };

      var moistureOnValue = (response) {
        var json = jsonDecode(response);
        if (json['code'] == 200) {
          setState(() {
            _moisture.aviable = true;
            _moisture.value = double.parse(json['data']['value']);
            _moisture.min = double.parse(json['data']['min']);
            _moisture.max = double.parse(json['data']['max']);

            _moisture.ranges.clear();
            for (var item in json['data']['ranges']) {
              Map<String, String> map = new Map<String, String>();
              item.forEach((final String key, final value) {
                map.putIfAbsent(key, () => value);
              });
              _moisture.ranges.add(map);
            }
          });
        } else {
          setState(() {
            _moisture.aviable = false;
          });
        }
      };

      _curl.createCurl({
        "request": "GET /moisture\n",
        "device": widget.device
      }).then((response) {
        moistureOnValue(response);

        _curl.createCurl({
          "request": "GET /humidity\n",
          "device": widget.device
        }).then((response) {
          humidityOnValue(response);

          _curl.createCurl({
            "request": "GET /temperature\n",
            "device": widget.device
          }).then(temperatureOnValue);
        });
      });
    };

    _timer = Timer.periodic(new Duration(seconds: 2), callback);

    callback(_timer);
  }

  @override
  void deactivate() {
    super.deactivate();

    _timer.cancel();
    _curl.createCurl(
        {"request": String.fromCharCode(CANCEL_CHAR), "device": widget.device});
  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();
    _curl.createCurl(
        {"request": String.fromCharCode(CANCEL_CHAR), "device": widget.device});
  }

  @override
  Widget build(BuildContext context) {
    double circularWidth = 50;
    double circularHeigh = 50;
    double circularStrokeWidth = 5;
    double circularTextFontSize = 14;

    return Scaffold(
        appBar: AppBar(
          title: Text('Czujniki urządzenia na porcie ' + widget.device),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(
                'Czujniki',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Czujnik wilgotności gleby:"),
                          SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: circularWidth,
                                height: circularHeigh,
                                child: CircularProgressIndicator(
                                  value: _moisture.aviable
                                      ? _moisture.getPercentage()
                                      : 0,
                                  strokeWidth: circularStrokeWidth,
                                ),
                              ),
                              Text(
                                _moisture.aviable
                                    ? (_moisture.getPercentage() * 100)
                                            .toStringAsFixed(2) +
                                        "%"
                                    : "N/A",
                                style:
                                    TextStyle(fontSize: circularTextFontSize),
                              ),
                            ],
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Czujnik wilgotności powietrza:"),
                          SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: circularWidth,
                                height: circularHeigh,
                                child: CircularProgressIndicator(
                                  value: _humidity.aviable
                                      ? _humidity.getPercentage()
                                      : 0,
                                  strokeWidth: circularStrokeWidth,
                                ),
                              ),
                              Text(
                                _humidity.aviable
                                    ? (_humidity.getPercentage() * 100)
                                            .toStringAsFixed(2) +
                                        "%"
                                    : "N/A",
                                style:
                                    TextStyle(fontSize: circularTextFontSize),
                              ),
                            ],
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Czujnik temperatury:"),
                          SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: circularWidth,
                                height: circularHeigh,
                                child: CircularProgressIndicator(
                                  value: _temperature.aviable
                                      ? _temperature.getPercentage()
                                      : 0,
                                  strokeWidth: circularStrokeWidth,
                                ),
                              ),
                              Text(
                                _temperature.aviable
                                    ? (_temperature.value).toStringAsFixed(2) +
                                        " °C"
                                    : "N/A",
                                style:
                                    TextStyle(fontSize: circularTextFontSize),
                              ),
                            ],
                          ),
                        ])
                  ]),
            ])));
  }
}
