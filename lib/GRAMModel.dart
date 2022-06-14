import 'dart:typed_data';

import 'GRAMMessage.dart';
import 'Translation.dart';
import 'dart:convert';
import 'GRAMWeightRecord.dart';
import 'Units.dart';
import "Measurement.dart";
import 'RangeMode.dart';
import 'Scale.dart';
import "WeightRecord.dart";
import 'TareRecord.dart';
import "Log.dart";
import 'dart:io';
import 'dart:ui';
import 'GRAMConnection.dart';
import 'LocalFileSystemUtilities.dart';
import 'ScaleDatabase.dart';
import 'License.dart';
import 'dart:math';
import 'package:devicelocale/devicelocale.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'DataTypesUtilities.dart';
import 'CSVDatabase.dart';
import 'Label.dart';
import 'PrinterProtocol.dart';
import 'CPCLPrinter.dart';
import 'ESCPrinter.dart';
import 'BlueConnection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'SerialTester.dart';
import 'PrinterConnectionProtocol.dart';
import 'package:flutter_blue/flutter_blue.dart';
import "SerialPrinterConnection.dart";
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum DisplayFields {
  user,
  userCode,
  customer,
  customerCode,
  number,
  date,
  time,
  item,
  netWeight,
  tare,
  grossWeight,
  code,
  codeCode,
  codeBarcode,
  netWeightNumber,
  grossWeightNumber
}

enum DeviceType {
  terminal,
  phone,
  tablet
}

DeviceType deviceType = DeviceType.phone;


const displayFieldsTitles = {
  DisplayFields.user: 'User',
  DisplayFields.customer: 'Customer',
  DisplayFields.number: 'Number',
  DisplayFields.date: 'Date',
  DisplayFields.time: 'Time',
  DisplayFields.item: 'Item',
  DisplayFields.netWeight: 'Net Weight',
  DisplayFields.tare: 'Tare',
  DisplayFields.grossWeight: 'Gross Weight'
};

List<DisplayFields> fields = [DisplayFields.user, DisplayFields.customer, DisplayFields.number,
  DisplayFields.date, DisplayFields.time, DisplayFields.item,
  DisplayFields.netWeight, DisplayFields.tare, DisplayFields.grossWeight];

class GRAMModel {


  static final GRAMModel shared = GRAMModel._constructor();


  // displayedFiels is for selecting which fields are shown in the record view

  var displayedFields = {
    DisplayFields.user: true,
    DisplayFields.customer: true,
    DisplayFields.number: true,
    DisplayFields.date: true,
    DisplayFields.time: true,
    DisplayFields.item: true,
    DisplayFields.netWeight: true,
    DisplayFields.tare: true,
    DisplayFields.grossWeight: true
  };


  var theme = 0;  // theme = 0 -> Clear, 1 -> Dark
  // Scale process info

  var holdEnabled = false;
  var holding = false;
  var goneToZero = false;
  var lastTimestamp = DateTime.now();

  var recordsToZero = true;
  var zeroSinceLastRecord = true;

  var limitsEnabled = false;
  var lowLimit = Measurement(0.0, Unit.grams);
  var upperLimit = Measurement(0.0, Unit.grams);


  // Measurement flags

  var zero = false;
  var tareOn = false;
  var stable = false;
  var netWeight = false;
  var tareMode = 0;
  var highResolution = false;
  var initialZero = false;
  var overload = false;
  var negative = false;
  var range = 1;
  var presetTare = false;

  var initialZeroRange = 0;

  var presentedWeight = Measurement(0.0, Unit.grams);

  var weight = Measurement(0.0, Unit.grams);
  var tare = Measurement(0.0, Unit.grams);


  get nWeight => weight - tare;

  set nWeight(nWeight) {
    weight = nWeight + tare;
  }

  var scale = Scale();
  int serialSpeed = 115200;

  var serialNumber = ""; // Changing serial number triggers scale data request, license verification and options enabling
  var deviceId = 1; // Device Id de la balança
  var moduleBoardCode = "";
  var firmwareVersion = "";
  var optionalBoard = "";
  int outputRate = 0;
  int adSpeed = 0;
  int baudRate = 0;

  int adcCountsFiltered = 0;
  int initialZeroCounts = 0;
  double slopeDivisor = 1.0;

  int geoCode = 16;
  int geoCodeAdjustment = 16;

  String lastChange = "";
  int counterChange = 0;

  bool allowNegativeWeight = false;
  var scaleUnit = Unit.grams; // Scale default unit
  var rangeMode = 0; // range mode for the scales
  var modes = [RangeMode(0.0, 0.0), RangeMode(0.0, 0.0)];
  var decimalPointPosition = 0;
  var resolutionFactor = 1.0;

  var sealed = false;

  var scaleName = "    ";  // Parameter ssidName

  // Just for configuration

  // AS AP

  String apPassword = "";  // Entenc  que es ssidPassword
  String ipBaseAddress = "";  // ipAddress  todo
  bool isAccessPoint = false; // accessPoint todo

  int tcpServerPort = -1;   // tcpServerPort todo
  int udpRemotePort = -1; // udpRemotePort todo
  int udpLocalPort = -1; // udpLocalPort todo

  // AS Standalone  Aquestes es llegeixen OK

  var netName = "****";     // networkNane full
  var netPassword = "****"; // networkPassword full
  var netDhcp = false;    //netDhcp ful
  var netIp = "****";   // netIp full

  // HASH configuration

  String strHash = "740163149BAF6BDBC26910E4173C68B0";

  List<int> hash = [0, 0, 0, 0];  // hash original
  List<int> currentHash = [0, 0, 0, 0];  // hash que enviem i rebem

  bool hashOk = false;

  List<int> lastRotation = [0, 0];
  List<int> lastLastRotation = [0, 0];

  Timer  HRTimer;
  int maxHRTime = 2;  // Maximum seconds in HR if sealed


  var deviceState = DeviceError.noError;

  get deviceStateMessage => deviceErrorString[deviceState];

  set deviceStateMessage(deviceStateMessage) {

  }

  // Scale options

  var autoTare = false;
  var tareOnStability = false;
  var zeroTrackingDevice = false;
  var zeroTrackingRange = 0;
  var motionFilter = false;
  var livestockFilter = false;
  var filterLevel = 0;
  var stabilityRange = 0;


  // Aditional Info

  var _user = "<User>";
  var _userCode = "<>";
  var _customer = "<Customer>";
  var _customerCode = "<>";
  var _code = "<Code>";
  var _codeCode = "<>";
  var _codeBarcode = "<>";

  var urlUsers = "http://192.168.1.21/users.csv";
  var urlProducts = "http://192.168.1.21/products.csv";
  var urlCustomers = "http://192.168.1.21/customers.csv";
  var urlSend = "";

  var printing = 0; // 0 -> No print , 1-> Print label 1, 2 -> Print label 2, 3 -> Print personalized ñabeñ
  var  barcode = 4; // Barcode to print in std labels. -1 -> No barcode
  var leftMargin = 0; // Left label margin in characters. 1 char 12 pt
  var labelName = "";
  Label label;
  int serialPrinterSpeed = 9600;
  int printerWidth = 36;



  // Databases

  var number = 0;
  List<WeightRecord> recordedWeights = [];
  var weightsName = "weights";

  TareDatabase taresDatabase = TareDatabase.shared;
  ScaleDatabase scalesDatabase = ScaleDatabase.shared;

  List<CSVDatabase> databases = [];



  // Connection

  SerialTester tester = SerialTester("");

  GRAMConnection connection;

  // Manage subscriptions

  List subscriptors = [];

  // Subscripcions tècnica (ADC Counts etc

  List subscriptorsTecnic = [];

  Future<List<WeightRecord>> testJSON;

  // Manual

  String manualURL;

  // Optional Features

  bool scannerEnabled = false;
  bool exportEnabled = false;

  // Disable license restrictions

  bool disableRestrictions = (deviceType ==  DeviceType.terminal) ;


  // Localization
  String locale = "en_US";
  Translation tr;

  // Thee to be set at start of application
  bool darkMode = false;

  // Application State

  AppLifecycleState appState = AppLifecycleState.resumed;

  // last data  a

  GRAMWeightRecord lastWeightRecord;

  // Printer

  PrinterConnectionProtocol printerConnection;

  PrinterProtocol aprinter ;
  String printerName = (deviceType ==  DeviceType.terminal) ? "/dev/ttyS4" :  "HM-A300-0a1e"; // ME31";
  String printerType = "ESC";

  int counter = 0;

  // Anti Tamper

  String apkHash = "Calculating";

  // Show / Hide QR Code in visor

  bool showQr = false;


  GRAMModel._constructor(){
    initModel();
   }

  void initModel() async {
    await getAndShowDeviceData();
    // Mirar de modificar la ScaleDatabase en cas que tan sols tingui el Config

    scalesDatabase.initDatabase();
    getManualURL();
    getLocaleInformation();

    /*
    try {
       printer.scanPrinter("ME31");
    }catch(e){
      Log.shared.error("Model._constructor", "Starting Scan", [e]);
    }
  */

    this.number = 0;

    hash[0] = int.parse(strHash.substring(0, 8), radix:16);
    hash[1] = int.parse(strHash.substring(8, 16), radix:16);
    hash[2] = int.parse(strHash.substring(16, 24), radix:16);
    hash[3] = int.parse(strHash.substring(24, 32), radix:16);

    var data = strHash.substring(0, 8) + " " + strHash.substring(8, 16) + " " +
        strHash.substring(16, 24) + " " + strHash.substring(24, 32);

    Log.shared.error("Model._constructor Hash", data );

    currentHash = List.from(hash);

    hashOk = true;

    getApkHash().then((s) {
      apkHash = s;
    });

    didReceiveData();

    urlUsers = "file://" + await dataPath() + "/users.csv";
     urlProducts = "file://" + await dataPath() + "/products.csv";
     urlCustomers = "file://" + await dataPath() + "/customers.csv";


  }

  static Future<DeviceType> getDeviceType() async{
    DeviceInfoPlugin deviceInfo = await DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var version = androidInfo.version;
    //var sdkInt = version.sdkInt;
    var deviceModel = androidInfo.model;

    DeviceType aDeviceType = deviceModel == "SBC3300" ? DeviceType.terminal : DeviceType.phone;

    return aDeviceType;
  }

  void getAndShowDeviceData() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Log.shared.warning("main.initState", "App Name : " + packageInfo.appName);
    Log.shared.warning("main.initState", "Package  Name : " +packageInfo.packageName);
    Log.shared.warning("main.initState", "Version  : " + packageInfo.version + " (" + packageInfo.buildNumber+ ")");
    Log.shared.warning("main.initState", "Signature : " +packageInfo.buildSignature);
    Log.shared.warning("main.initState", "APK Hash : " + this.apkHash);



    DeviceInfoPlugin deviceInfo = await DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var version = androidInfo.version;
    var sdkInt = version.sdkInt;
    var deviceModel = androidInfo.model;

    deviceType = deviceModel == "SBC3300" ? DeviceType.terminal : DeviceType.phone;

    Log.shared.warning("main.initState", "codename : " + version.codename);
    Log.shared.warning("main.initState", "sdkInt :  {$sdkInt}");
    Log.shared.warning("main.initState", "device model :  {$deviceModel}");

    this.disableRestrictions = (deviceType ==  DeviceType.terminal) ;


  }
  Future<String> getPackageCodePath() async{
    return (await DeviceApps.getApp("es.gorina.gram_02")).apkFilePath;

  }
  Future<String> getApkHash() async {
    String apkFilePath = await getPackageCodePath();
    Log.shared.info("LicenseViiew.apkVerifyWithHash", apkFilePath);
    var apkFile = File(apkFilePath);

    try{

      var output = AccumulatorSink<Digest>();

      var input = md5.startChunkedConversion(output);
      List<int> bytes ;

      final r = ChunkedStreamReader(apkFile.openRead());

      bytes = await(r.readChunk(16384));

      while(bytes.length > 0){
        input.add(bytes);
        bytes = await(r.readChunk(16384));

      }

      r.cancel();
      input.close();
      var digest = output.events.single;
      Log.shared.info("apkVerifyWithHash", "$digest");
      return "$digest";



    }catch(e){
      Log.shared.error("LicenseView.apkVerifyWithHash", e.toString());
    }

  }

  Future<void> getLocaleInformation()  async {
    var value = await Devicelocale.currentLocale;
    //var value = await DeviceLocale.getCurrentLocale();
    locale =  value.toString();
    tr =  Translation(locale: locale);

  }


  void getManualURL() async {

    var dir = await localPath();
    var path = dir + "/Manual/index.html";
    var url = "file://" + path;
    manualURL = url;

  }

  // Get connection state

  bool isConnected(){
    if (this.connection == null){
      return  false;
    }else{
    return this.connection.connectionState == GRAMConnectionState.connected || this.connection.connectionState == GRAMConnectionState.streaming;
    }
  }

  // Get connection state

  bool isStreaming(){


    return this.connection == null ? false : this.connection.connectionState == GRAMConnectionState.streaming;
  }

  // Defaults management

  Future<File> saveDefaults() async{

    var dir = await localPath();
    var path = "$dir/defaults.json";
    var file = File(path);


    Map<String, String> json = {
      'user': _user,
      'usercode' : _userCode,
      'customer': _customer,
      'customercode': _customerCode,
      'item': _code,
      'itemcode': _codeCode,
      'itembarcode': _codeBarcode,
      'scale': scale.name,
      'printing': sprintf("%d", [printing]),
      'barcode' : sprintf("%d", [barcode]),
      'leftmargin' : sprintf("%d", [leftMargin]),
      'label' : labelName,
      'urlusers': urlUsers,
      'urlcustomers': urlCustomers,
      'urlproducts': urlProducts,
      'printername' : printerName,
      'printertype' : printerType,
      'serialprinterspeed' : sprintf("%d", [serialPrinterSpeed]),
      'printerwidth' : sprintf("%d", [printerWidth]),
      'urlsend' : urlSend,

    };
    var jsonData = JsonEncoder().convert(json);

    print("SAVE DEFAULTS");
    print(jsonData);
    try {
      var afile = await file.writeAsString(jsonData);
      return afile;
    }catch (e) {
      print("Error: $e");
      return  null;
    }
  }


  Future<void> loadDefaults() async{
    var dir = await localPath();
    var path = "$dir/defaults.json";
    var file = File(path);


    printerName = (deviceType ==  DeviceType.terminal) ? "/dev/ttyS4" :  "HM-A300-0a1e"; // ME31";

    try {
      var jsonData = await file.readAsString();
      print("LOAD DEFAULTS");
      print(jsonData);
      if (jsonData != "Error!") {
        var json = JsonDecoder().convert(jsonData);
        _customer = json['customer'];
        _customerCode = json['customercode'];
        _user = json['user'];
        _userCode = json['usercode'];
        _code = json['item'];
        _codeCode = json['itemcode'];
        _codeBarcode = json['itembarcode'];

        urlUsers = json['urlusers'];
        urlCustomers = json['urlcustomers'];
        urlProducts = json['urlproducts'];
        urlSend = json['urlsend'];

        labelName = json['label'];

        if(labelName != null){
          label = Label();
          label.load(labelName);
        }


        var scaleName = json['scale'];
        if (scaleName != null) {
          scale = scalesDatabase.scaleForName(scaleName);
        } else {
          scale = scalesDatabase.first();
        }

        var sprinting = json['printing'];
        if (sprinting == null){
          printing = 0;
        }else{
          var iprinting = int.parse(sprinting);
          printing = iprinting;
        }

        var sbarcode = json['barcode'];
        if (sbarcode == null){
          barcode = -1;
        }else{
          var ibarcode = int.parse(sbarcode);
          barcode = ibarcode;
        }

        var sleftmargin = json['leftmargin'];
        if (sleftmargin == null){
          leftMargin = 0;
        }else{
          var ileftMargin = int.parse(sleftmargin);
          leftMargin = ileftMargin;
        }

        var sprinter = json['printername'];

        if (sprinter != null){
          printerName = sprinter;
        }

        printerConnection = printerName.startsWith("/dev/tty") ? SerialPrinterConnection() :  BlueConnection(FlutterBlue.instance);

        var tprinter = json['printertype'];

        if (tprinter != null){
          printerType  = tprinter;
        }

        if(printerType == 'ESC'){
          aprinter = ESCPrinter(printerConnection);
        } else {
          aprinter = CPCLPrinter(printerConnection);
        }

        var sspeed = json['serialprinterspeed'];

        if (sspeed != null){
          int speed = int.parse(sspeed);

          if (speed != null && speed != 0){
            serialPrinterSpeed = speed;
          }
        }

        var swidth = json['printerwidth'];

        if (swidth != null){
          int width = int.parse(swidth);

          if (width != null && width != 0){
            printerWidth = width;
          }
        }


        return json;
      } else {
        return null;
      }
    } catch(e){
      print("Error $e a $path");
      scale = scalesDatabase.first();
    }
  }

  void checkLicensed()  {

    didReceiveData();

  }

  Future<void> printLabel1(PrinterProtocol printer) async{
    await printer.startLabel(420);
    await printer.writeString("\n\n\n\n\n");
    await printer.setFontSize(2);
    await printer.setBold(1);
    await printer.centerLine();
    await printer.writeString(sprintf("%d\n\n", [counter]));

    await printer.writeString(presentedWeight.valueFormatted(decimalPointPosition, grouping: false) + " " + nWeight.symbol()+"\n\n\n");
    //await printer.writeString(weight.formatted(2)+"\n\n\n");
    await printer.setBold(0);

    if (_codeBarcode.isNotEmpty){
      if (barcode == 9){
        await printer.writeQRCode(_codeBarcode);
      }else if (barcode >= 0 && barcode < 9){
        await printer.writeBarcode(_codeBarcode, barcode);
      }
    }
    await printer.writeString("\n");

   // await printer.writeString("\n\n\n\n\n\n");
    await printer.endLabel();

  }

  Future<void> printLabel2(PrinterProtocol printer, record) async{

    int lr = (printerWidth / 2).floor();    // Ex 32 / 2 ->16
    int ll = printerWidth - lr - 1;   // 32 - 16 - 1 -> 15
    lr = lr - leftMargin;

    String sMargin = "";

    for (int i = 0; i < leftMargin; i++){
      sMargin += " ";
    }

    await printer.startLabel(420);
    await printer.setFontSize(1);
    await printer.leftLine();
    await printer.writeString("\n");

    String sl = justifyRight(dateString(record.when) + " " + shortTimeString(record.when) , ll, " ");
    String sr = justifyRight("N:" + justifyLeft(sprintf("%d", [counter]), 5, '0'), lr, " ");

    await printer.writeString(sMargin + sl + "|" + sr + "\n");

    sl = justifyRight("User: "+ record.user, ll, " ");
    sr = justifyRight(record.customer, lr, " ");

    await printer.writeString(sMargin + sl+ "|" + sr +  "\n");
    await printer.writeString(sMargin + justifyRight("_", printerWidth - leftMargin, "_")    + "\n\n");
    await printer.writeString(sMargin + justifyRight("Product: " + record.code, ll + lr - leftMargin, " ") + "\n");
    await printer.writeString(sMargin + "Net: \n");
    await printer.setFontSize(2);
    await printer.setBold(1);

    await printer.centerLine();

    await printer.writeString(presentedWeight.valueFormatted(decimalPointPosition, grouping: false) + " " + nWeight.symbol()+"\n");
    //await printer.writeString((record.grossWeight - record.tare).formatted(2)+"\n");
    await printer.setBold(0);

    await printer.writeString("\n");
     await printer.setFontSize(1);
    await printer.leftLine();
    await printer.writeString(justifyRight("_", printerWidth, "_")    + "\n\n");

    sl = justifyRight("Brut: "+ record.grossWeight.valueFormatted(decimalPointPosition, grouping: false) + " " + nWeight.symbol(), ll, " ");
    sr = justifyLeft( " Tare: " + record.tare.valueFormatted(decimalPointPosition, grouping: false)+ " " + nWeight.symbol(), lr, " ");

    await printer.writeString(sMargin + sl +  " " + sr + "\n");
    await printer.writeString(sMargin + justifyRight("_", printerWidth - leftMargin, "_")    + "\n\n");

    if (_codeBarcode.isNotEmpty){
      if (barcode == 9){
        await printer.writeQRCode(_codeBarcode);
      }else if (barcode >= 0 && barcode < 9){
        await printer.writeBarcode(_codeBarcode, barcode);
      }
    }
     await printer.leftLine();

    await printer.writeString("\n");

    await printer.endLabel();

  }

  // Recorded Weights Management

  Future<void> sendWeight(Map jsonMap) async {

    String data = json.encode(jsonMap);
    // List<int> utf8Data = utf8.encode(data);
    HttpClient httpClient = new HttpClient();
    httpClient.postUrl(Uri.parse(urlSend)).then((request) {
      request.headers.add(HttpHeaders.contentTypeHeader, "text/json");
      request.write(data);

      return request.close();

    }).then((HttpClientResponse response) {
      utf8.decodeStream(response).then((body) {
        print(body);
      });
    });

    return;



}
  void recordWeight() async{

    if (weight.value == 0.0){
      return;
    }

    number += 1;
    var newRecord = WeightRecord(
        serialNumber,
        scaleName,
        _user,
        _userCode,
        _customer,
        _customerCode,
        number,
        DateTime.now(),
        _code,
        _codeCode,
        _codeBarcode,
        weight,
        tareOn ? tare : Measurement(0.0, weight.unit),
        decimalPointPosition);
    recordedWeights.insert(0, newRecord);
    doSaveRecords();
    //recordedWeights.append(newRecord)
    sendUpdateMessage();
    // Print

    if (urlSend.isNotEmpty){
      sendWeight(newRecord.toJsonT());
    }
    counter += 1;
    zeroSinceLastRecord = false;

    if (printing == 1 && (scannerEnabled || disableRestrictions)){
      await printLabel1(aprinter);
    }else if (printing == 2 && (scannerEnabled || disableRestrictions))
    {
      await printLabel2(aprinter, newRecord);
    }else if (printing == 3 && (scannerEnabled || disableRestrictions) &&  label != null){ // Print defined label
      await label.load(labelName);
      await label.printLabel(aprinter, record: newRecord, printerWidth: printerWidth);
    }



  }

  void resetCounter(){
    counter = 0;
  }

  recordedWeightsToJson(){
    List jsonList = [];
    recordedWeights.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  List<WeightRecord> decodeRecordedWeights(List<dynamic> jsonList){
    List<WeightRecord> records = [];
    jsonList.map((item) => records.add(WeightRecord.fromJson(item))).toList();
    return records;
  }

  void doSaveRecords(){
    _saveRecords();
  }

  void doSaveAsCSV(){
   _saveCSVRecords();

  }
  Future<File> _saveRecords() async {
    var dir = await localPath();
    var path = "$dir/$weightsName.json";

    var file = File(path);

    var jsonData = JsonEncoder().convert(recordedWeightsToJson());

    try {
      var afile = await file.writeAsString(jsonData);
      return afile;
    }catch (e) {
      print("Error: $e");
      return  null;
    }

   }

  Future<File> _saveCSVRecords() async {
    var dir = await localPath();
    var path = "$dir/$weightsName.csv";
    return await doSaveCSVRecords(path);
  }

  Future<File> doSaveCSVRecords(String path) async {

    var file = File(path);


     var data = this.recordsAsCSV();
     try {
       var afile = await file.writeAsString(data);
       return afile;
     }catch (e) {
       print("Error: $e");
       return  null;
     }

   }

  Future<List<WeightRecord>> loadRecords() async{
    var dir = await localPath();
    var path = "$dir/$weightsName.json";
    var file = File(path);

    try {
      var jsonData = await file.readAsString();

      if (jsonData != "Error!") {
        var jsonList = JsonDecoder().convert(jsonData);
        var v = decodeRecordedWeights(jsonList);
        return v;
      } else {
        return null;
      }
    }catch(e){
      print("Error $e al llegir $path");
    }
   }


  didReceiveData() {

    sendUpdateMessage();
  }

  updateData(GRAMWeightRecord record) {


    this.weight = Measurement(record.weight, unitsAbrev[record.wunit]);
    this.tare = Measurement(record.tare,  unitsAbrev[record.tunit]);
    this.range = record.range;

    // When sealed maximum HR time = 4s

    if(!this.highResolution  && record.highResolution && this.sealed){
      HRTimer = Timer(Duration(seconds: maxHRTime), () {
        if (this.highResolution){
          this.connection.enqueueMessage(GRAMMessage.highResolutionMode());
          HRTimer = null;
        }
      });
    }

    // flags

    this.zero = record.zero;
    this.tareOn = record.tareOn;
    this.stable = record.stable;
    this.netWeight = record.netWeight;
    this.tareMode = record.tareMode;
    this.highResolution = record.highResolution;
    //this.initialZero = record.initialZero;  // Sembla que dona false encara que sigui true!!!

    this.overload = record.overload;
    this.negative = record.negative;
    this.range = record.range;
    this.presetTare = record.presetTare;
    this.decimalPointPosition = record.decimalPosition;
    this.lastTimestamp = DateTime.now();


    if (this.overload) {
      this.deviceState = DeviceError.overload;
    }

    else if (this.negative) {
      this.deviceState = DeviceError.negativeWeight;
    } else {
      this.deviceState = DeviceError.noError;
    }
    // Compute new states

    var newState = this.computePresentedWeight();

    this.presentedWeight = newState[0];
    this.holding = newState[1];
    this.goneToZero = newState[2];

    if (this.zero && this.stable) {
      this.zeroSinceLastRecord = true;
    }
    // Update Screen
    didReceiveData();
  }

  // Returns new Measurement, if it is holding and if it has gone to zero


  computePresentedWeight() {
    if (holdEnabled) {
      if (holding) { // While already holding
        if ((goneToZero && stable && !zero) || (nWeight > presentedWeight &&
            stable)) { // Update weight when gone to zero
          return [nWeight, holding, false];
        } else if (zero) { // Set goneToZero to true
          return [presentedWeight, true, true];
        } else { // Normal case, propagate gonetozero values
          return [presentedWeight, true, goneToZero];
        }
      } else { // Not Holding
        if (stable && !zero) { // Got a value, hold it
          return [nWeight, true, false];
        } else { // Not a stable value, just pass it
          return [nWeight, false, false];
        }
      }
    } else { // Normal case
      return [nWeight, false, false];
    }
  }

  // Returns a scaled value according decimalPointPosition and highResolution
  scaleValue(double value) {
    var v = value;
    for (int i = 0; i < decimalPointPosition; i++) {
      v = v / 10.0;
    }

    if (highResolution) {
      v = v * 10.0;
    }

    return v;
  }


  enableHolding() {
    holdEnabled = true;
    goneToZero = false;
    holding = false;
    didReceiveData();
  }

  disableHolding() {
    holdEnabled = false;
    goneToZero = false;
    holding = false;
    didReceiveData();
  }

  setLimits(double lower, double upper) {
    lowLimit = Measurement(lower, scaleUnit);
    upperLimit = Measurement(upper, scaleUnit);
    print("Low Limit " + lowLimit.valueFormatted(0) + " Upper Limit " + upperLimit.valueFormatted(1));
    limitsEnabled = true;
    didReceiveData();
  }

  cancelLimits() {
    limitsEnabled = false;
    didReceiveData();
  }


  setUser(List<dynamic> u) async{
    _user = u[1];
    _userCode = u[0];
    await saveDefaults();
    didReceiveData();
  }

  setCustomer(List<dynamic> c) async{
    _customer = c[1];
    _customerCode = c[0];
    await saveDefaults();
    didReceiveData();
  }

  setItem(List<dynamic> c) async{
    _code = c[1];
    _codeCode = c[0];
    _codeBarcode = c[2];
    await saveDefaults();
    didReceiveData();
  }

  setPrinting(int v) async {
    printing = v;
    await saveDefaults();
  }

  String getUser({int max = 100}){
    if(_user == null){
      return "";
    }
    return _user.substring(0, min(max, _user.length));
  }

  String getCustomer({int max = 100}){
    if(_customer == null){
      return "";
    }
    return _customer.substring(0, min(max, _customer.length));
  }

  String getItem({int max = 100}){
    if(_code == null){
      return "";
    }
    return _code.substring(0, min(max, _code.length));
  }

  // HASH functions

  void resetHash(){

    currentHash = List.from(hash);

    hashOk = true;
    lastRotation = [0, 0];
    lastLastRotation = [0, 0];
  }

  void rotateHash(int n){

    for(int i = 0; i < 4; i++){
      currentHash[i] =  rotate(currentHash[i], n);
    }
    hashOk = true;
  }


  int rotate(int value, int bits){
    var len = 32;
    var c =  bits & (len-1);
    var mask = 0xffffffff;

    var result = value << c | value >> (len - c);

    // Must escape the bytes
    var bytes = [(result & 0xff000000) >> 24, (result & 0xff0000) >> 16,(result & 0xff00) >> 8,(result & 0xff) ].map((e) => escapeByte(e)).toList();
    var escapedResult = ( bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3] ;

    return escapedResult & mask;
  }

  int escapeByte(int b){
    if (b == 0x00){
      return 0x01;
    }else if (b == 0xaa){
      return 0xab;
    }else {
      return b;
    }

  }
  Uint8List buildHashPacket(List<int> hash){

    List<int> packet = [0xaa, 0x55];

    for (var v in hash){

      packet.add(v & 0xff);
      packet.add((v & 0xff00) >> 8);
      packet.add((v & 0xff0000) >> 16);
      packet.add((v & 0xff000000) >> 24);

    }
    packet.add(0x0d);
    packet.add(0x0a);

    return Uint8List.fromList(packet);

  }



  String hashPacketToString(List<int> hash){

    return sprintf("%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", hash);

  }

  void procesaRespostaHash(List<int> msg){

    if(msg[0] != 0x55 || msg[1] != 0xaa || msg.length != 4){

      var data = "|";
      for (var x in msg){
        data = data + sprintf("%02x ", x);
      }
      data = data + "|";
      Log.shared.error("GRAMModel.Error en procesaRespostaHash", data);

      return;
    }
    int bits = msg[2] ;  // Com fem un mod 32 el high value byte no serveix de res.
    lastLastRotation[0] = lastRotation[0];
    lastLastRotation[1] = lastRotation[1];


    lastRotation[0] = bits;
    lastRotation[1] = msg[3];


    rotateHash(bits);

    if (connection.currentMessage == null) {
      connection.processNextMessage(); // Send any pending message
    }

  }

  // Saving recorded weights


  //TODO: Add load and save methods for scales, weight records, tares.

  int exportableRecords(){

    return recordedWeights.map((e) {
      var sn = e.serialNumber;
      if (sn != null){
        if (LicenseDatabase.shared.isEnabled(sn, 0)){
          return 1;
        }

      }
      return 0;
    }).reduce((ac, e) => ac+e);
  }
  // Exporting recorded weights

  String recordsAsCSV() {


    var format = NumberFormat.decimalPattern(locale);

    var decimal = format.symbols.DECIMAL_SEP ?? ".";
    var sep = ",";
    if (decimal == ","){
      sep = ";";
    }

    var data = WeightRecord.titlesAsCSV(sep, "\n") + recordedWeights.map((w) => w.recordAsCSV(sep, "\n")).join();
    return data;

  }

  // Clearing records

  void clearRecords(){
    recordedWeights = [];
    doSaveRecords();
    sendUpdateMessage();
  }

// Message analysis


  analitzaMissatge(GRAMMessage message) {

    bool stateUpdated = false;

    switch (message.address) {
      case AddressType.measurementData :
        { // Streaming data answer

          //self.connectionTimer?.invalidate()      // Stop connection timer
          try {
            var decodedMessage = GRAMWeightRecord(message.dataSent);
            if (decodedMessage != null && (lastWeightRecord == null || !lastWeightRecord.iseq(decodedMessage))) {
              connection.connectionState = GRAMConnectionState.streaming;
              updateData(decodedMessage);
              lastWeightRecord = decodedMessage;
              stateUpdated = true;
            }

           }catch(e){
            Log.shared.error("GRAMConnection.processMessage",
                "Error decoding message ${message.address}",
                [message, e]);
          }
        }
        break;

    // restart connection timer for next one
    //self.connectionTimer = Timer(timeInterval: self.connectionTimeout, repeats: false, block: self.processConnectionTimer)
    //RunLoop.main.add(self.connectionTimer!, forMode: .default)


      case AddressType.stopStreaming:
        { // Stop Streaming

          // Disconnect connection timer

          // self.connectionTimer?.invalidate()
          // self.connectionTimer = nil
          Log.shared.info("GRAMConnection.processMessage",
              "StopStreaming accepted ${message.dataSent}");
          //self.state = .connected
          stateUpdated = true;

        }
        break;

      case AddressType.streamData:
        { // Answer to start streaming


          var error = message.executionErrorMessage();
          if (error != null) {
            stateUpdated = true;stateUpdated = true;
            Log.shared.error("GRAMmessage.analyzeMessage",
                "Error while trying to start streaming", error);
          } else {
            //self.state = .streaming
            //self.firstConnect = false
            //self.connectionTimer?.invalidate()
            //self.connectionTimer = Timer(timeInterval: self.connectionTimeout, repeats: false, block: self.processConnectionTimer)
            //RunLoop.main.add(self.connectionTimer!, forMode: .default)
            stateUpdated = true;
            Log.shared.trace("GRAMConnection.processMessage",
                "Starting Streaming ${message.dataSent}");
          }
        }
        break;

      case AddressType.sealing:

        if (message.function == FunctionType.read_response) {
          Log.shared.info("GRAMConnection.processMessage",
              "Sealing  is ${message.stringValue}");
        }

        sealed = message.stringValue == "1";
        break;

      case AddressType.getState:
        if (message.function == FunctionType.read_response) {
          Log.shared.info("GRAMConnection.processMessage",
              "state  is ${message.stringValue}");

          var strHash = message.stringValue;
          if(strHash.length == 32){

            hash[0] = int.parse(strHash.substring(0, 8), radix:16);
            hash[1] = int.parse(strHash.substring(8, 16), radix:16);
            hash[2] = int.parse(strHash.substring(16, 24), radix:16);
            hash[3] = int.parse(strHash.substring(24, 32), radix:16);

            currentHash[0] = hash[0];
            currentHash[1] = hash[1];
            currentHash[2] = hash[2];
            currentHash[3] = hash[3];
           }
        }

        break;



      case AddressType.serialNumber:
        { // serialNumber
          if (message.function ==
              FunctionType.read_response) { // Hem llegit les dades
            Log.shared.info("GRAMConnection.processMessage",
                "SerialNumber is ${message.stringValue}");


            if (serialNumber != message.stringValue || true) {
              //TODO: Send getScaleData message
              serialNumber = message.stringValue;
              connection.getScaleData(); // Update ScaleData
              stateUpdated = true;
            }
            var sn = serialNumber;
            while(sn.length < 10){
              sn = "0" + sn;
            }

            if (LicenseDatabase.shared.isEnabled(sn, 1)){
              scannerEnabled = true;
              print("Scanner Enabled");

            }else {
              scannerEnabled = false;
              print("Scanner Disabled");
            }

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            } else {

            }
          }
        }
        break;


      case AddressType.deviceId:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Device Id ${message.dataSent} : $mv ");
            deviceId = mv;
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getDeviceId());
          }
        }
        break;


      case AddressType.geoCode:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Geo Code ${message.dataSent} : $mv ");
            geoCode = mv;
            sendUpdateMessage(type: AddressType.geoCode, tecnic: true, data: message.intValue.toString());


          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getGeoCode());
          }
        }
        break;

      case AddressType.geoCodeAdjustment:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Geo Code Adjustment${message.dataSent} : $mv ");
            geoCodeAdjustment = mv;
            sendUpdateMessage(type: AddressType.geoCodeAdjustment, tecnic: true, data: message.intValue.toString());

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getGeoCodeAdjustment());
          }
        }
        break;


      case AddressType.moduleBoardCode:
        { // Decimal position
          if (message.function == FunctionType.read_response) {

            Log.shared.info("GRAMConnection.processMessage",
                "Module Board ${message.dataSent} : $message ");
            moduleBoardCode = message.stringValue;

            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getModuleBoardCode());
          }
        }
        break;

      case AddressType.firmwareVersion:
        { // Decimal position
          if (message.function == FunctionType.read_response) {

            Log.shared.info("GRAMConnection.processMessage",
                "Firmware Version ${message.dataSent} : $message ");
            firmwareVersion = message.stringValue;
            if (firmwareVersion.compareTo("3007") >= 0) {
              connection.enqueueMessage(GRAMMessage.getDateLastCalibration());
              connection.enqueueMessage(GRAMMessage.getChangeCalibrationCounter());
            }

            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getFirmwareVersion());
          }
        }
        break;

      case AddressType.optionalBoard:
        { // Decimal position
          if (message.function == FunctionType.read_response) {

            Log.shared.info("GRAMConnection.processMessage",
                "Optional Board ${message.dataSent} : $message ");
            optionalBoard = message.stringValue;
            connection.getNetworkData();
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getOptionalBoard());
          }
        }
        break;

      case AddressType.outputRate:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Output rate ${message.dataSent} : $mv ");
            outputRate = mv;
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getOutputRate());
          }
        }
        break;


      case AddressType.adSpeed:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "AD Speed ${message.dataSent} : $mv ");
            adSpeed = mv;
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getAdSpeed());
          }
        }
        break;



      case AddressType.baudRate:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Baud rate ${message.dataSent} : $mv ");
            baudRate = mv;
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }

            connection.enqueueMessage(GRAMMessage.getBaudRate());
          }
        }
        break;

      case AddressType.allowNegativeWeight: // AllowNegativeWeight
        if (message.function == FunctionType.read_response) {
          allowNegativeWeight = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info(
              "GRAMConnection.processMessage", "Allow Negative Weight $allowNegativeWeight");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getAllowNegativeWeight());
        }
        break;


      case AddressType.scaleUnit:
        { // scale unit

          var index = message.intValue;

          if (index >= 1 && index <= 4) {
            Log.shared.trace("GRAMConnection.processMessage",
                "Scale Unit ${message.dataSent} : $index");
                scaleUnit = unitsCodes[index];
            stateUpdated = true;

          } else {
            Log.shared.warning("GRAMConnection.processMessage",
                "Ignored out of range $index ${message.stringValue }value for scale Units.");
          }
        }
        break;

      case AddressType.rangeMode:
        { // range mode

          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Range Mode ${message.dataSent} : $mv");
            rangeMode = mv;
            stateUpdated = true;
          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.addLog(
                  LogNivell.error, "GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }
            connection.enqueueMessage(GRAMMessage.getRangeMode());
          }
        }
        break;


      case AddressType.maxValue_1:
        { // Max value

          if (message.function == FunctionType.read_response) {
            var mv = message.doubleValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Max Value${message.dataSent} : $mv");

            modes[0].max = scaleValue(mv);
            stateUpdated = true;

            Log.shared.info("GRAMConnection.processMessage",
                "Max Value Stored ${modes[0].max}");
          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.addLog(
                  LogNivell.error, "GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }
            connection.enqueueMessage(GRAMMessage.getMax1());
          }
        }
        break;


      case AddressType.e_1:
        { // e1 value
          if (message.function == FunctionType.read_response) {
            var mv = message.doubleValue;
            Log.shared.info("GRAMConnection.processMessage",
                "e1 Value ${message.dataSent} : $mv");
            modes[0].e = scaleValue(mv);
            stateUpdated = true;

            Log.shared.info(
                "GRAMConnection.processMessage",
                "e1 Value Stored ${modes[0].e}");
          }else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.addLog(
                  LogNivell.error, "GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }
            connection.enqueueMessage(GRAMMessage.gete1());
          }
        }
        break;


      case AddressType.maxValue_2:
        { // Max value
          if (message.function == FunctionType.read_response) {
            var mv = message.doubleValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Max Value 2 ${message.dataSent} : $mv");
            modes[1].max = scaleValue(mv);
            stateUpdated = true;


            Log.shared.info("GRAMConnection.processMessage",
                "Max Value 2 Stored ${modes[1].max}");
          }else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.addLog(
                  LogNivell.error, "GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }
            connection.enqueueMessage(GRAMMessage.getMax2());
          }
        }
        break;


      case AddressType.e_2:
        { // e1 value

          if (message.function == FunctionType.read_response) {
            var mv = message.doubleValue;
            Log.shared.info("GRAMConnection.processMessage",
                "e2 Value ${message.dataSent} : $mv");
            modes[1].e = scaleValue(mv);
            stateUpdated = true;

            Log.shared.info(
                "GRAMConnection.processMessage", "e2 Stored ${modes[1].e}");
          }else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.addLog(
                  LogNivell.error, "GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }
            connection.enqueueMessage(GRAMMessage.gete2());
          }
        }
        break;


      case AddressType.decimalPosition:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Decimal point position${message.dataSent} : $mv ");
            decimalPointPosition = mv;
            stateUpdated = true;

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }else {
              connection.enqueueMessage(GRAMMessage.getDecimalPointPosition());
            }


          }
        }
        break;

      case AddressType.initialZeroCounts:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Initial Zero Counts ${message.dataSent} : $mv ");
            initialZeroCounts = mv;
            sendUpdateMessage(type: AddressType.initialZeroCounts, tecnic: true, data: mv.toString());

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }else {
              connection.enqueueMessage(GRAMMessage.getInitialZeroCounts());
            }


          }
        }
        break;

      case AddressType.slopeDivisor:
        { // Decimal position
          if (message.function == FunctionType.read_response) {
            var mv = message.intValue;
            Log.shared.info("GRAMConnection.processMessage",
                "Slope Divisor * 10000 ${message.dataSent} : $mv ");
            slopeDivisor = mv.toDouble() / 10000.0;
            sendUpdateMessage(type: AddressType.slopeDivisor, tecnic: true, data: slopeDivisor.toString());

          } else if (message.function == FunctionType.write_response) {
            var error = message.writeErrorMessage();
            if (error != null) {
              Log.shared.error("GRAMConnection.processMessage",
                  "Error when writing ${message.address} : $error");
            }else {
              connection.enqueueMessage(GRAMMessage.getSlopeDivisor());
            }


          }
        }
        break;


      case AddressType.resolutionFactor:
        {
          var mv = message.intValue;
          Log.shared.info("GRAMConnection.processMessage",
              "Resolution factor ${message.dataSent}  : $mv");
          resolutionFactor = mv.toDouble();
          highResolution = mv == 10 ? true : false;
          stateUpdated = true;

        }
        break;


      case AddressType.autoTare: // Autotare
        if (message.function == FunctionType.read_response) {
          autoTare = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info(
              "GRAMConnection.processMessage", "Auto tare $autoTare");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
         connection.enqueueMessage(GRAMMessage.getAutoTare());
        }
        break;

      case AddressType.tareOnStability: // Tare On Stability
        if (message.function == FunctionType.read_response) {
          tareOnStability = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Tare On Stability $tareOnStability");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getTareOnStability());

        }
        break;

      case AddressType.zeroTrackingDevice: // Zero Tracking Device
        if (message.function == FunctionType.read_response) {
          zeroTrackingDevice = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Zero tracking device $zeroTrackingDevice");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getZeroTracking());

        }
        break;

      case AddressType.zeroTrackingRange: // Zero Tracking Range
        if (message.function == FunctionType.read_response) {
          zeroTrackingRange = message.intValue;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Zero tracking Range $zeroTrackingRange");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getZeroTrackingRange());

        }
        break;

      case AddressType.filterLevel:
        if (message.function == FunctionType.read_response) {
          filterLevel = message.intValue;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Filter level $filterLevel");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getFilterLevel());

        }
        break;

      case AddressType.stabilityRange:
        if (message.function == FunctionType.read_response) {
          stabilityRange = message.intValue;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Stability Rangel $stabilityRange");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getStabilityRange());

        }
        break;



      case AddressType.motionFilter: // Motion Filter
        if (message.function == FunctionType.read_response) {
          motionFilter = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Motion Filter $motionFilter");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getMotionFilter());

        }
        break;

      case AddressType.livestockFilter: // LivestockFilter
        if (message.function == FunctionType.read_response) {
          livestockFilter = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "Livestock Filter $livestockFilter");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getLivestockFilter());


        }
        break;

      case AddressType.highResolutionMode: // High Resolution Mode
        if (message.function == FunctionType.execution_response) {
          Log.shared.info("GRAMConnection.processMessage",
              "HighResolution toggle ${message.dataSent}");
        }
        break;

      case AddressType.deviceStateInformation: // Devide state information


        if (message.function == FunctionType.read_response) {
          var error = message.deviceError();
          deviceState = error;
          stateUpdated = true;
          //connection. insertMessage(GRAMMessage.getHashMessage());
        }
        break;

      case AddressType
          .tareValue: // Tare Value  Don't do anything as it is received in every weight message
        if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          //self.messageQueue.enqueue(self.getOneMeasure())
        }
        break;

      case AddressType
          .clearTare: // Clear Tare Don't do anything as it is received in every weight message
        if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          //self.messageQueue.enqueue(self.getOneMeasure())
        }
        break;

      case AddressType
          .switchTareOn: // Switch tare mode No need to treat it here
        if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          //self.messageQueue.enqueue(self.getOneMeasure())

        }
        break;

      case AddressType.presetManualTare: // Preset or manuial tare value
        if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          //self.messageQueue.enqueue(self.getOneMeasure())

        }
        break;



      case AddressType.adcCountsFiltered: //  Comptes desl AD converter
        if (message.function == FunctionType.read_response) {
          adcCountsFiltered = message.intValue;
          sendUpdateMessage(type: AddressType.adcCountsFiltered, tecnic: true, data: message.intValue.toString());

          Log.shared.info("GRAMConnection.processMessage",
              "ADC counts filtered $adcCountsFiltered");
        }
        break;

      case AddressType.changeCalibrationCounter:
        if (message.function == FunctionType.read_response) {
          counterChange = message.intValue;
          sendUpdateMessage(type: AddressType.changeCalibrationCounter, tecnic: true, data: message.intValue.toString());

          Log.shared.info("GRAMConnection.processMessage",
              "changeCalibrationCounter $counterChange");
        }
        break;


      case AddressType.dateLastCalibration: // LivestockFilter
        if (message.function == FunctionType.read_response) {
          lastChange = message.stringValue;
          sendUpdateMessage(type: AddressType.dateLastCalibration, tecnic: true, data: message.stringValue);

          Log.shared.info("GRAMConnection.processMessage",
              "Date Last Calibration $lastChange");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getDateLastCalibration());
          connection.enqueueMessage(GRAMMessage.getChangeCalibrationCounter());


        }
        break;



      case AddressType
          .zeroIndicator: // Zero Indicator no need to treat comes in weight register
        if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          //self.messageQueue.enqueue(self.getOneMeasure())

        }
        break;

      case AddressType.ssidName: // ssid Name
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "SSID is '${message.stringValue}'");
          stateUpdated = true;
          if(connection.mode == GRAMConnectionMode.normal) {
            this.scaleName = message.stringValue;
            print("Scale name ${this.scaleName}" );
          }else {

            print("Trobada bàscula " + message.stringValue + " at " + message.ipOrigin);
              // Construim una nova scale

              var foundScale = Scale();
            foundScale.name = message.stringValue;
            foundScale.ssid = message.stringValue;
            foundScale.ipAddress = message.ipOrigin;
            foundScale.port = 4445;

            scalesDatabase.add(foundScale);

            // TODO: Build a new scale. Check if it is in the database and if not add it.
          }

          stateUpdated = true;

        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getSSIDName());
          }
        }
        break;

      case AddressType.ssidPassword: // password
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "Scale password is '${message.stringValue}'");
          this.apPassword = message.stringValue;
          stateUpdated = true;

        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getSSIDPassword());
          }
        }
        break;


      case AddressType.ipAddress: // password
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "Base IP Address '${message.stringValue}'");
          this.ipBaseAddress = message.stringValue;
          stateUpdated = true;

        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getIPAddress());
          }
        }
        break;


      case AddressType.accessPoint:
        if (message.function == FunctionType.read_response) {
          this.isAccessPoint = message.dataSent[0] == 0x31;
          sendUpdateMessage(type: AddressType.accessPoint, tecnic: true, data: message.stringValue);

          Log.shared.info("GRAMConnection.processMessage",
              "Access Point? $isAccessPoint");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getAccessPoint());


        }
        break;





      case AddressType.networkName: // ssid Name
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "Network name is '${message.stringValue}'");
          stateUpdated = true;
          this.netName = message.stringValue;
          this.scalesDatabase.add(this.scale);


        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getNetworkName());
          }
        }
        break;

      case AddressType.networkPassword: // password
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "Network password is '${message.stringValue}'");
          this.netPassword = message.stringValue;
          this.scalesDatabase.add(this.scale);
          stateUpdated = true;

        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getNetworkPassword());
          }
        }
        break;

        // Network

      case AddressType.netDhcp: // LivestockFilter
        if (message.function == FunctionType.read_response) {
          this.netDhcp = message.dataSent[0] == 0x31;
          sendUpdateMessage(type: AddressType.netDhcp, tecnic: true, data: message.stringValue);


          Log.shared.info("GRAMConnection.processMessage",
              "Network DHCP $netDhcp");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getNetDhcp());


        }
        break;


      case AddressType.netIp: // password
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          Log.shared.info("GRAMConnection.processMessage",
              "Network IP is '${message.stringValue}'");
          this.netIp = message.stringValue;
          stateUpdated = true;

        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getNetIp());
          }
        }
        break;



      case AddressType.tcpServerPort:
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          int v = message.intValue;

          Log.shared.info("GRAMConnection.processMessage",
              "TCP Server Port is '${v}'");
          this.tcpServerPort = v;
          sendUpdateMessage(type: AddressType.tcpServerPort, tecnic: true, data: message.stringValue);


        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getTCPServerPort());
          }
        }
        break;


      case AddressType.udpLocalPort:
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          int v = message.intValue;

          Log.shared.info("GRAMConnection.processMessage",
              "UDP Local Port is '${v}'");
          this.udpLocalPort = v;
          sendUpdateMessage(type: AddressType.udpLocalPort, tecnic: true, data: message.stringValue);


        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getUDPLocalPort());
          }
        }
        break;


      case AddressType.udpRemotePort:
        if (message.function ==
            FunctionType.read_response) { // Hem llegit les dades
          int v = message.intValue;

          Log.shared.info("GRAMConnection.processMessage",
              "UDP Remote Port is '${v}'");
          this.udpRemotePort = v;
          sendUpdateMessage(type: AddressType.udpRemotePort, tecnic: true, data: message.stringValue);


        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          } else {
            connection.enqueueMessage(GRAMMessage.getUDPRemotePort());
          }
        }
        break;



      case AddressType.initialZero: // Tare On Stability
        if (message.function == FunctionType.read_response) {
          initialZero = message.dataSent[0] == 0x31;
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "InitialZero $initialZero");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getInitialZero());

        }
        break;

      case AddressType.initialZeroRange: //Initial Zero Range
        if (message.function == FunctionType.read_response) {
          initialZeroRange = message.intValue;
          print("Initial Zero Range $initialZeroRange");
          stateUpdated = true;

          Log.shared.info("GRAMConnection.processMessage",
              "initial Zero Range $initialZeroRange");
        } else if (message.function == FunctionType.write_response) {
          var error = message.writeErrorMessage();
          if (error != null) {
            Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
                "Error when writing ${message.address} : $error");
          }
          connection.enqueueMessage(GRAMMessage.getInitialZeroRange());

        }
        break;



      default:
        {
          Log.shared.addLog(LogNivell.error, "GRAMConnection.processMessage",
              "Comanda desconeguda 0x${message.address}");
        }
        break;
    }
    if(stateUpdated){
      sendUpdateMessage();
    }
  }


// End analitzaMissatge

// Subscriptions and notifications

void addSubscriptor(object, {bool tecnic = false}){
    if (tecnic){
      if (!subscriptorsTecnic.contains(object)) {
        subscriptorsTecnic.add(object);
      }
    }else {
      if (!subscriptors.contains(object)) {
        subscriptors.add(object);
      }
    }
}

void removeSubscriptors(object,){


    if (subscriptors.contains(object)) {
      subscriptors.remove(object);
    }
    if (subscriptorsTecnic.contains(object)) {
      subscriptorsTecnic.remove(object);
    }

}

void sendUpdateMessage({AddressType type = AddressType.measurementData, bool tecnic = false, String data = null}){
    
    if(tecnic){
      for (var object in subscriptorsTecnic){
        object.tecnicUpdated(type, data);
      }

    }else {
      for (var object in subscriptors){
        object.modelUpdated();
      }
      
    }


}

}
