import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'GRAMModel.dart';
import 'LabeledSegments.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'LabeledSwitch.dart';
import 'GRAMMessage.dart';
import 'package:sprintf/sprintf.dart';
import 'Dialogs.dart';

import 'ColorCompatibility.dart';

import 'SettingsScreen.dart';

import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

class Setup extends StatefulWidget {
  Function dialogFunction;

  Setup(Function dialogFunction) {
    this.dialogFunction = dialogFunction;
  }

  _SetupState createState() => _SetupState(dialogFunction);
}

class _SetupState extends State<Setup> {
  Function dialogFunction;

  GRAMModel model = GRAMModel.shared;
  TextEditingController _textFieldController = TextEditingController();


  double bottomPadding = 0.0;

  _SetupState(Function dialogFunction) {
    this.dialogFunction = dialogFunction;


  }

   @override
  void initState() {
    super.initState();
    model.addSubscriptor(this);

    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,

    ]);

     */
  }


  void dummy(bool newValue) {
    print("New Value : $newValue");
  }

  void setAutoTare(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.autoTare(newValue));
  }

  void setTareOnStability(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.tareOnStability(newValue));
  }

  void setTareMode(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.toggleTareMode());
  }

  void setZeroTracking(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.zeroTracking(newValue));
  }

  void setRecordsToZero(bool newValue) {
    model.recordsToZero = newValue;
    setState(() {});
  }

  void setZeroTrackingRange(int value) {
    model.connection.enqueueMessage(GRAMMessage.zeroTrackingRange(value));
  }

  void setLivestockFilter(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.livestockFilter(newValue));
  }

  void adjustFilterLevel(int dir) {
    var fl = model.filterLevel;

    if (dir == 0 && model.filterLevel > 1) {
      fl = fl - 1;
    } else if (dir == 1 && model.filterLevel < 6) {
      fl = fl + 1;
    }

    model.connection.enqueueMessage(GRAMMessage.filterLevel(fl));
  }

  void setPrinting(int value) {
    print(sprintf("Printing %d", [value]));
    setState(() {
      model.setPrinting(value);
    });
  }

  void changeSSID() {
    _textFieldController.text = model.scale.ssid;
    displayYesNoDialog(context, model.tr.localize("Enter Scale Name"),
        model.tr.localize("Name"), _textFieldController, (v) {
      model.connection.enqueueMessage(GRAMMessage.ssidName(v));
    });
  }

  void setNetDhcp(bool newValue) {
    model.connection.enqueueMessage(GRAMMessage.netDhcp(newValue));
  }

  void changeNet() {
    _textFieldController.text = model.scale.networkName;
    displayYesNoDialog(context, model.tr.localize("Enter Network Name"),
        model.tr.localize("Name"), _textFieldController, (v) {
      model.connection.enqueueMessage(GRAMMessage.networkName(v));
    });
  }

  void changeNetPwd() {
    _textFieldController.text = model.scale.networkPassword;
    displayYesNoDialog(context, model.tr.localize("Enter Network Password"),
        model.tr.localize("Password"), _textFieldController, (v) {
      model.connection.enqueueMessage(GRAMMessage.networkPassword(v));
    });
  }

  void changeNetIp() {
    _textFieldController.text = model.scale.networkPassword;
    displayYesNoDialog(context, model.tr.localize("Enter Network IP"), "IP",
        _textFieldController, (v) {
      model.connection.enqueueMessage(GRAMMessage.netIp(v));
    });
  }

  void close() {
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }

  Widget buildWidgetH() {
    return Container(
        decoration:
            BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
        height: screenHeight(context),
        padding: EdgeInsets.only(left: 30, top: 30.0, right: 5, bottom: 0.0),
        child: SettingsScreen());
  }

  Widget buildWidget() {


       return
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.start,

           SettingsScreen();

  }

  Widget buildWidgetOld() {
    return Container(
      decoration:
          BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),

      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 30.0, right: 5, bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(model.tr.localize('Settings'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0), fontSize: 24)),
          SizedBox(height: 50.0),

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              height: screenHeight(context) - 110.0,
              width: screenWidth(context) - 70.0,
              child: ListView(
                children: [
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 50.0, right: 0.0, bottom: 0.0)),
                  //Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Setup", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),],),
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 50.0, right: 0.0, bottom: 0.0)),
                  Container(
                      height: 40,
                      child: labeledSwitch(model.tr.localize("Auto Tare"),
                          model.autoTare, setAutoTare)),
                  Container(
                      height: 40,
                      child: labeledSwitch(
                          model.tr.localize("Tare when stable"),
                          model.tareOnStability,
                          setTareOnStability)),
                  Container(
                      height: 40,
                      child: labeledSwitch(model.tr.localize("Tare mode"),
                          model.tareMode == 0, setTareMode)),
                  Container(
                      height: 40,
                      child: labeledSwitch(
                          model.tr.localize("Zero Tracking device"),
                          model.zeroTrackingDevice,
                          setZeroTracking)),
                  Container(
                      height: 40,
                      child: labeledSegmentsFromText(
                          model.tr.localize("Zero Tracking Rng"),
                          ["R 0", "R 1", "R 2", "R 3"],
                          model.zeroTrackingRange,
                          setZeroTrackingRange)),
                  Container(
                      height: 40,
                      child: stepper(model.tr.localize("Filter Level"),
                          model.filterLevel, adjustFilterLevel)),
                  Container(
                      height: 40,
                      child: labeledSwitch(
                          model.tr.localize("Livestock filter"),
                          model.livestockFilter,
                          setLivestockFilter)),
                  Container(
                      height: 40,
                      child: labeledSwitch(model.tr.localize("Records no 0"),
                          model.recordsToZero, setRecordsToZero)),
                  Container(
                      height: 40,
                      child: labeledSegmentsFromText(
                          model.tr.localize("Label"),
                          ["No", "Tip 1", "Tip 2", "User"],
                          model.printing,
                          setPrinting)),
                  Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 12),
                      child: labeledLink(
                          "SSID",
                          model.scale.ssid.isEmpty ? "***" : model.scale.ssid,
                          changeSSID,
                          context,
                          textAlign: TextAlign.right)),
                  Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 12),
                      child: labeledLink(
                          "S/N", model.serialNumber, null, context,
                          textAlign: TextAlign.right)),
                  Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 12),
                      child: labeledLink(
                          model.tr.localize("Net SSID"),
                          model.netName.isEmpty ? "***" : model.netName,
                          changeNet,
                          context,
                          textAlign: TextAlign.right)),
                  Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 12),
                      child: labeledLink(
                          model.tr.localize("Net Pwd"),
                          model.netPassword.isEmpty ? "***" : model.netPassword,
                          changeNetPwd,
                          context,
                          textAlign: TextAlign.right)),
                  Container(
                      height: 40,
                      child: labeledSwitch(model.tr.localize("Net DHCP"),
                          model.netDhcp, setNetDhcp)),
                  Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 12),
                      child: labeledLink(
                          model.tr.localize("Net IP"),
                          model.netIp.isEmpty ? "***" : model.netIp,
                          changeNetIp,
                          context,
                          textAlign: TextAlign.right)),
                ],
              ), // END OF ListView
            ),
            Container(
              width: 30,
              child: activeImage(
                "back_right",
                close,
                context,
              ),
            ),
          ]), // End of row
        ],
      ), // End of Column
    );
  }

  void modelUpdated() {
    //setState(() {});
  }



    @override
    Widget build(BuildContext context) {
      return KeyboardSizeProvider(
        smallSize: 500.0,
        child: Scaffold(
          appBar: null,
          body: buildWidget(),
        ),
      );
    }



  @override
  void dispose() {
    model.removeSubscriptors(this);


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
