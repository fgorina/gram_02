import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'GRAMModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'LabeledDropDown.dart';
import 'LabeledSwitch.dart';
import 'LabeledSegments.dart';
import 'LabeledTextField.dart';
import 'GRAMMessage.dart';
import 'Units.dart';
import 'Dialogs.dart';
import 'LocalFileSystemUtilities.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:convert';

class ScaleDefinition extends StatefulWidget {
  _ScaleDefinitionState createState() => _ScaleDefinitionState();
}

class _ScaleDefinitionState extends State<ScaleDefinition> {
  GRAMModel model = GRAMModel.shared;

  bool waitingForCountsForInitialZero = false;
  bool waitingForCountsForSlope = false;

  double pes = 0.0;

  List<int> eValues = [1, 2, 5, 10, 20, 50];

  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    model.addSubscriptor(this, tecnic: true);

    model.connection.enqueueMessage(GRAMMessage.getInitialZeroCounts());
    model.connection.enqueueMessage(GRAMMessage.getAdcCountsFiltered());
    model.connection.enqueueMessage(GRAMMessage.getSlopeDivisor());
  }

  void dispose() {
    model.removeSubscriptors(this);
    super.dispose();
  }

  void setNegativeWeight(bool newValue) {
    GRAMModel model = GRAMModel.shared;
    model.connection.enqueueMessage(GRAMMessage.allowNegativeWeight(newValue));

    setState(() {
      model.allowNegativeWeight = newValue;
    });
  }

  void setScaleUnit(int newValue) {
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.scaleUnit(newValue + 1));
    setState(() {
      model.scaleUnit = unitsCodes[newValue + 1];
    });
  }

  void setDecimalPointPosition(int newValue) {
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.decimalPointPosition(newValue));
    setState(() {
      model.decimalPointPosition = newValue;
    });
  }

  void setRangeMode(int newValue) {
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.rangeMode(newValue));
    setState(() {
      model.rangeMode = newValue;
    });
  }

  int eToIndex(double v) {
    for (int i = 0; i < model.decimalPointPosition; i++) {
      v = v * 10.0;
    }
    int iv = v.round();

    if (!eValues.contains(iv)) {
      iv = 1;
    }

    return iv;
  }

  double intToe(int i) {
    return i.toDouble();
  }

  void setMax1(String newValue) {
    GRAMModel model = GRAMModel.shared;

    double raw = double.parse(newValue.replaceAll(",", "."));

    for (int i = 0; i < model.decimalPointPosition; i++) {
      raw *= 10.0;
    }

    int v = raw.round();
    model.connection.enqueueMessage(GRAMMessage.setMax1(v));
    setState(() {
      model.modes[0].max = v.toDouble();
    });
  }

  void sete1(int newvalue) {
    GRAMModel model = GRAMModel.shared;

    model.connection.enqueueMessage(GRAMMessage.sete1(newvalue));
    setState(() {
      double v = newvalue.toDouble();

      for (int i = 0; i < model.decimalPointPosition; i++) {
        v = v / 10.0;
      }
      model.modes[0].e = v;
    });
  }

  void setMax2(String newValue) {
    GRAMModel model = GRAMModel.shared;

    double raw = double.parse(newValue.replaceAll(",", "."));

    for (int i = 0; i < model.decimalPointPosition; i++) {
      raw *= 10.0;
    }

    int v = raw.round();

    model.connection.enqueueMessage(GRAMMessage.setMax2(v));
    setState(() {
      model.modes[1].max = v.toDouble();
    });
  }

  void sete2(int newvalue) {
    GRAMModel model = GRAMModel.shared;

    double v = newvalue.toDouble();

    for (int i = 0; i < model.decimalPointPosition; i++) {
      v = v / 10.0;
    }
    model.connection.enqueueMessage(GRAMMessage.sete2(newvalue));
    setState(() {
      model.modes[1].e = v;
    });
  }

  /* When pressing button it sets current count to zero */

  void adjustZero() {
    model.connection.enqueueMessage(GRAMMessage.getAdcCountsFiltered());
    waitingForCountsForInitialZero = true;
  }

  /* If entered manually it sets the value or initialZeroCounts directly */

  void setZeroCounts(String v) {
    int value = int.parse(v);

    model.connection.enqueueMessage(GRAMMessage.initialZeroCounts(value));
    setState(() {
      model.initialZeroCounts = value;
      updateChanges();
    });
  }

  void enterWeight() {
    _textFieldController.text = model.scale.networkPassword;
    displayYesNoDialog(context, model.tr.localize("Enter weight in the scale"),
        "Weight", _textFieldController, (v) {
      pes = double.parse(v.replaceAll(",", "."));
      adjustSlope();
    }, okButton: "Adjust", cancelButton: "Cancel");
  }

  void adjustSlope() {
    model.connection.enqueueMessage(GRAMMessage.getAdcCountsFiltered());
    waitingForCountsForSlope = true;
  }

  void setSlope(String v) {
    double slope = double.parse(v.replaceAll(",", "."));

    model.connection.enqueueMessage(GRAMMessage.slopeDivisor(slope));
    setState(() {
      model.slopeDivisor = slope;
      updateChanges();
    });
  }

  void setGeoCode(String v) {
    int geocode = int.parse(v);

    model.connection.enqueueMessage(GRAMMessage.geoCode(geocode));

    setState(() {
      model.geoCode = geocode;
    });
  }

  void setGeoCodeAdjustment(String v) {
    int geocode = int.parse(v);

    model.connection.enqueueMessage(GRAMMessage.geoCodeAdjustment(geocode));

    setState(() {
      model.geoCodeAdjustment = geocode;
    });
  }

  void resetScale() {
    displayOptionsAlert(context, "Reset Scale",
        "Do you really want to reset the scale?", "Yes", doResetScale);
  }

  void doResetScale() {
    model.connection.enqueueMessage(GRAMMessage.resetScale());
  }

  String getStringValue(Map<String, dynamic> json, String name) {
    var value = json[name];
    if (value == null) {
      return "0";
    } else {
      return value;
    }
  }

  int getIntValue(Map<String, dynamic> json, String name) {
    String value = getStringValue(json, name);

    var i = int.parse(value);

    if (i != null) {
      return i;
    } else {
      return -1;
    }
  }

  double getDoubleValue(Map<String, dynamic> json, String name) {
    String value = getStringValue(json, name);

    var i = double.parse(value);

    if (i != null) {
      return i;
    } else {
      return -1.0;
    }
  }

  Future<String> settingsPathForScale(String serialNumber) async{
    return await settingsPath() + "/" + serialNumber + ".json";
  }

  Future<File> saveSettings() async {
    var ux = units[model.scaleUnit];
    var uc = 1;
    if (ux != null) {
      uc = ux.code;
    }

    String path = await settingsPathForScale(model.serialNumber);

    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted){
      print("Permissos concedits");
    }else{
      print("Permisos denegats ${status}");
    }

    var file = File(path);

    Map<String, String> json = {
      'allownegativeweight': model.allowNegativeWeight ? "true" : "false",
      'weighingunit': symbolLiterals()[uc - 1],
      'decimalplaces': sprintf("%d", [model.decimalPointPosition]),
      'rangemode': sprintf("%d", [model.rangeMode]),
      'max1': sprintf("%g", [model.modes[0].max]),
      'e1': sprintf("%g", [model.modes[0].e]),
      'max2': sprintf("%g", [model.modes[1].max]),
      'e2': sprintf("%g", [model.modes[1].e]),
      'initialzerocounts': sprintf("%d", [model.initialZeroCounts]),
      'slopedivisor': sprintf("%g", [model.slopeDivisor]),
      'geocodeadjustment': sprintf("%d", [model.geoCodeAdjustment]),
      'geocode': sprintf("%d", [model.geoCode]),
    };
    var jsonData = JsonEncoder().convert(json);

    print("SAVE SETTINGS");
    print(jsonData);
    try {
      var afile = await file.writeAsString(jsonData);
      return afile;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> loadSettings() async {
    String path = await settingsPathForScale(model.serialNumber);


    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted){
      print("Permissos concedits");
    }else{
      print("Permisos denegats ${status}");
    }

    var file = File(path);

    try {
      var jsonData = await file.readAsString();
      print("JSON DATA");
      print(jsonData);
      if (jsonData != "Error!") {
        var json = JsonDecoder().convert(jsonData);

        print(json);
        model.allowNegativeWeight =
            getStringValue(json, 'allownegativeweight') == 'true'
                ? true
                : false;


        var abrev = getStringValue(json, 'weighingunit');
        if(abrev.length == 1){
          abrev = abrev + " ";
        }

        print("|${abrev}|");
        model.scaleUnit = unitsAbrev[abrev];

        model.decimalPointPosition = getIntValue(json, 'decimalplaces');
        model.rangeMode = getIntValue(json, 'rangemode');

        String max1 = getStringValue(json, 'max1');
        String max2 = getStringValue(json, 'max2');

        model.modes[0].e = getDoubleValue(json, 'e1');
        model.modes[1].e = getDoubleValue(json, 'e2');

        model.initialZeroCounts = getIntValue(json, 'initialzerocounts');
        model.slopeDivisor = getDoubleValue(json, 'slopedivisor');

        model.geoCodeAdjustment = getIntValue(json, 'geocodeadjustment');
        model.geoCode = getIntValue(json, 'geocode');

        // Update Scale

        setNegativeWeight(model.allowNegativeWeight);
        setDecimalPointPosition(model.decimalPointPosition);
        setRangeMode(model.rangeMode);
        setMax1(max1);
        sete1(model.modes[0].e.round());
        setMax2(max2);
        sete2(model.modes[1].e.round());

        setZeroCounts(model.initialZeroCounts.toString());
        setSlope(model.slopeDivisor.toString());

        setGeoCodeAdjustment(model.geoCodeAdjustment.toString());
        setGeoCode(model.geoCode.toString());

        return json;
      } else {
        return null;
      }
    } catch (e) {
      print("Error $e a $path");
    }
  }

  void updateChanges() {
    if (int.parse(model.firmwareVersion) >= 3007) {
      print("Updating update data");
      var now = DateTime.now();
      String stringDate = "${now.day}/${now.month}/${now.year}";
      DateFormat formatter = DateFormat('dd/MM/yy HH:mm:ss');
      stringDate = formatter.format(now);
      model.connection
          .enqueueMessage(GRAMMessage.dateLastCalibration(stringDate));
      model.lastChange = stringDate;
      model.counterChange += 1;
    }
  }

  void tecnicUpdated(AddressType type, String data) {
    if (waitingForCountsForInitialZero &&
        type == AddressType.adcCountsFiltered) {
      model.connection.enqueueMessage(
          GRAMMessage.initialZeroCounts(model.adcCountsFiltered));
      waitingForCountsForInitialZero = false;

      setState(() {
        model.initialZeroCounts = model.adcCountsFiltered;
        updateChanges();
      });
    }

    if (waitingForCountsForSlope && type == AddressType.adcCountsFiltered) {
      print("Counts 0 ${model.adcCountsFiltered}");

      // Compute the slope :

      double counts =
          (model.adcCountsFiltered - model.initialZeroCounts).toDouble();

      double slope = (counts / pes);

      for (int i = 0; i < model.decimalPointPosition; i++) {
        slope = slope / 10.0;
      }

      model.connection.enqueueMessage(GRAMMessage.slopeDivisor(slope));
      waitingForCountsForSlope = false;
      setState(() {
        model.slopeDivisor = slope;
        updateChanges();
      });
    }

    if (type != AddressType.adcCountsFiltered) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    var ux = units[model.scaleUnit];
    var uc = 1;
    if (ux != null) {
      uc = ux.code;
    }

    return Padding(
      padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 10.0, bottom: 0.0),
      child: Wrap(runSpacing: 10.0, children: [
        !model.sealed
            ? labeledSwitch(
                model.tr.localize("Allow negative settings"),
                model.allowNegativeWeight,
                setNegativeWeight,
              )
            : Container(width: 100),
        labeledSegmentsFromText(model.tr.localize("Weighing unit"),
            symbolLiterals(), uc - 1, setScaleUnit,
            enabled: !model.sealed),
        labeledSegmentsFromText(
            model.tr.localize("Decimal places"),
            [" 0 ", " 1 ", " 2", " 3", " 4"],
            model.decimalPointPosition,
            setDecimalPointPosition,
            enabled: !model.sealed),
        labeledDropDown(
            model.tr.localize("Range mode"),
            [
              model.tr.localize("Single range"),
              model.tr.localize("2 ranges"),
              model.tr.localize("2 intervals")
            ],
            model.rangeMode,
            setRangeMode,
            enabled: !model.sealed),

        (model.rangeMode > 0)
            ? Row(
                children: [
                  Container(width: 150),
                  Spacer(),
                  Container(
                      width: 100,
                      child: Text(model.tr.localize("Range 1"),
                          textAlign: TextAlign.right)),
                  Container(width: 10),
                  Container(
                      width: 100,
                      child: Text(model.tr.localize("Range 2"),
                          textAlign: TextAlign.right)),
                ],
              )
            : Text(" "),

        (model.rangeMode > 0)
            ? labeled2NumericField(
                model.tr.localize("Max"),
                model.modes[0].max.toString(),
                model.modes[1].max.toString(),
                setMax1,
                setMax2,
                enabled: !model.sealed,
                enabled1: !model.sealed & (model.rangeMode > 0),
              )
            : labeledNumericField(model.tr.localize("Max"),
                model.modes[0].max.toString(), setMax1,
                enabled: !model.sealed),

        /* (model.rangeMode > 0)
            ? labeled2NumericField(
                model.tr.localize("e"),
                model.modes[0].e.toString(),
                model.modes[1].e.toString(),
                sete1,
                sete2,
                enabled: !model.sealed,
                enabled1: !model.sealed & (model.rangeMode > 0),
              )
            : labeledNumericField(
                model.tr.localize("e"), model.modes[0].e.toString(), sete1,
                enabled: !model.sealed),

        */

        (model.rangeMode > 0)
            ? labeled2PopupField(
                model.tr.localize("e"),
                eToIndex(model.modes[0].e),
                eToIndex(model.modes[1].e),
                eValues,
                sete1,
                sete2,
                enabled: !model.sealed,
                enabled1: !model.sealed & (model.rangeMode > 0),
              )
            : labeled1PopupField(
                model.tr.localize("e"),
                eToIndex(model.modes[0].e),
                eValues,
                sete1,
                enabled: !model.sealed,
              ),

        labeledGenericText(model.tr.localize("Current A/D cts"),
            AddressType.adcCountsFiltered, Duration(milliseconds: 500)),
        labeledNumericFieldButton(
            model.tr.localize("Initial Zero"),
            model.initialZeroCounts.toString(),
            model.tr.localize("Adjust Zero"),
            setZeroCounts,
            adjustZero,
            enabled: !model.sealed),
        labeledNumericFieldButton(
            model.tr.localize("Slope Divisor"),
            model.slopeDivisor.toString(),
            model.tr.localize("Adjust Span"),
            setSlope,
            enterWeight,
            enabled: !model.sealed),
        //stepper(model.tr.localize("AC/DC cts"), (model.slopeDivisor * model.modes[0].e.toDouble()).round(), step, enabled: !model.sealed),
        //labeled2TextField(model.tr.localize("Input Sig"), model.modes[0].max.toString(), model.modes[1].max.toString(), null, null ),
        //labeledText(model.tr.localize("Current A/D cts"), model.adcCountsFiltered.toString(),),

        labeledNumericField(model.tr.localize("GEO code adjustment"),
            model.geoCodeAdjustment.toString(), setGeoCodeAdjustment,
            enabled: !model.sealed),
        labeledNumericField(model.tr.localize("GEO code place of use"),
            model.geoCode.toString(), setGeoCode,
            enabled: !model.sealed),

        int.parse(model.firmwareVersion) > 3005
            ? labeledText(model.tr.localize("Last Change"), model.lastChange)
            : Text(""),
        int.parse(model.firmwareVersion) > 3005
            ? labeledText(
                model.tr.localize("Counter"), model.counterChange.toString())
            : Text(""),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            OutlinedButton(
              onPressed: saveSettings,
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: Text(
                model.tr.localize("Save Adjust"),
              ),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: resetScale,
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: Text(
                model.tr.localize("Scale Reset"),
              ),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: loadSettings,
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: Text(
                model.tr.localize("Restore Adjust"),
              ),
            ),
            Spacer(),
          ],
        ),
      ]),
    );
  }
}
