import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class Curl {
  Future<String> createCurl(dynamic data) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(dataLoader, receivePort.sendPort);

    SendPort sendPort = await receivePort.first;

    String response = await sendReceive(sendPort, data);

    return response;
  }

  static Future<void> dataLoader(SendPort sendPort) async {
    ReceivePort port = ReceivePort();

    sendPort.send(port.sendPort);

    await for (var data in port) {
      SendPort replyTo = data[0];
      String request = data[1];
      String device = data[2];
      SerialPort serialPort = new SerialPort(device);

      while (serialPort.isOpen) {}
      serialPort.open(mode: SerialPortMode.readWrite);

      String response = "";

      if (!request.endsWith('\n')) {
        request += '\n';
      }

      List<int> list = request.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);

      serialPort.write(bytes);

      Uint8List l;
      var c;
      do {
        l = serialPort.read(1);
        if (l.isNotEmpty) {
          c = String.fromCharCode(l[0]);

          if (c == '\n') {
            break;
          }

          response += c;
        }
      } while (true);

      serialPort.close();

      replyTo.send(response);
    }
  }

  Future sendReceive(SendPort port, data) {
    ReceivePort response = ReceivePort();
    port.send([response.sendPort, data['request'], data['device']]);
    return response.first;
  }
}
