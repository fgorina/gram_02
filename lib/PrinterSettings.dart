import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:sprintf/sprintf.dart';

import 'GRAMModel.dart';
import 'LabeledSegments.dart';
import 'screensize_reducers.dart';

import 'LocalFileSystemUtilities.dart';

import 'ESCPrinter.dart';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as pth;
import 'Label.dart';

import "CPCLPrinter.dart";
import 'package:flutter_blue/flutter_blue.dart';
import "BlueConnection.dart";
import "SerialPrinterConnection.dart";
import 'LabeledTextField.dart';

import 'Log.dart';

class PrinterSettings extends StatefulWidget {
  _PrinterSettingsState createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<PrinterSettings> {
  GRAMModel model = GRAMModel.shared;
  TextEditingController controller = TextEditingController();

  List<int> printerWidths = [32, 36, 48, 80];
  List<int> printerSpeeds = [9600, 19200, 38400, 57600, 115200];
  List<String> barcodes = [ "No Barcode", "UPC A", "UPC E", "EAN13", "EAN8", "Code 39", "2 of 5", "CODABAR", "Code 93", "Code128", 'QR'];
  List<int> margins = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    controller.text = model.labelName;
  }

  void setPrinterName(String name) {
    model.printerName = name;
    model.saveDefaults();

    model.printerConnection = name.startsWith("/dev/tty")
        ? SerialPrinterConnection()
        : BlueConnection(FlutterBlue.instance);
    if (model.printerType == "ESC") {
      model.aprinter = ESCPrinter(model.printerConnection);
    } else {
      model.aprinter = CPCLPrinter(model.printerConnection);
    }
  }

  void setPrinterType(int type) {
    setState(() {
      model.printerType = ["ESC", "CPCL"][type];
      model.saveDefaults();
      if (type == 0) {
        model.aprinter = ESCPrinter(model.printerConnection);
      } else {
        model.aprinter = CPCLPrinter(model.printerConnection);
      }
    });
  }

  Future<bool> requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  void selectLabel() async {
    await Permission.storage.request();
    var path = await labelPath();
    var labelsDir = Directory(path);

    String label = await FilesystemPicker.open(
      title: model.tr.localize('Select Label'),
      context: context,
      rootDirectory: labelsDir,
      fsType: FilesystemType.all,
      permissionText: model.tr.localize("Permission was not granted"),
      //allowedExtensions: ['.zip'],
      pickText: model.tr.localize("Select a label "),
      folderIconColor: Colors.teal,
      requestPermission: requestPermission,
    );

    if (label != null) {
      setState(() {
        var name = pth.basename(label);
        model.labelName = name;
        model.label = Label();
        model.label.load(name);
        controller.text = name;
        model.saveDefaults();
        print(name);
      });
    }
  }

  void importLabel() async {
    var path = await localPath() + "/Labels";
    var labelsDir = Directory(path);

    if (!await labelsDir.exists()) {
      await labelsDir.create(recursive: true);
    }
    var importDir = await downloadsDirectory();

    print("External dir ${importDir.path}");
    String labelPath = await FilesystemPicker.open(
      title: model.tr.localize("Import Label"),
      context: context,
      rootDirectory: importDir,
      fsType: FilesystemType.all,
      permissionText: model.tr.localize("Permission was not granted"),
      //allowedExtensions: ['.zip'],
      pickText: model.tr.localize("Select a label "),
      folderIconColor: Colors.teal,
      requestPermission: requestPermission,
    );

    if (labelPath == null) {
      return;
    }

    // Now we must extract the zip into our labels directory

    var inFile = File(labelPath);

    var destDir = path + "/" + pth.basename(labelPath).replaceAll(".zip", "");

    ZipFile.extractToDirectory(
        zipFile: inFile, destinationDir: Directory(destDir));
  }

  void setPrinting(int value) {
    print(sprintf("Printing %d", [value]));
    setState(() {
      model.setPrinting(value);
    });
  }

  int speedIndex() {
    int v = model.serialPrinterSpeed;
    print("Printer Speed ${model.serialPrinterSpeed}");
    if (!printerSpeeds.contains(v)) {
      return printerSpeeds[0];
    } else {
      return v;
    }
  }

  void dummy(String s){

  }
  void setSpeed(int value) {
    setState(() {
      model.serialPrinterSpeed = value;
      try {
         model.aprinter.connect(model.printerName, dummy,);

      } catch (e) {
        Log.shared.error("Model._constructor", "Starting Scan", [e]);
      }
    });

    model.saveDefaults();

    print("Connection to printer at ${value}");
  }

  int widthIndex() {
    int v = model.printerWidth;

    if (!printerWidths.contains(v)) {
      return printerWidths[0];
    } else {
      return v;
    }
  }

  void setWidth(int value) {
    setState(() {
      model.printerWidth = value;
    });

    model.saveDefaults();

    print("Printer Width :t ${value}");
  }

  void setBarcode(int newValue){
    setState(() {
      model.barcode = newValue - 1;
    });

    model.saveDefaults();

    print("New Barcode :t ${newValue - 1}");
  }

  void setMargin(int newValue){
    setState(() {
      model.leftMargin = newValue;
    });

    model.saveDefaults();

    print("New Margin : ${newValue}");
  }



  Widget build(BuildContext context) {
    return Wrap(runSpacing: 20.0, children: [
      labeledSegmentsFromText(model.tr.localize("Printing"),
          ["No", "Label 1", "Label 2", "User"], model.printing, setPrinting),

      labeled1PopupField(
        model.tr.localize("Left Margin"),
        model.leftMargin,
        margins,
        setMargin,
      ),

      labeledStringPopupField(
        model.tr.localize("Barcode Type"),
        model.barcode+1,
        barcodes,
        setBarcode,

      ),
      TextField(
          onChanged: setPrinterName,
          controller: TextEditingController(text: model.printerName),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: model.tr.localize("Printer Name"),
          )),
      labeled1PopupField(
    model.tr.localize("Printer Width"), widthIndex(), printerWidths, setWidth),
      labeled1PopupField(
    model.tr.localize("Serial Printer Speed"), speedIndex(), printerSpeeds, setSpeed),
      labeledSegmentsFromText(model.tr.localize("Protocol"), ["ESC", "CPCL"],
          model.printerType == 'ESC' ? 0 : 1, setPrinterType),
      Row(children: [
        Container(
          width: screenWidth(context) -
              ((screenWidth(context) > screenHeight(context)) ? 270 : 90),
          child: TextField(
              controller: controller,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: model.tr.localize('Current Label'),
              )),
        ),
        Spacer(),
        IconButton(icon: Icon(Icons.adjust), onPressed: selectLabel),
      ]),
      Row(children: [
        Spacer(),
        TextButton(onPressed: importLabel, child: Text(model.tr.localize('Import Label'))),
        Spacer(),
      ]),
    ]);
  }
}
