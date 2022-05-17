import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'License.dart';
import 'LocalFileSystemUtilities.dart';
import 'RoundButton.dart';
import 'ScaleDatabase.dart';
import 'IndicatorButton.dart';
import 'screensize_reducers.dart';
import 'GRAMConnection.dart';
import 'GRAMMessage.dart';
import 'GRAMModel.dart';
import 'Visor.dart';
import 'ColorCompatibility.dart';
import 'MainHeader.dart';
import 'WeightRecordsList.dart';
import 'IconAndFilesUtilities.dart';
import 'ActiveText.dart';
import "Setup.dart";
import "SlideRoutes.dart";
import 'WeightRecordsScreen.dart';
import 'AskTara.dart';
import 'package:flutter/services.dart';
import 'LimitsScreen.dart';
import 'AskLimits.dart';
import 'Scanner.dart';
import 'Dialogs.dart';
import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'Translation.dart';
import 'LicenseView.dart';
import 'LogViewer.dart';
import 'Log.dart';
import 'ScannerView.dart';
import 'CSVDatabase.dart';
import 'CSVDatabaseView.dart';
import 'BlueConnection.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ESCPrinter.dart';

import 'ToggleQrProtocol.dart';
import 'PrinterConnectionProtocol.dart';
import 'SerialprinterConnection.dart';

//void main() => runApp(MyApp());


void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'GRAM Xtrem',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'GRAM Xtrem'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, ToggleQrProtocol  {


  String host = "192.168.4.1";
  int port = 6666;

  FlutterBlue flutterBlue;

  PrinterConnectionProtocol printerConnection;

  GRAMModel model = GRAMModel.shared;
  LicenseDatabase licenses = LicenseDatabase.shared;

  //GRAMConnection connection;
  StreamSubscription subscription;

  GRAMMessage dataReceived;

  String errorReceived = "No Error";

  final buttonTitles = ["+", "HR", "Limits", "Hold", "^tare", "^zero"];
  TextEditingController _textFieldController = TextEditingController();

  bool selector = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("State $state");
    setState(() {
      GRAMModel.shared.appState = state;
      Log.shared.info(
          "main.didChangeAppLifecycleState", "App changed state to $state");

      if (state == AppLifecycleState.resumed) {
        if (!model.isStreaming()) {
          connect();
        }
      } else if (state == AppLifecycleState.paused) {
        disconnect();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();

  }

  Future<void>initAsync() async{
    deviceType = await GRAMModel.getDeviceType();


    //Model.getAndShowDeviceData(model);// Configure DeviceType and record some data !!!

    // Configurem una impresora per si no hi ha res definit

    this.flutterBlue = FlutterBlue.instance;

    this.printerConnection = deviceType == DeviceType.terminal ? SerialPrinterConnection() :  BlueConnection(this.flutterBlue);
    model.printerConnection = this.printerConnection;
    model.aprinter = ESCPrinter(this.printerConnection);

    model.addSubscriptor(this);
    model.tr = Translation();
    checkAndInstallManual();
    await loadInititalData();



    print(model.urlProducts);
    model.connection = GRAMConnection(context);
    subscription = model.connection.streamController.stream.listen(
          (message) {
        //print("New Message");
        dataReceived = message;
        model.analitzaMissatge(message);
        // Check if there are messages to send and send them
        if (model.connection.currentMessage == null) {
          model.connection.processNextMessage(); // Send any pending message
        }
      },
      onError: (err) =>
          Log.shared.error("main.initState.stream.listen.onError", err),
      onDone: () =>
          Log.shared.warning("main.initState.stream.listen.onDone", ""),
    );

    WidgetsBinding.instance.addObserver(this);

    // model.printer.scanPrinter("ME31");
    model.databases.add(CSVDatabase(model.urlProducts));
    model.databases.add(CSVDatabase(model.urlCustomers));
    model.databases.add(CSVDatabase(model.urlUsers));


    if (model.scale != null) {
      if(model.scale.networkName == "tty") {
        model.tester.device = model.scale.ssid;
        model.scale.port =
            model.tester.testConfigurations(
                [9600, 19200, 38400, 57600, 115200]);
      }
      if (model.scale.port != 0) {
        connect();
      }
    }

  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    subscription.cancel();
    model.connection.destroy();
    super.dispose();
  }


  void dummy(String s) {}


  Future<void> loadInititalData() async {
    var v = await model.loadRecords();
    await model.loadDefaults();
    if (v != null) {
      model.recordedWeights = v;
    }

    try {
      await model.aprinter.connect(model.printerName, dummy);
    } catch (e) {
      Log.shared.error("Model._constructor", "Starting Scan", [e]);
    }


    setState(() {});
  }

  void checkAndInstallManual() async {
    var dir = await localPath();
    var path = dir + "/Manual";

    var file = File(path);

    if (file.existsSync()) {
      // Directory exists, just skip install
      return;
    }
    var data = await rootBundle.load('assets/Manual.zip');
    var buffer = data.buffer;
    var bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Archive archive = new ZipDecoder().decodeBytes(bytes);

    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        var name = dir + "/" + filename;
        new File(name)
          ..createSync(recursive: true)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        var name = dir + "/" + filename;
        new Directory(name)..create(recursive: true);
      }
    }
  }

  void modelUpdated() {
    setState(() {});
  }

  void connect() {
    model.connection.connectionRetries = 0;
    model.connection.connect();
  }

  void disconnect() {
    model.connection.disconnect();
  }

  void reconnect() async {
    connect();

    setState(() {
      errorReceived = "Connection done";
    });
  }

  void toggleQr(){
    setState(() {
      model.showQr = !model.showQr;
    });
  }


  void empty() {
    Log.shared.error("main.empty", "Empty Called from button");
  }

  void tare() {
    model.connection.enqueueMessage(GRAMMessage.setTare());
  }

  void hr() {
    model.connection.enqueueMessage(GRAMMessage.highResolutionMode());
  }

  void zero() {
    model.connection.enqueueMessage(GRAMMessage.setZero());
  }

  void hold() {
    if (model.holdEnabled) {
      model.disableHolding();
      model.didReceiveData();
    } else {
      model.enableHolding();
      model.didReceiveData();
    }
  }

  void doScanx() async {
    if (model.scannerEnabled) {
      Log.shared.info("main.doScan", "Starting Scanner");

      await scanBarcodeNormal((s) {
        if (s != "-1") {
          model.setItem(s);
          model.didReceiveData();
        }
      });
    } else {
      displayOptionsAlert(
          context,
          "Scanner not implemented",
          "Please, contact your dealer.",
          "Enter License",
              () => Navigator.push(context, SlideLeftRoute(widget: LicenseView())));

      //displayAlert(context, , "Please, contact your dealer." );
    }
  }

  void askResetCounter(){
    displayOptionsAlert(
        context,
        "Reset Counter",
        "Do you really want to reset the counter?",
        "Reset Counter",
            () => model.resetCounter());
  }

  void doScan() {

    if(deviceType == DeviceType.terminal){
      askResetCounter();
    }else {
      if (model.scannerEnabled) {
        Log.shared.info("main.doScan", "Starting Scanner");
        Navigator.push(context, SlideLeftRoute(widget: ScannerView()));
      } else {
        displayOptionsAlert(
            context,
            "Scanner not implemented",
            "Please, contact your dealer.",
            "Enter License",
                () =>
                Navigator.push(context, SlideLeftRoute(widget: LicenseView())));

        //displayAlert(context, , "Please, contact your dealer." );
      }
    }
  }

  void addLicense() async {}

  void addRecord() {
    model.recordWeight();
  }

  Function doit(title) {
    switch (title) {
      case "Tare":
        {
          return this.tare;
        }
        break;

      case "HR":
        {
          return this.hr;
        }
        break;

      case "→0←":
        {
          return this.zero;
        }
        break;

      case "Hold":
        {
          return this.hold;
        }
        break;

      case "+":
        {
          this.addRecord;
        }
        break;

      default:
        {
          return this.empty;
        }
        break;
    }
    return this.empty;
  }

  /* void userDialog() {
    _textFieldController.text = ""; //model.getUser();
    displayDialog(context, "Enter User", "User", _textFieldController, (v) {
      setState(() {
        model.setUser(v);
      });
    });
  }

  void customerDialog() {
    _textFieldController.text = ""; //model.getCustomer();
    displayDialog(context, "Enter Customer", "Customer", _textFieldController, (v) {
      setState(() {
        model.setCustomer(v);
      });
    });
  }

  void itemDialog() {
    print('Item Dialog');
    openSelector();
  }

  void itemDialogx() {
    _textFieldController.text = ""; //model.getItem();
    displayDialog(context, "Enter Code", "Code",_textFieldController,  (v) {
      setState(() {
        model.setItem(v);
      });
    });
  }
*/

  void ssidDialog() {
    _textFieldController.text = model.scale.ssid;
    displayYesNoDialog(context, "Enter SSID", "SSID", _textFieldController,
            (v) {
          model.connection.enqueueMessage(GRAMMessage.ssidName(v));

          var sc = model.scale.duplicateWithSsid(
              v); // Create a new scale with the new ssid and name
          ScaleDatabase.shared.add(sc);

          // Disconnect

          if (model.isConnected()) {
            disconnect();
            model.scale = sc;
            connect();
          } else {
            model.scale = sc;
          }

          model.didReceiveData();
        });
  }

  void openSetup() {

    /* model.connection.getSetupData(); Ara no es necessari doncs ja es carrega al ciomençament.També permet treballar sense conexió*/
    Navigator.push(context, SlideLeftRoute(widget: Setup(ssidDialog)));
  }

  // Selectors for Database Fields

  void openSelector() async {
    setState(() {
      selector = true;
    });
  }

  void closeSelector() async {
    setState(() {
      selector = false;
    });
  }

  void selectItem(e) async {
    setState(() {
      if (e[0] == 2) {
        model.setUser(e[1]);
      } else if (e[0] == 1) {
        model.setCustomer(e[1]);
      } else {
        model.setItem(e[1]);
      }
      //print(e);
      selector = false;
    });
  }

  Widget buildSelector() {
    print(this.selector);

    if (!selector) {
      return SizedBox.shrink();
    }

    return Center(
        child: CSVDatabaseView(model.databases, selectItem, closeSelector));
  }

  buildWidget() {
    if (model.tr != null && model.tr.loaded) {
      if (screenHeight(context) > 500) {
        return buildLongWidget();
      } else {
        return buildShortWidget();
      }
    } else {
      return Center(child: Text("Loading language"));
    }
  }

  void openLog() {
    if (LicenseDatabase.shared.isEnabled("0009999999", 0) ||
        model.disableRestrictions) {
      Navigator.push(context, SlideLeftRoute(widget: LogViewer()));
    }
  }

  buildShortWidget() {
    if (model != null) {
      return SafeArea(
        child: Stack(children: [
          Container(
            decoration:
            BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 30.0, right: 0.0, bottom: 0.0)),
                  buildMainHeader(model, reconnect, disconnect, null, null,
                      openSelector, context),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Container(
                        height: 40,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 5.0, right: 0.0, bottom: 0.0),
                        child: FlatButton(
                          onPressed: openLog,
                          child: getImage("logo", 0),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 40,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 5.0, right: 0.0, bottom: 0.0),
                        child: roundButton(
                          "⚙",
                          30,
                          CC.widgetColor(WN.buttonColor, 0),
                          CC.widgetColor(WN.inactiveButtonColor, 0),
                          CC.widgetColor(WN.buttonTextColor, 0),
                          openSetup,
                          context,
                          textSize: 30,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        left: 50.0, top: 0.0, right: 50.0, bottom: 0.0),
                    child: buildVisor(model, context, this),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 85,
                        /*
                        child: activeImage(
                          "setup",
                          openSetup,
                          //() => Navigator.push(
                          //context, SlideLeftRoute(widget: Setup(ssidDialog)))
                          //: null,

                          context,
                        ),
                        */

                      ),
                      Spacer(),
                      buildButtons(),
                      Spacer(),
                      Container(
                        width: 40,
                        height: 85,
                        child: activeImage(
                          "limits",
                              () => Navigator.push(
                              context, SlideRightRoute(widget: LimitsScreen())),
                          context,
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 34,
                    child: activeImage(
                      "records",
                          () => Navigator.push(
                          context, SlideUpRoute(widget: WeightRecordsScreen())),
                      context,
                    ),
                  )
                ]),
          ),
          buildSelector(),
        ]),
      );
    }
    return [Text("No data")];
  }

  buildLongWidget() {
    if (model != null) {
      return SafeArea(
        //height: screenHeight(context),
        child: Stack(children: [
          Container(
            decoration:
            BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),

            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 30.0, right: 0.0, bottom: 0.0)),
                  buildMainHeader(model, reconnect, disconnect, null, null,
                      openSelector, context),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Container(
                        height: 40,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
                        child: FlatButton(
                          onPressed: openLog,
                          child: getImage("logo", 0),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 40,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 10.0, right: 5.0, bottom: 0.0),
                        child: roundButton(
                          "⚙",
                          32,
                          CC.widgetColor(WN.buttonColor, 0),
                          CC.widgetColor(WN.inactiveButtonColor, 0),
                          CC.widgetColor(WN.buttonTextColor, 0),
                          openSetup,
                          context,
                          textSize: 18,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        left: 10.0, top: 0.0, right: 10.0, bottom: 0.0),
                    child: buildVisor(model, context, this),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        /*child: activeImage(
                          "setup",
                          model.isConnected() ? openSetup : null,
                          //model.isConnected() ?
                          //() => Navigator.push(
                          //       context, SlideLeftRoute(widget: Setup(ssidDialog))) : null,
                          context,
                        ),*/
                      ),
                      buildButtons(),
                      Container(
                        width: 40,
                        child: activeImage(
                          "limits",
                          model.isConnected()
                              ? () => Navigator.push(context,
                              SlideRightRoute(widget: LimitsScreen()))
                              : null,
                          context,
                        ),
                      )
                    ],
                  ),

                  GestureDetector(
                    onTap: toggleQr,
                    child: model.showQr  && (model.stable ) ?
                    Padding(
                        padding: EdgeInsets.only(
                            left: 0.0, top: (screenHeight(context) - 525-200)/2.0, right: 0.0, bottom: 10.0),
                        child: model.presentedWeight.qrcode(model.decimalPointPosition, withUnits: model.sealed)) :
                    buildWeighRecordsList( model, screenHeight(context) - 560, context),
                  ),


                  //
                  Spacer(),
                  Container(
                    height: 40,
                    child: activeImage(
                      "records",
                          () => Navigator.push(
                          context, SlideUpRoute(widget: WeightRecordsScreen())),
                      context,
                    ),
                  )
                ]), // End of Columns
          ),
          buildSelector(),
        ]),
      );
    }

    return [Text("No data")];
  }

  Color indicatorColorForButton(int but) {
    switch (but) {
      case 1:
        {
          // HR
          return this.model.highResolution && model.isConnected()
              ? CC.widgetColor(WN.indicatorLevel_1, 0)
              : CC.widgetColor(WN.inactiveButtonColor, 0);
        }
        break;

      case 2:
        {
          // Limits
          return this.model.limitsEnabled && model.isConnected()
              ? CC.widgetColor(WN.indicatorLevel_1, 0)
              : CC.widgetColor(WN.inactiveButtonColor, 0);
        }
        break;

      case 3:
        {
          // Hold
          return this.model.holdEnabled && model.isConnected()
              ? CC.widgetColor(WN.indicatorLevel_1, 0)
              : CC.widgetColor(WN.inactiveButtonColor, 0);
        }
        break;

      case 4:
        {
          // Tare
          return this.model.tareOn && model.isConnected()
              ? CC.widgetColor(WN.indicatorLevel_1, 0)
              : CC.widgetColor(WN.inactiveButtonColor, 0);
        }
        break;

      default:
        {
          return CC.labelColor(CL.clear, 0);
        }
        break;
    }
  }

  // Returns true if the ith button should be active, false otherwise
  bool isActiveButton(int i) {
    if (!model.isStreaming()) {
      return false; // Change for enabling for test
    }

    switch (i) {
      case 0: // +

        return (model.isStreaming() &&
            (model.zeroSinceLastRecord || !model.recordsToZero) &&
            model.stable &&
            !model.zero);
        break;

      case 3: // Hold
        return !model.sealed;
        break;

      default:
        return true;
        break;
    }
  }

  buildButtonsRow(row, buttonsPerRow) {
    var buttonFunctions = [
      this.addRecord,
      this.hr,
          () {
        if (model.limitsEnabled) {
          model.cancelLimits();
        } else {
          Navigator.push(context, SlideUpRoute(widget: AskLimits()));
        }
      },
      this.hold,
      this.tare,
      this.zero
    ];

    var padding = MediaQuery.of(context).padding;

    double buttonSize =  85.0;

    List<Widget> childs = [];
    for (int j = 0; j < buttonsPerRow; j++) {
      if (row * buttonsPerRow + j < buttonTitles.length) {
        var sw = ((screenWidth(context) - (padding.right + padding.left  + 100.0 + (buttonsPerRow * buttonSize))) /
            (buttonsPerRow - 1));   // En comptes de pàdding eren 100
        sw = sw >= 0.0 ? sw : 0.0;
        if (j != 0) {
          childs.add(SizedBox(width: sw));

          //childs.add(Spacer());
        }
        int index = (row * buttonsPerRow) + j;
        var indicatorColor = this.indicatorColorForButton(index);

        var title = buttonTitles[index];

        if (index == 4) {
          // Tare
          childs.add(
            GestureDetector(
              child: indicatorButton(
                title,
                buttonSize,
                CC.widgetColor(WN.tareButtonColor, 0),
                CC.widgetColor(WN.inactiveButtonColor, 0),
                CC.widgetColor(WN.tareButtonText, 0),
                indicatorColor,
                isActiveButton(index) ? buttonFunctions[index] : null,
                context,
                invertColor: isActiveButton(index) ? false : true,
              ),
              onLongPress: Feedback.wrapForLongPress(
                      () =>
                      Navigator.push(context, SlideUpRoute(widget: AskTara())),
                  context),
            ),
          );
        } else if (index == 0) {
          // +
          childs.add(
            GestureDetector(
                child: indicatorButton(
                  model.tr.localize(title),
                  buttonSize,
                  CC.widgetColor(WN.buttonColor, 0),
                  CC.widgetColor(WN.inactiveButtonColor, 0),
                  CC.widgetColor(WN.buttonTextColor, 0),
                  indicatorColor,
                  isActiveButton(index) ? buttonFunctions[index] : null,
                  context,
                ),
                onLongPress:
                Feedback.wrapForLongPress(() => doScan(), context)),
          );
        } else if (index == 5) {
          // 0
          childs.add(indicatorButton(
              title,
              buttonSize,
              CC.widgetColor(WN.buttonColor, 0),
              CC.widgetColor(WN.inactiveButtonColor, 0),
              CC.widgetColor(WN.buttonTextColor, 0),
              indicatorColor,
              isActiveButton(index) ? buttonFunctions[index] : null,
              context,
              invertColor: true));
        } else {
          childs.add(
            indicatorButton(
              model.tr.localize(title),
              buttonSize,
              CC.widgetColor(WN.buttonColor, 0),
              CC.widgetColor(WN.inactiveButtonColor, 0),
              CC.widgetColor(WN.buttonTextColor, 0),
              indicatorColor,
              isActiveButton(index) ? buttonFunctions[index] : null,
              context,
            ),
          );
        }
      }
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: childs);
  }

  buildButtons() {
    int rows = (screenWidth(context) > 600 ? 1 : 2);
    int buttonsPerRow = (buttonTitles.length / rows).floor();

    List<Widget> childs = [];

    for (int i = 0; i < rows; i++) {
      if (rows == 2) childs.add(SizedBox(height: 10));
      childs.add(buildButtonsRow(i, buttonsPerRow));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, children: childs);
  }

  // OK we want 110 pixels for each button

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    SystemChrome.setEnabledSystemUIOverlays([]);
    model.darkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      appBar: null,
      body: buildWidget(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
