import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue/flutter_blue.dart';
import 'Log.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'PrinterConnectionProtocol.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';


class SerialPrinterConnection implements PrinterConnectionProtocol {

  String printerState = "Disconnected";

  String portName = "/dev/ttyS4";

  SerialPortConfig config;

  SerialPort serialPort = null;

  String name(){
    return portName;
  }

  bool  autoClose(){
    return true;
  }

  Future<void> scanPrinter(String name, Function(String) callback, int speed) async {


    portName = name;

    try {
      if (serialPort != null) {
        serialPort.close();
      } else {
        serialPort = SerialPort(name);
      }





      if (!serialPort.openWrite()) {
        Log.shared.error(
            "SerialPrinterConnection.scanPrinter Error when opening port  $name",
            "Not Opened ");
      }

      await buildConfiguration(speed);
      var desc = "Trying ${serialPort.description}  at ${config.baudRate}";
      Log.shared.trace(
          "SerialPrinterConnection.scanPrinter ", desc);

    } on SerialPortError catch (e) {
      Log.shared.error(
          "SerialTester.testConfiguration testConfiguration Opening Port @ $name" ,
          e.message);
    }

  }
  Future<dynamic> write(List<int> data, int speed, {int chunkSize : 0}) async{
    if ( serialPort == null) {
      await scanPrinter(portName, null, speed);
    }
    serialPort.write(Uint8List.fromList(data));

  }

  void close() {
    if (serialPort != null){
      serialPort.close();
      serialPort.dispose();
      serialPort = null;
    }
  }

  void buildConfiguration(int speed) async {

     String msg = "Configuration at {$speed}\r\n";
     print(msg);
      config = SerialPortConfig();
      config.baudRate = speed;
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.setFlowControl(SerialPortFlowControl.none);

      serialPort.config = config;


      //await write(msg.codeUnits);

  }


}