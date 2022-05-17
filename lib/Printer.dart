import 'package:flutter_blue/flutter_blue.dart';
import 'package:sprintf/sprintf.dart';
import 'Log.dart';

class Printer {
  final  FlutterBlue flutterBlue = FlutterBlue.instance;

  BluetoothDevice connectedDevice;
  List<BluetoothService> bluetoothServices;
  BluetoothDevice printDevice;
  BluetoothService printService;
  BluetoothCharacteristic printCharacteristic;

  bool scanning = false;

  Future<void> scanPrinter(String name) async {
    Log.shared.warning("Printer.scanPrinter", "Starting Printer Scan", []);

    //flutterBlue.setLogLevel(LogLevel.notice);

    /*  try {
      await flutterBlue.startScan(scanMode: ScanMode(2), timeout: Duration(seconds: 4));
    }catch(e){
       Log.shared.error("Printer.scanPrinter", "Starting Scan", [e]);
       scanning = false;
       return;
    }
    scanning = true;
    flutterBlue.scanResults.listen((List<ScanResult> results){
      for (ScanResult result in results) {
        if(result.device.name == name) {
          Log.shared.info("Printer.scanPrinter", "Found "+result.device.name);
          printDevice = result.device;
          flutterBlue.stopScan();
          scanning = false;
          doConnect(printDevice);
        }
      }
    });
*/
    flutterBlue.stopScan();
    try {

      scanning = true;

      List<BluetoothDevice> cd = await flutterBlue.connectedDevices;

      Log.shared.info("Printer.scanPrinter",
          "Found number of devices " + sprintf("%d", [cd.length]));

      cd.forEach((device) {
        Log.shared.info("Printer.scanPrinter",
            "Found in connected devices " + device.name + " " + device.id.toString());
        if(device.name == name) {
          printDevice = device;
          scanning = false;
          doConnect(printDevice);
          return;
        }
      });
    } catch (e) {
      Log.shared.error("Printer.scanPrinter", " Looking for connected devices", [e]);
      scanning = false;
    }

    try{
      flutterBlue
          .scan(scanMode: ScanMode.lowLatency, timeout: Duration(seconds: 20), allowDuplicates: true)
          .listen((ScanResult result) {
        Log.shared.info("Printer.scanPrinter",
            "Found " + result.device.name + " " + result.device.id.toString());

        if (result.device.name == name && printDevice == null) {
          Log.shared.info(
              "Printer.scanPrinter", "Will connect to " + result.device.name);
          printDevice = result.device;
          flutterBlue.stopScan();
          scanning = false;
          doConnect(printDevice);
        }
      });
    } catch (e) {
      Log.shared.error("Printer.scanPrinter", "Scanning for devices", [e]);
      scanning = false;
    }
    Log.shared.info("Printer.scanPrinter",
        "Finished Scanning ");
    scanning = false;
  }

  Future<void> writeBarcode(String s) async {
    // Set the width of barcode
    await printCharacteristic.write([29, 72, 2]); // Digits below
    await printCharacteristic.write([29, 119, 3]); // Width
    print(s.toUpperCase().codeUnits);
    List<int> bytes = [];
    bytes.addAll([29, 107, 4]);
    bytes.addAll(s.codeUnits);
    bytes.add(0);

    //bytes.add(10);
    try {
      await printCharacteristic.write(bytes);
    } catch (e) {
      Log.shared
          .error("Printer.scanPrinter", "Error when printing barcode", [e]);
    }
  }

  Future<void> writeString(String s) async {
    try {
      await printCharacteristic.write((s).codeUnits);
    } catch (e) {
      Log.shared.error("Printer.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setFontSize(int size) async {
    int s = (size * 16) + size;
    await printCharacteristic.write([29, 33, s]);
  }

  Future<void> setBold(int on) async {
    await printCharacteristic.write([27, 69, on]);
  }

  Future<void> centerLine() async {
    await printCharacteristic.write([27, 97, 1]);
  }

  Future<void> leftLine() async {
    await printCharacteristic.write([27, 97, 0]);
  }

  Future<void> rightLine() async {
    await printCharacteristic.write([27, 97, 2]);
  }

  Future<void> nextPage() async {
    try {
      await printCharacteristic.write([12]);
    } catch (e) {
      Log.shared.error("Printer.nextPage", "Error in  next page", [e]);
    }
  }

  Future<void> doConnect(device) async {
    Log.shared
        .warning("Printer.scanPrinter", "Connecting to " + device.name, []);

    try {
      await device.connect();
    } catch (e) {
      Log.shared.error("Printer.scanPrinter",
          "Error when connecting to " + device.name, [e]);
    }

    try {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        Log.shared.warning("Printer.doConnect",
            "Found service " + service.uuid.toString(), []);

        if (service.uuid.toString() == "49535343-fe7d-4ae5-8fa9-9fafd205e455") {
          var characteristics = service.characteristics;
          for (BluetoothCharacteristic c in characteristics) {
            if (c.uuid == Guid("49535343-8841-43F4-A8D4-ECBE34729BB3")) {
              Log.shared.warning(
                  "Printer.doConnect", "Found Char  " + c.toString(), []);

              printCharacteristic = c;
            }
          }
        }
      });
    } catch (e) {
      Log.shared.error("Printer.scanPrinter",
          "Error when discovering services for " + device.name, [e]);
    }
  }

  Future<void> disconnect() async {
    await printDevice.disconnect();
    printDevice = null;
    printService = null;
    printCharacteristic = null;
  }

  Future<void> doPrint() async {
    await writeString("My printing String");
  }
}
