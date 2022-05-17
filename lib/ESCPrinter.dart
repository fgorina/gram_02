import 'GraphicsKeyboard.dart';
import 'Log.dart';
import 'package:image/image.dart' as img;

import 'PrinterProtocol.dart';
import 'PrinterConnectionProtocol.dart';
import 'GRAMModel.dart';

class ESCPrinter implements PrinterProtocol {
  PrinterConnectionProtocol connection ;
  GRAMModel model = GRAMModel.shared;

  ESCPrinter(PrinterConnectionProtocol aconnection){
    this.connection = aconnection;
  }

  PrinterType printerType(){
    return PrinterType.ESC;
  }


  Future<void> connect(String name, Function(String) callback) async {
    await connection.scanPrinter(name, callback, model.serialPrinterSpeed);
  }

  String state() {
    return connection.printerState;
  }

  Future<void> writeBarcode(String s, int type) async {
    // Set the width of barcode

    await centerLine();
    await connection.write([29, 72, 2], model.serialPrinterSpeed); // Digits below
    await connection.write([29, 119, 3], model.serialPrinterSpeed); // Width

    List<int> bytes = [];
    bytes.addAll([29, 107, type + 65, s.length]);
    bytes.addAll(s.toUpperCase().codeUnits);

    try {
      await connection.write(bytes, model.serialPrinterSpeed);
    } catch (e) {
      Log.shared
          .error("ESCPrinter.scanPrinter", "Error when printing barcode", [e]);
    }
    await leftLine();
    return await setFontSize(1);
  }

  Future<void> writeQRCode(String s) async {
    // Store the data in the symbol storage area
    await centerLine();
    await setFontSize(1);
    await connection.write([10], model.serialPrinterSpeed);
    List<int> header = [
      29,
      40,
      107,
      (s.length + 3) % 256,
      ((s.length + 3) / 256).floor(),
      49,
      80,
      48
    ];
    List<int> buffer = header + s.codeUnits;
    await connection.write(buffer, model.serialPrinterSpeed); // Store data in symbol storage area

    await connection.write(
        [29, 40, 107, 3, 0, 49, 81, 48], model.serialPrinterSpeed); // print data in symbol storage area
    return await leftLine();
  }

  Future<void> writeString(String s, {chunksize = 20}) async {
    try {
      var converted = s;
      GraphicsKeyboard.graphicsUnicode.keys.forEach((element) {
        converted = converted.replaceAll(element,
            String.fromCharCode(GraphicsKeyboard.graphicsUnicode[element]));
      });

      return await connection.write((converted).codeUnits, model.serialPrinterSpeed, chunkSize: chunksize);
    } catch (e) {
      Log.shared.error("ESCPrinter.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setPageMode() async {
    try {
      return await connection.write([27, 76], model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("ESCPrinter.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setStandardMode() async {
    try {
      return await connection.write([27, 83], model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("ESCPrinter.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setEncoding(int encoding) async {
    try {
      return await connection.write([27, 116, encoding], model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("ESCPrinter.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setPrintArea(width, height) async {
    return await connection.write([27, 87, 0, 0, 0, 0, 1, 0, 1], model.serialPrinterSpeed);
  }

  Future<void> setAbsolutePrintPosition(int pixels) async {
    return await connection.write([27, 36, (pixels % 256), (pixels / 256).floor()], model.serialPrinterSpeed);
  }

  Future<void> writeImage(img.Image image) async {
    //await writeString("Hello World\n");

    await clearData();
    //await setPageMode();
    // await setStandardMode();
    //await setFontSize(1);
    await setCharacterLineSpacing(24);
    //await writeString("\n");

    //setPrintArea(256, 256);
    var left = ((576 - image.width) / 2).floor();

    // De moment fem blocs de 24 pixels en vertical

    var lines = [];
    int res = 3; // Pot ser 1 o 3
    lines = [];
    //print("Image Height ${image.height}");

    List<int> aline = [];

    for (int yline = 0;
        yline < (image.height - (8 * res) + 1);
        yline = yline + (8 * res)) {
      //print("Computing line $yline");

      aline = [];

      for (int x = 0; x < image.width; x += 1) {
        int item = 0;
        for (int j = 0; j < 8; j++) {
          var pixel = img.getRed(image.getPixel(x, (yline + j))) & 0x01;
          pixel = pixel == 1 ? 0 : 1;
          item = (item * 2) + pixel;
        }
        aline.add(item);
        item = 0;

        if (res == 3) {
          for (int j = 0; j < 8; j++) {
            var pixel = img.getRed(image.getPixel(x, yline + 8 + j)) & 0x01;
            pixel = pixel == 1 ? 0 : 1;
            item = (item * 2) + pixel;
          }
          aline.add(item);
          item = 0;

          for (int j = 0; j < 8; j++) {
            var pixel = img.getRed(image.getPixel(x, yline + 16 + j)) & 0x01;
            pixel = pixel == 1 ? 0 : 1;
            item = (item * 2) + pixel;
          }
          aline.add(item);
        }
      }
      lines.add(aline);
    }

    var w = (image.width / 1).floor();
    print("Width $w");
    print("Height $image.height");

    // List<int> header = [29, 118, 48, 48, (w % 256).toInt(), (w / 256).floor(), (image.height % 256).toInt(), (image.height / 256).floor() ];
    // List<int> header = [29, 118, 48, 3, 0, 24, 0 ];
    List<int> header = [
      27,
      42,
      res == 1 ? 0 : 33,
      (w % 256).toInt(),
      (w / 256).floor()
    ];

    for (int j = 0; j < lines.length; j += 1) {
      print("Printing line $j");
      List<int> l = lines[j];
      List<int> buffer = header + l + [10];
      await setAbsolutePrintPosition(left);
      var d = 0;
      try {
        await connection.write(buffer, model.serialPrinterSpeed, chunkSize: d);
      } catch (e) {
        Log.shared.error("ESCPrinter.writeImage", "Error in  write Image", [e]);
      }
    } // End for

    // await nextPage();

    await setCharacterLineSpacing(24);
    return await setAbsolutePrintPosition(0);
  }

  Future<void> setFontSize(int size) async{
     int s = size - 1;
     s = (s * 16) + s;


     return await connection.write([29, 33, s], model.serialPrinterSpeed);
  }

  Future<void> setCharacterLineSpacing(int size) async{
    return await connection.write([27, 51, size], model.serialPrinterSpeed);
  }

  Future<void> setBold(int on) async{
    return await connection.write([27, 69, on], model.serialPrinterSpeed);
  }

  Future<void> centerLine() async{
    return await connection.write([27, 97, 1], model.serialPrinterSpeed);
  }

  Future<void> leftLine() async{
    return await  connection.write([27, 97, 0], model.serialPrinterSpeed);
  }

  Future<void> rightLine() async{
    return await connection.write([27, 97, 2], model.serialPrinterSpeed);
  }

  Future<void> startLabel(int height) async{
    await setCharacterLineSpacing(24);
    await connection.write([27, 77, 0], model.serialPrinterSpeed);
    return await setFontSize(1);

  }

  Future<void> endLabel() async{
    try {
      print("EOF");

      await connection.write([0x0d, 0x0a, 0x0c], model.serialPrinterSpeed);
      if(connection.autoClose()) {
        connection.close();
      }
     } catch (e) {
      Log.shared.error("ESCPrinter.nextPage", "Error in  next page", [e]);
    }
  }

  Future<void> clearData() async {
    try {
      return await connection.write([27, 64], model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("ESCPrinter.clearData", "Error in  clearData", [e]);
    }
  }

  Future<void> doPrint() async {
    return await writeString("My printing String");
  }
}
