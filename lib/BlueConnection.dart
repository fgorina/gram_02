import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'Log.dart';
import 'PrinterConnectionProtocol.dart';

class BlueConnection implements PrinterConnectionProtocol{


 FlutterBlue flutterBlue ;

  BluetoothDevice  connectedDevice = null;
  List<BluetoothService> bluetoothServices = [];
  BluetoothDevice printDevice;
  BluetoothService printService;
  BluetoothCharacteristic printCharacteristic;

  StreamSubscription<BluetoothDeviceState> stateSubscription;

  Function(String) stateCallback;

  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
 // StreamSubscription<ScanResult> scanSubscription;
  StreamSubscription<List<ScanResult>> scanSubscription;
  String printerState = "Disconnected";
  bool scanning = false;
  int mtu = 20;

  bool withoutResponse = true;


  BlueConnection(FlutterBlue aflutterBlue){
    this.flutterBlue = aflutterBlue;
  }

 String name(){
   return printDevice.name;
 }

 bool  autoClose(){
    return false;
 }

  Future<void> delay(Duration d) async{
    return Future.delayed(d);
  }

  void close(){
    disconnect();
  }
  Future disconnect() async {

    if(printDevice != null) {
      await printDevice?.disconnect();
    }
    if(stateSubscription != null) {
      await stateSubscription?.cancel();
    }
      updateState(BluetoothDeviceState.disconnected);
      stateSubscription = null;
      printDevice = null;
      printService = null;
      printCharacteristic = null;

  }



  Future<void> doConnect(device) async {



    Log.shared
        .warning("BlueConnection.doConnect", "Connecting to " + device.name, []);

    flutterBlue?.setLogLevel(LogLevel.debug);
    await delay(Duration(milliseconds: 800));

    try {
      await device.connect(autoConnect: false); //await device.connect(autoConnect:false);

      //await printDevice?.requestMtu(128);
     // mtu = await printDevice?.mtu.first;

     // Log.shared.warning("BlueConnection.doConnect", "MTU {$mtu} " );


    } catch ( e) {
      Log.shared.error("BlueConnection.doConnect",
          "Error when connecting to " + device.name, [e]);
    }

    try {
      Log.shared.warning("BlueConnection.doConnect",
          "Discovering Services", []);
      List<BluetoothService> services = await device.discoverServices();
      print("Queried services");
      services.forEach((service) {
        Log.shared.warning("BlueConnection.doConnect",
            "Found service " + service.uuid.toString(), []);

        if (service.uuid.toString() ==
            "49535343-fe7d-4ae5-8fa9-9fafd205e455" ||
            service.uuid.toString() ==
                "00005500-d102-11e1-9b23-74f07d000000") {
          printService = service;
          this.updateState(deviceState);
          var characteristics = service.characteristics;
          for (BluetoothCharacteristic c in characteristics) {
            if (c.uuid == Guid("49535343-8841-43F4-A8D4-ECBE34729BB3") ||
                c.uuid == Guid("00005501-d102-11e1-9b23-74f07d000000")) {

              Log.shared.warning(
                  "BlueConnection.doConnect", "Found Char  " + c.toString(), []);

              printCharacteristic = c;
              this.updateState(deviceState);

            }
          }
        }
      });
    } catch (e) {
      Log.shared.error("BlueConnection.doConnect",
          "Error when discovering services for " + device.name, [e]);
    }
  }

 Future<void> doConnectNew(device) async {
   Log.shared.warning(
       "BlueConnection.doConnect", "Connecting to " + device.name, []);

  try {
    await device.connect(autoConnect: false, timeout: Duration(seconds: 20))
        .then((value) {

      /*
         printDevice?.requestMtu(128).then((void v)  {
           var mtu =  printDevice?.mtu.first.then((mtu) => Log.shared.warning("BlueConnection.doConnect", "MTU {$mtu} " ));

         }
          );

          */


      Log.shared.warning("BlueConnection.doConnect",
          "Discovering Services", []);
      device.discoverServices().then((services) {
        print("Queried services");
        services.forEach((service) {
          Log.shared.warning("BlueConnection.doConnect",
              "Found service " + service.uuid.toString(), []);

          if (service.uuid.toString() ==
              "49535343-fe7d-4ae5-8fa9-9fafd205e455" ||
              service.uuid.toString() ==
                  "00005500-d102-11e1-9b23-74f07d000000") {
            printService = service;
            this.updateState(deviceState);
            var characteristics = service.characteristics;
            for (BluetoothCharacteristic c in characteristics) {
              Log.shared.warning("BlueConnection.doConnect",
                  "Found char " + c.uuid.toString(), []);
              if (c.uuid == Guid("49535343-8841-43F4-A8D4-ECBE34729BB3") ||
                  c.uuid == Guid("00005501-d102-11e1-9b23-74f07d000000")) {
                Log.shared.warning(
                    "BlueConnection.doConnect",
                    "Found Char  " + c.toString(), []);

                this.printCharacteristic = c;
                this.updateState(deviceState);
              }
            }
          }
        });
      }).catchError((e) {
        Log.shared.error("BlueConnection.doConnect",
            "Error when discovering services " + device.name, [e]);
      }); // End of discoverServices error

    }).catchError((e) {
      Log.shared.error("BlueConnection.doConnect",
          "Error when discovering services " + device.name, [e]);
    }); // End of de deviceConnect error

  } catch (e) {
    Log.shared.error("BlueConnection.doConnect",
        "Error when connecting to  " + device.name, [e]);
  }
   Log.shared.warning("BlueConnection.doConnect",
       "Sortint de connect");
 }

  Future<void> scanPrinterOld(String name, Function(String) callback) async {

    stateCallback = callback;

    Log.shared.warning("BlueConnection.scanPrinter", "Starting Printer Scan", []);
    if(printDevice != null){
      Log.shared.warning("BlueConnection.scanPrinter", "Disconnecting", []);
      await disconnect();
      Log.shared.warning("BlueConnection.scanPrinter", "Disconnected", []);
    }
    flutterBlue?.setLogLevel(LogLevel.debug);
    Log.shared.warning("BlueConnection.scanPrinter", "Waiting for flutterBlue to stop scanning", []);
    await flutterBlue?.stopScan();


    try{
      if (flutterBlue == null){
        Log.shared.warning( "BlueConnection.scanPrinter", "Flutter Blue not loaded");
      }else{
        Log.shared.warning( "BlueConnection.scanPrinter", "Beginning scan");
      }



      /*scanSubscription = flutterBlue
          .scan(scanMode: ScanMode.lowLatency, timeout: Duration(seconds: 120), allowDuplicates: true)*/
      flutterBlue?.startScan(timeout: Duration(seconds: 20));

      scanSubscription =   flutterBlue?.scanResults.listen( (List<ScanResult> results) async {
        for (var result in results) {
          if (result.device.name != "") {
            Log.shared.info("BlueConnection.scanPrinter",
                "Found:  " + result.device.name);
          } else {
            Log.shared.trace("BlueConnection.scanPrinter",
                "Found:  " + result.device.id.toString());
          }
          if (result.device.name == name && printDevice == null) {
            Log.shared.warning(
                "BlueConnection.scanPrinter",
                "Will connect to " + result.device.name);
            scanSubscription?.cancel();
            scanSubscription = null;

            printDevice = result.device;
            await flutterBlue?.stopScan();
            await delay(Duration(milliseconds: 800));

            stateSubscription = printDevice?.state.listen((state) {
              deviceState = state;
              if (stateCallback != null) {
                updateState(state);
              }
            });
            scanning = false;

             await doConnect(printDevice);
             break;
          }
        }
      }
        );

      scanSubscription?.onDone(() {
        Log.shared.warning( "BlueConnection.scanPrinter", "Finished Scan");
      });

      scanSubscription?.onError((e) {
        Log.shared.error( "BlueConnection.scanPrinter", e.toString(), [e]);
      });

      return scanSubscription?.asFuture();
    } catch (e) {
      Log.shared.error("BlueConnection.scanPrinter", "Scanning for devices", [e]);
      scanning = false;
    }


    //Log.shared.info("Printer.scanPrinter",
    //    "Finished Scanning ");
    //scanning = false;
  }

 Future<void> scanPrinter(String name, Function(String) callback, int speed) async {

   stateCallback = callback;

   flutterBlue?.setLogLevel(LogLevel.debug);


   Log.shared.warning("BlueConnection.scanPrinter", "Starting Printer Scan", []);
   if(printDevice != null){
     Log.shared.warning("BlueConnection.scanPrinter", "Disconnecting", []);
     await disconnect();
     Log.shared.warning("BlueConnection.scanPrinter", "Disconnected", []);
   }

   Log.shared.warning("BlueConnection.scanPrinter", "Waiting for flutterBlue to stop scanning", []);
   await flutterBlue?.stopScan();
   await delay(Duration(milliseconds: 500)); // Wait some time

   try {
     if (flutterBlue == null) {
       Log.shared.warning(
           "BlueConnection.scanPrinter", "Flutter Blue not loaded");
     } else {
       Log.shared.warning("BlueConnection.scanPrinter", "Beginning scan");
     }


     /*scanSubscription = flutterBlue
          .scan(scanMode: ScanMode.lowLatency, timeout: Duration(seconds: 120), allowDuplicates: true)*/

     printDevice = null;

     await flutterBlue?.startScan(timeout: Duration(seconds: 20)).then((
         results) async {
       for (var result in results) {
         if (result.device.name != "") {
           Log.shared.info(
               "BlueConnection.scanPrinter", "Found:  " + result.device.name);
         } else {
           Log.shared.trace("BlueConnection.scanPrinter",
               "Found:  " + result.device.id.toString());
         }
         if (result.device.name == name && printDevice == null) {
           Log.shared.warning("BlueConnection.scanPrinter",
               "Will connect to " + result.device.name);
           printDevice = result.device;
         }
       }
       await delay(Duration(milliseconds: 500)); // Wait some time
       if(printDevice != null) {
         await doConnect(printDevice);
       }

       Log.shared.info("BlueConnection.scanPrinter", "Connected to " + printDevice.id.toString());

       stateSubscription = printDevice.state.listen((state) {
         deviceState = state;
         if (stateCallback != null) {
           updateState(state);
         }
       });
     }
     );
   } catch(e){
     Log.shared.error("BlueConnection.scanPrinter",
         "Error:  " + e.toString());
     }
 }

  void updateState(BluetoothDeviceState st){
    switch (st){
      case BluetoothDeviceState.disconnected:
          printerState =  "Disconnected";
        break;
      case BluetoothDeviceState.connecting:
        printerState =  "Connecting";
        break;
      case BluetoothDeviceState.connected:
        if (printService == null){
          printerState = "Looking for services";
        } else if (printCharacteristic == null){
          printerState = "Checking device type";

        }else {
          printerState = "Connected";
        }
        break;
      case BluetoothDeviceState.disconnecting:
        printerState =  "Disconnecting";
        break;
    }
    stateCallback(printerState);
  }

  Future<dynamic> write(List<int> data, int speed, {int chunkSize : 0}) async{

    int theChunkSize = chunkSize;

    if (data.length > mtu){
      theChunkSize = mtu;
    }
    if(theChunkSize == 0){
      try {
        if (withoutResponse == true) {
          await delay(Duration(milliseconds: 4));
        }
         return await printCharacteristic?.write(data, withoutResponse: withoutResponse);

      } catch (e) {
        Log.shared.error("BlueConnection.write", "Error in  writing data", [e]);
      }

    } else {

      try {


        var chunks = [];
        var nchunks = 0;
        for (var i = 0; i < data.length; i += theChunkSize) {
          chunks.add(data.sublist(i, ((i+theChunkSize ) > data.length) ? data.length : i + theChunkSize).toList());
          nchunks = nchunks + 1;
        }

        print("Chunks $nchunks");
        print("First chunk size  ${chunks[0].length}");

        for(int i = 0; i < nchunks; i = i + 1){
          var chunk = chunks[i];
          print("Printing chunk $i $chunk");
          await printCharacteristic?.write(chunk, withoutResponse: withoutResponse )   ;          //Era false
          await delay(Duration(milliseconds: 4));
        }


      } catch (e) {
        Log.shared.error("BlueConnection.write", "Error in  writing data", [e]);
      }
      return delay(Duration(milliseconds: 1));
    }
  }


}
