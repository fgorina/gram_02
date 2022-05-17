import 'package:flutter/material.dart';
import 'SettingsItem.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screensize_reducers.dart';
import 'GRAMModel.dart';
import 'LabeledSwitch.dart';
import 'LabeledSegments.dart';
import 'LabeledTextField.dart';
import 'LicenseSettings.dart';
import 'PrinterSettings.dart';
import 'DatabaseSettings.dart';
import 'GRAMMessage.dart';
import 'IconAndFilesUtilities.dart';
import "ColorCompatibility.dart";
import 'DocumentViewer.dart';
import 'SlideRoutes.dart';
import 'ScaleDefinition.dart';
import 'LabeledDropDown.dart';
import 'LabeledSwitch.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'LabeledSlider.dart';
import 'Dialogs.dart';
import 'NetworkOptions.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<SettingsItem> items = [];
  SettingsItem rightItem;
  GRAMModel model = GRAMModel.shared;

  String signature = "";
  String versionString = "xxx";

  double _initialZeroRange = 0.0;

  @override
  void initState() {
    super.initState();

    items.add(new SettingsItem(model.tr.localize("General"), general, false));
    items.add(new SettingsItem(model.tr.localize("Zero Options"), zeroOptions, false));
    items.add(new SettingsItem(model.tr.localize("Tare Options"), tareOptions, false));
    items.add(new SettingsItem(model.tr.localize("Filter Options"), filterOptions, false));
    items.add(new SettingsItem(model.tr.localize("COM port"), comPortOptions, false));
    items.add(new SettingsItem(model.tr.localize("Scale Definition"), scaleDefinition, false));
    if(deviceType != DeviceType.terminal) {
      items.add(new SettingsItem(model.tr.localize("Licenses"), licenses, true));
    }
    items.add(new SettingsItem(model.tr.localize("Printer"), printerSettings, true));
    items.add(new SettingsItem(model.tr.localize("Databases"), databaseSettings, true));

    if (model.optionalBoard == "01" || model.optionalBoard == "02" || true ) {
      items.add(new SettingsItem(model.tr.localize("Advanced"), networkOptions, false));
    }
    items.add(new SettingsItem(model.tr.localize("About App"), about, true));

    rightItem = items.last;
  }

  void close() {
    GRAMModel model = GRAMModel.shared;
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }

  Widget menuTextFromItem(SettingsItem item, Function f, context) {
    return GestureDetector(
        child: Padding(
            padding:
                EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 5.0),
            child: Text(item.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:model.isConnected() || item.alwaysActive ? Colors.black : Colors.grey))),
        onTap: () {
         if ( model.isConnected() || item.alwaysActive) {
            selectItem(item);
         }
        });
  }

  void selectItem(SettingsItem e) {
    setState(() {
      rightItem = e;
    });
  }

  Widget leftWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => menuTextFromItem(e, selectItem, context),
          )
          .toList(),
    );
  }

  Widget buildH(BuildContext context) {
    return Consumer<ScreenHeight>(builder: (context, _res, child) {
      return Column(children: [
        Container(
          color: Color.fromRGBO(230, 230, 230, 1),
          child: Row(children: [
            Spacer(),
            Text(rightItem.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            Spacer(),
            IconButton(onPressed: close, icon: Icon(Icons.close)),
          ]),
        ),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Color.fromRGBO(230, 230, 230, 1),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, top: 0.0, right: 0.0, bottom: 10.0),
                  child: Container(
                    width: 180,
                    height: screenHeight(context) - 80.0 - _res.keyboardHeight,
                    child: SingleChildScrollView(child: leftWidget(), controller: ScrollController()),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 10.0, right: 08.0, bottom: 10.0),
                child: Scrollbar(
                  isAlwaysShown: true,
                    child: Container(
                  width: screenWidth(context) - 220,
                  height: screenHeight(context) - 80.0 - _res.keyboardHeight,
                  child:
                      SingleChildScrollView(child: rightItem.detail(context), controller: ScrollController()),
                ),
                ),
              ),
            ]),
      ]);
    });
  }

  Widget buildV(BuildContext context) {
    return Consumer<ScreenHeight>(builder: (context, _res, child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PopupMenuButton(
              onSelected: selectItem,
              itemBuilder: (BuildContext context) => items
                  .map((e) => PopupMenuItem(value: e, child: Text(e.title), enabled: model.isConnected() || e.alwaysActive))
                  .toList()),
          Spacer(),
          Text(rightItem.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(onPressed: close, icon: Icon(Icons.close)),
        ]),
        Padding(
          padding:
              EdgeInsets.only(left: 20.0, top: 10.0, right: 2.0, bottom: 10.0),
          child: Container(
            height: screenHeight(context) - 80 - _res.keyboardHeight,
            width: screenWidth(context) - 40,
            child: SingleChildScrollView(child: rightItem.detail(context), controller: ScrollController(),),
          ),
        ),
        Spacer(),
      ]);
    });
  }

  Widget build(BuildContext context) {
    if (screenWidth(context) > screenHeight(context)) {
      return buildH(context);
    } else {
      return buildV(context);
    }
  }

  // Aqui generem els diversos widgets epr diverses opcions

  void setScaleName(String newValue) {
    GRAMModel model = GRAMModel.shared;

    if (model.scaleName != newValue) {
      displayOptionsAlert(
          context,
          model.tr.localize("Conformation"),
          model.tr.localize(
              "Do you really want to change the name of the scale from ${model.scaleName} to ${newValue}"),
          model.tr.localize("Change the name"), () {
        print("Canviant el nom de ${model.scaleName} to ${newValue}");

        model.connection.enqueueMessage(GRAMMessage.ssidName(newValue));
        setState(() {
          model.scaleName = newValue;
        });
      });
    }
  }

  void setDeviceId(String newValue) {
    GRAMModel model = GRAMModel.shared;
    int id = int.parse(newValue);
    print("Set device id de ${model.deviceId} to ${newValue}");

    model.connection.enqueueMessage(GRAMMessage.deviceId(id));

    setState(() {
      model.deviceId = id;
    });
  }

  Widget general(BuildContext context) {
    GRAMModel model = GRAMModel.shared;

    var optional = "Not Present";

    switch (model.optionalBoard) {
      case "00":
        optional = "Not Present";
        break;

      case "01":
        optional = "Ethernet";
        break;

      case "02":
        optional = "WiFi";
        break;

      default:
        optional = model.optionalBoard;
    }

    return Wrap(runSpacing: 20.0, children: [
      labeledTextField(model.tr.localize("Name"),
          model.scaleName.isEmpty ? "***" : model.scaleName, setScaleName),
      labeledLink(
          model.tr.localize("Serial Number"),
          model.serialNumber.isEmpty ? "***" : model.serialNumber,
          null,
          context,
          textAlign: TextAlign.right),
      labeledNumericField(model.tr.localize("Device Id"),
          model.deviceId.toString(), setDeviceId),
      labeledText(
        model.tr.localize("Type"),
        model.moduleBoardCode,
      ),
      labeledText(model.tr.localize("Software Version"), model.firmwareVersion),
      labeledText(
        model.tr.localize("Optional Board"),
        model.tr.localize(optional),
      ),
      labeledText(model.tr.localize("Sealing Switch"),
          model.sealed ? "Sealed" : "Not Sealed"),
    ]);
  }

  /*** Zero Options
   *
   *
   */

  void setInitialZero(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.initialZero(newValue));
    setState(() {
      model.initialZero = newValue;
    });
  }

  void setInitialZeroRange(double value) {
    GRAMModel model = GRAMModel.shared;

    model.connection
        .enqueueMessage(GRAMMessage.initialZeroRange(value.round()));
    setState(() {
      model.initialZeroRange = value.round();
    });
  }

  void adjustInitialZeroRange(double value) {
    setState(() {
      _initialZeroRange = value;
    });
  }

  void setZeroTracking(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.zeroTracking(newValue));
    setState(() {
      model.zeroTrackingDevice = newValue;
    });
  }

  void setZeroTrackingRange(int value) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.zeroTrackingRange(value));
    setState(() {
      model.zeroTrackingRange = value;
    });
  }

  Widget zeroOptions(BuildContext context) {
    GRAMModel model = GRAMModel.shared;
    _initialZeroRange = model.initialZeroRange.toDouble();

    return Wrap(runSpacing: 10.0, children: [
      labeledSwitch(model.tr.localize("Initial Zero Setting"),
          model.initialZero, setInitialZero,
          enabled: !model.sealed),
      LabeledSlider(model.tr.localize("Initial Zero Range"), 0.0, 100.0,
          _initialZeroRange, setInitialZeroRange, !model.sealed),
      labeledSwitch(model.tr.localize("Zero Tracking device"),
          model.zeroTrackingDevice, setZeroTracking,
          enabled: !model.sealed),
      labeledSegmentsFromText(
          model.tr.localize("Zero Tracking Rng"),
          ["R 0", "R 1", "R 2", "R 3"],
          model.zeroTrackingRange,
          setZeroTrackingRange,
          enabled: !model.sealed),
    ]);
  }

  /***
   * Tare Options
   */

  void setAutoTare(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.autoTare(newValue));
  }

  void setTareOnStability(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.tareOnStability(newValue));
  }

  void setTareMode(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.toggleTareMode());
  }

  Widget tareOptions(BuildContext context) {
    GRAMModel model = GRAMModel.shared;

    return Wrap(runSpacing: 10.0, children: [
      labeledSwitch(model.tr.localize("Auto Tare"), model.autoTare, setAutoTare,
          enabled: !model.sealed),
      labeledSwitch(model.tr.localize("Tare when stable"),
          model.tareOnStability, setTareOnStability,
          enabled: !model.sealed),
      labeledSwitch(
          model.tr.localize("Tare mode"), model.tareMode == 0, setTareMode,
          enabled: !model.sealed),
    ]);
  }

  /*
   * Filter Options
   */

  void adjustFilterLevel(int dir) {
    GRAMModel model = GRAMModel.shared;

    var fl = model.filterLevel;

    if (dir == 0 && model.filterLevel > 1) {
      fl = fl - 1;
    } else if (dir == 1 && model.filterLevel < 6) {
      fl = fl + 1;
    }

    model.connection.enqueueMessage(GRAMMessage.filterLevel(fl));
    setState(() {
      model.filterLevel = fl;
    });
  }

  void setLivestockFilter(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.livestockFilter(newValue));
    setState(() {
      model.livestockFilter = newValue;
    });
  }

  void setMotionFilter(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.motionFilter(newValue));
  }

  void setStabilityRange(String newValue) {
    GRAMModel model = GRAMModel.shared;
    int v = int.parse(newValue);
    model.connection.enqueueMessage(GRAMMessage.stabilityRange(v));
    setState(() {
      model.stabilityRange = v;
    });
  }

  void setOutputRate(String newValue) {
    GRAMModel model = GRAMModel.shared;
    int v = int.parse(newValue);

    model.connection.enqueueMessage(GRAMMessage.outputRate(v));
    setState(() {
      model.outputRate = v;
    });
  }

  void setWeighing(int newValue) {
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.adSpeed(newValue));
    setState(() {
      model.adSpeed = newValue;
    });
  }

  Widget filterOptions(BuildContext context) {
    GRAMModel model = GRAMModel.shared;

    return Wrap(runSpacing: 10.0, children: [
      stepper(model.tr.localize("Filter Level"), model.filterLevel,
          adjustFilterLevel),
      labeledSwitch(model.tr.localize("Livestock filter"),
          model.livestockFilter, setLivestockFilter),
      labeledSwitch(model.tr.localize("Motion filter"), model.motionFilter,
          setMotionFilter),

      //TODO: Afegir Motion Filter, Stability Range, Output Rate and Wifgh AC/DC Speed

      labeledNumericField(model.tr.localize("Stability range"),
          model.stabilityRange.toString(), setStabilityRange,
          enabled: !model.sealed),
      labeledNumericField(model.tr.localize("Output rate (ms)"),
          model.outputRate.toString(), setOutputRate),
      labeledSegmentsFromText(model.tr.localize("Weighing AD/C speed)"),
          ["12 sps", "50 sps"], model.adSpeed, setWeighing),
    ]);
  }

  /*
    COM Port
   */
  void setComPort(String newValue) {
    GRAMModel model = GRAMModel.shared;
    print("COM Port : $newValue ");
  }

  void adjustComSpeed(int newValue) {
    var l = ["9600", "19200", "38400", "57600", "115200"];
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.baudRate(newValue));
    setState(() {
      model.baudRate = newValue;
    });
  }

  Widget comPortOptions(BuildContext context) {
    GRAMModel model = GRAMModel.shared;

    return Wrap(runSpacing: 10.0, children: [
      labeledTextField(model.tr.localize("COM port"), "COM4", setComPort,
          enabled: false),

      labeledDropDown("Speed", ["9600", "19200", "38400", "57600", "115200"],
          model.baudRate, adjustComSpeed),

      // labeledTextField(model.tr.localize("Speed"), "9600t", adjustComSpeed),

      //TODO: Afegir COM Port configuration
    ]);
  }

  /* Advanced : Network */


  Widget networkOptions(BuildContext context) {

    return NetworkOptions();
  }

  /* Dummy */
  Widget dummy(BuildContext context) {
    return Text("Not Implemented");
  }

  Widget licenses(BuildContext context) {
    return LicenseSettings();
  }

  Widget printerSettings(BuildContext context) {
    return PrinterSettings();
  }

  Widget databaseSettings(BuildContext context) {
    return DatabaseSettings();
  }

  /* Scale Definiotion*/

  Widget scaleDefinition(BuildContext context) {
    return ScaleDefinition();
  }

  /* About */

  void getInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      versionString = "Version $version ($buildNumber)";
      signature = packageInfo.buildSignature;

      setState(() {});
    });
  }

  Widget about(BuildContext context) {
    GRAMModel model = GRAMModel.shared;

    getInfo();

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: 150.0,
        height: 50.0,
        child: getImage("logo", 0),
      ),
      SizedBox(height: 10.0),
      Text(versionString),
      SizedBox(height: 10.0),
      Text("Signature", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(signature, style: TextStyle(fontSize: 12)),
      SizedBox(height: 10.0),
      Text("MD5 Digest", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(model.apkHash, style: TextStyle(fontSize: 12)),
      SizedBox(height: 10.0),
      TextButton(
        onPressed: () => Navigator.push(
            context, SlideLeftRoute(widget: DocumentViewer(model.manualURL))),
        child: Text(
          "Help",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      SizedBox(height: 10.0),
      TextButton(
        onPressed: () => Navigator.push(
            context,
            SlideLeftRoute(
                widget: DocumentViewer(
                    "https://gram-group.com/xtrem-presentation/"))),
        child: Text(
          "Support",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
    ]);
  }
}
