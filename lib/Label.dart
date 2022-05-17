import 'package:flutter/material.dart';
import 'VariableInfo.dart';
import 'LineInfo.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_archive/flutter_archive.dart';
import 'PrinterProtocol.dart';
import 'WeightRecord.dart';
import 'package:share/share.dart';
import 'LocalFileSystemUtilities.dart';
import 'package:permission_handler/permission_handler.dart';


class Label {
  int labelWidth = 36; // Chars de 12 x 24  // Eren 48
  int labelHeight = 20; // Lines de 24

  List<LineInfo> lines = [];
  //List<GlobalKey> keys = [];

  img.Image grayscale;
  img.Image blackAndWhite;

  var grayLevel = RangeValues(64.0, 192.0);
  var logoWidth = 304;
  var logoHeight = 150;
  var logoMode = 0; // 0 -> B&W, 1 -> Grayscale

  Label({int n = 20, int width = 36}) {
    lines = [];
    for (int i = 0; i < n; i++) {
      lines.add(LineInfo());
      //keys.add(GlobalKey());
      labelHeight = n;
      labelWidth = width;
    }
  }

  Label.fromJSON(Map<String, dynamic> json) {
    labelWidth = json['labelWidth'];
    labelHeight = json['labelHeight'];
    grayLevel = RangeValues(json['grayLevelMin'], json['grayLevelMax']);
    logoWidth = json['logoWidth'];
    logoHeight = json['logoHeight'];
    logoMode = json['logoMode'];

    List<Map<String, dynamic>> jsonLines = json['lines'];

    lines = jsonLines.map((l) => LineInfo.fromJSON(l, blackAndWhite));
  }

  void fromJSON(Map<String, dynamic> json) {
    labelWidth = json['labelWidth'];
    labelHeight = json['labelHeight'];
    grayLevel = RangeValues(json['grayLevelMin'], json['grayLevelMax']);
    logoWidth = json['logoWidth'];
    logoHeight = json['logoHeight'];
    logoMode = json['logoMode'];

    var jsonLines = json['lines'].toList();
     var aux = jsonLines
        .map<LineInfo>((l) => LineInfo.fromJSON(l, blackAndWhite))
        .toList();
    print(aux[0]);
    lines = aux.toList();
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {};

    json['labelWidth'] = labelWidth;
    json['labelHeight'] = labelHeight;
    json['grayLevelMin'] = grayLevel.start;
    json['grayLevelMax'] = grayLevel.end;
    json['logoWidth'] = logoWidth;
    json['logoHeight'] = logoHeight;
    json['logoMode'] = logoMode;

    List<Map<String, dynamic>> jsonLines =
        lines.map((l) => l.toJSON()).toList();
    json['lines'] = jsonLines;

    return json;
  }


  void save(String name) async {

    await Permission.storage.request();

    var dir = await labelPath();
    print(dir);
    var labelName = dir + "/" + name;
    var labelDir = Directory(labelName);

    if (labelDir.existsSync()) {
      labelDir.delete(recursive: true);
    }
    labelDir.create(recursive: true);

    try {
      var labFile = File('$labelName/info.json');
      // Write the file
      var jsonData = JsonEncoder().convert(toJSON());
      print(jsonData);
      await Permission.storage.request();
      await labFile.writeAsString(jsonData);
    } catch (e) {
      print("Error saving data: $e");
    }

    try {
      var grayscaleFile = File('$labelName/grayscale.png');
      var pngData = img.PngEncoder().encodeImage(grayscale);
      await Permission.storage.request();
      grayscaleFile.writeAsBytesSync(pngData, flush: true);
    } catch (e) {
      print("Error saving grayscale: $e");
    }

    try {
      var bAndWFile = File('$labelName/bandw.png');
      var pngData = img.PngEncoder().encodeImage(blackAndWhite);
      await Permission.storage.request();
      bAndWFile.writeAsBytesSync(pngData, flush: true);
    } catch (e) {
      print("Error saving b&w: $e");
    }
  }


  void export(String name) async {
    var dir = await labelPath();
    var labelName = '$dir/$name';
    var zipName = labelName + ".zip";
    print("Zipping $labelName into $zipName");

    // Remove if exists
    try {
      var f = File(zipName);
      await f.delete();
    } catch (e) {}

    try {
      final zipFile = File(zipName);
      final labelDir = Directory(labelName);
      await ZipFile.createFromDirectory(
          sourceDir: labelDir, zipFile: zipFile, recurseSubDirs: true);
      await Share.shareFiles([zipName],
          text: "Label", subject: "Label description");
    } catch (e) {
      print("Error while zipping label : ${e.toString()}");
    }
  }

  Future<void> load(String name) async {
    await Permission.storage.request();
    var dir = await labelPath();
    print(dir);
    var labelName = '$dir/$name';

    try {
      var grayscaleFile = File('$labelName/grayscale.png');
      await Permission.storage.request();
      var pngData = grayscaleFile.readAsBytesSync();
      grayscale = img.decodeImage(pngData);
    } catch (e) {
      print('grayscale  not found');
      grayscale = null;
    }

    try {
      var bAndWFile = File('$labelName/bandw.png');
      await Permission.storage.request();
      var pngData = bAndWFile.readAsBytesSync();
      blackAndWhite = img.decodeImage(pngData);
    } catch (e) {
      print('B & W  not found');
      blackAndWhite = null;
    }

    try {
      var labFile = File('$labelName/info.json');
      await Permission.storage.request();
      String contents = await labFile.readAsString();
      var jsonData = JsonDecoder().convert(contents);
      fromJSON(jsonData);
    } catch (e) {
      print('Error!' + e.toString());
    }
  }

  void clear() {
    for (int i = 0; i < lines.length; i++) {
      lines[i] = LineInfo();
    }
  }

  void setLeftValue(i, v) {
    if (i > 0 &&
        lines[i - 1].type == 0 &&
        lines[i - 1].left.length > 0 &&
        "┏┃┣".contains(lines[i - 1].left[0]) &&
        !"┃┗┣".contains(v.value)) {
      lines[i].setLeft(VariableInfo(v.title, "┃" + v.value));
    } else {
      lines[i].setLeft(v);
    }

    if (v.value.length > 0 &&
        i > 0 &&
        lines[i - 1].left.length > 0 &&
        lines[i - 1].type == 0 &&
        "┏┃┣".contains(lines[i - 1].left[0])) {
      if (lines[i - 1].center.length > 0 &&
          "┳╋┃".contains(lines[i - 1].center[0])) {
        var c = "┃";
        if (v.value[0] == "┗") {
          c = "┻";
        } else if (v.value[0] == "┣") {
          c = "╋";
        }
        lines[i].setCenter(VariableInfo(c, c));
      }
    }
  }

  void setCenterValue(i, v) {
    lines[i].setCenter(v);
  }

  void setRightValue(i, v) {
    if (i > 0 &&
        lines[i - 1].type == 0 &&
        lines[i - 1].right.length > 0 &&
        "┓┃┫".contains(lines[i - 1].right[lines[i - 1].right.length - 1]) &&
        !"┛┫┃".contains(v.value)) {
      lines[i].setRight(VariableInfo(v.title, v.value + "┃"));
    } else {
      lines[i].setRight(v);
    }

    if (v.value.length > 0 &&
        i > 0 &&
        lines[i - 1].type == 0 &&
        lines[i - 1].right.length > 0 &&
        "┓┃┫".contains(lines[i - 1].right[lines[i - 1].right.length - 1])) {
      if (lines[i - 1].center.length > 0 &&
          "┳╋┃".contains(lines[i - 1].center[0])) {
        var c = "┃";
        if (v.value[0] == "┛") {
          c = "┻";
        } else if (v.value[0] == "┫") {
          c = "╋";
        }
        lines[i].setCenter(VariableInfo(c, c));
      }
    }
  }

  void setLogo(int i) {
    var logo = new Image.memory(img.encodePng(blackAndWhite));
    lines[i].setImage(logo, logoWidth, logoHeight);
  }

  void setBarcodeValue(i, v) {
    lines[i].setBarcode(v);
  }

  // Set the image for the logo from the full colour image

  void setImage(img.Image image, int width,
      {PrinterType type: PrinterType.ESC}) {
    if (type == PrinterType.CPCL) {
      grayscale = img.copyResize(image,
          width: width, interpolation: img.Interpolation.cubic);
    } else {
      var scale = width / image.width;
      var height = ((image.height * scale) / 24).floor() * 24;

      grayscale = img.copyResize(image,
          height: height, interpolation: img.Interpolation.cubic);
    }
    img.grayscale(grayscale);

    filter();

    logoWidth = grayscale.width;
    logoHeight = grayscale.height;
  }

  void filterGray() {
    int black = grayLevel.start.floor();
    int white = grayLevel.end.floor();

    var image =
        img.copyCrop(grayscale, 0, 0, grayscale.width, grayscale.height);
    var gen = new Random();

    var valors = white - black;

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        var p = image.getPixel(x, y);

        var g = img.getGreen(p);

        if (g <= black) {
          image.setPixelRgba(x, y, 0, 0, 0);
        } else if (g >= white) {
          image.setPixelRgba(x, y, 0xff, 0xff, 0xff);
        } else {
          var cut = gen.nextInt(valors) + black;
          if (cut <= g) {
            image.setPixelRgba(x, y, 0xff, 0xff, 0xff);
          } else {
            image.setPixelRgba(x, y, 0, 0, 0);
          }
        }
      }
    }

    blackAndWhite = image;
  }

  void filter() {
    int level = grayLevel.start.floor();
    var image =
        img.copyCrop(grayscale, 0, 0, grayscale.width, grayscale.height);

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        var p = image.getPixel(x, y);

        var g = img.getGreen(p);
        if (g < level) {
          image.setPixelRgba(x, y, 0, 0, 0);
        } else {
          image.setPixelRgba(x, y, 0xff, 0xff, 0xff);
        }
      }
    }

    blackAndWhite = image;
  }

  Future<void> printLabel(PrinterProtocol printer, {WeightRecord record, int printerWidth=36}) async {
    // Don't print last white lines
    int maxline = lines.length - 1;

    if (maxline < 0) {
      return;
    }

    while (maxline >= 0 &&
        lines[maxline].type == 0 &&
        lines[maxline].description().trimRight().length == 0) {
      maxline = maxline - 1;
    }

    await printer.startLabel(labelHeight); // Canviar a la mida correcte

    for (int i = 0; i <= maxline; i += 1) {
      var line = lines[i];

      if (line.type == 0) {
        if (line.height.floor() == 1) {
          await printer.setFontSize(1);
        } else if (line.height.floor() > 1) {
          await printer.setFontSize(2);  //line.height.floor());  A Algunes impressores o els hi agrada el 3 o altres coses
          print("Big Letter");
        } else {
          await printer.setFontSize(1);
        }
        if (line.weight == FontWeight.bold) {
          await printer.setBold(1);
        } else {
          await printer.setBold(0);
        }
        await printer.leftLine();
        //print(record.recordAsCSV("|", "\n"));
        //print(line.description(record: record));
        await printer
            .writeString(line.description(record: record, lwidth: printerWidth).trimRight() + "\r\n");
        await printer.setFontSize(1);
      } else if (line.type == 1 && line.barcodeType != 9) {
        await printer.writeBarcode(line.getCenter(record), line.barcodeType);
      } else if (line.type == 1 && line.barcodeType == 9) {
        await printer.writeQRCode(line.getCenter(record));
      } else if (line.type == 2) {
        await printer.setFontSize(1);

        await printer.writeImage(blackAndWhite);
        await printer.writeString("\r\n");
      }
    }
    await printer.endLabel();
  }
}
