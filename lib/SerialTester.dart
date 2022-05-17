import 'dart:typed_data';
import 'GRAMModel.dart';

import 'GRAMMessage.dart';
import 'dart:async';
import 'Log.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialTester {
// Serial Port Connection

  SerialPort serialPort;

  String device;

  SerialPortConfig theConfig;

  List<SerialPortConfig> configurations = [];

  List<int> dadesRebudes = [];

  Function callback;

  SerialTester(String device) {
    this.device = device;
  }

  void buildConfigurations(List<int> speeds) {
    configurations = [];

    for (int speed in speeds) {
      var config = SerialPortConfig();
      config.baudRate = speed; //model.scale.port;
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.setFlowControl(SerialPortFlowControl.none);
      configurations.add(config);
    }
  }



  int testConfigurations(List<int> speeds) {
    // callback reb goodConfigurations
    GRAMModel.shared.connection.active = false;
    GRAMModel.shared.connection.disconnect();

    buildConfigurations(speeds);

    this.callback = callback;

    for (var config in configurations) {
      int speed = testConfiguration(config);
      if (speed != 0) {
        return speed;
      }
    }
  }

  int testConfiguration(SerialPortConfig config) {
    try {
      if (serialPort != null) {
        serialPort.close();
      } else {
        serialPort = SerialPort(device);
      }

      var desc = "Trying ${serialPort.description}  at ${config.baudRate}";

      Log.shared.trace(
          "SerialTester.testConfiguration ", desc);

      if (!serialPort.openReadWrite()) {
        Log.shared.error(
            "SerialTester.testConfiguration Error when opening port  $device",
            "Not Opened ");
      }

      serialPort.config = config;
    } on SerialPortError catch (e) {
      Log.shared.error(
          "SerialTester.testConfiguration testConfiguration Opening Port @ $device" ,
          e.message);
    }

    dadesRebudes = [];

    //startWaitTimer();
    String message =
        GRAMMessage.readAddress(AddressType.deviceStateInformation).data();
    var now = DateTime.now().millisecondsSinceEpoch;
    var t = now;

    try {
      serialPort.write(Uint8List.fromList(message.codeUnits));

      while (t - now < 100.0) {
        var r = serialPort.read(10, timeout: 5);
        dadesRebudes.addAll(r);
        t = DateTime.now().millisecondsSinceEpoch;
      }
      if (dadesRebudes.contains(0x02) &&
          dadesRebudes.contains(0x03) &&
          dadesRebudes.contains(0x0d) &&
          dadesRebudes.contains(0x0A)) {
        Log.shared.trace(
            "SerialTester found speed ", "${config.baudRate} bauds");
        serialPort.close();
        serialPort.dispose();
        serialPort = null;
        GRAMModel.shared.connection.active = true;
        return config.baudRate;
      }
    } on SerialPortError catch (e) {
      Log.shared.error(
          "SerialTester.testConfiguration write error @ " + serialPort.name,
          e.message);
    }
    GRAMModel.shared.connection.active = true;

    return 0;
  }
}
