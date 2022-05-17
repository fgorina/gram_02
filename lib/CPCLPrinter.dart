import 'dart:math';
import 'PrinterConnectionProtocol.dart';

import 'GraphicsKeyboard.dart';
import 'Log.dart';
import 'package:image/image.dart' as img;
import 'LineInfo.dart';
import 'BlueConnection.dart';

import 'PrinterProtocol.dart';
import 'PrinterConnectionProtocol.dart';
import 'GRAMModel.dart';

class CPCLPrinter implements PrinterProtocol {
  int currentY = 0;
  int xOffset = 0;
  int lineHeight = 24;
  int fontSize = 1;

  PrinterConnectionProtocol connection;
  GRAMModel model = GRAMModel.shared;

  CPCLPrinter(PrinterConnectionProtocol aconnection){
    this.connection = aconnection;
  }

  PrinterType printerType(){
    return PrinterType.CPCL;
  }

  Future<void> connect(String name, Function(String) callback, {int speed = 9600}) async {

    return await connection.scanPrinter(name, callback, speed);
  }

  String state() {
    return connection.printerState;
  }

  Future<void> startLabel(int height) async  {
    currentY = 0;
    xOffset = 0;
    try {
      var st = "! $xOffset 200 200 $height 1\r\n";
      print(st);
      return await connection.write(st.codeUnits, model.serialPrinterSpeed); // Show Text
    } catch (e) {
      Log.shared
          .error("Printer.scanPrinter", "Error when printing barcode", [e]);
    }
  }

  Future<void> endLabel() async{
    currentY = 0;
    xOffset = 0;
    try {
      print("FORM\r\n");
      await connection.write("FORM\r\n".codeUnits, model.serialPrinterSpeed); // Show Text
      print("PRINT\r\n");
      await connection.write("PRINT\r\n".codeUnits, model.serialPrinterSpeed);
      if(connection.autoClose()) {
        connection.close();
      }

    } catch (e) {
      Log.shared
          .error("Printer.scanPrinter", "Error when printing barcode", [e]);
    }
  }

  Future<void> writeBarcode(String s, int type) async {
    // Set the width of barcode
    try {
      await connection.write("CENTER\r\n".codeUnits, model.serialPrinterSpeed);
      await connection.write("BARCODE-TEXT 8 0 5\r\n".codeUnits, model.serialPrinterSpeed); // Show Text
      var st =
          "BARCODE ${LineInfo.barcodeCPCL[type]} 2 3 96 0  $currentY ${s.toUpperCase()}\r\n";
      print("Barcode" + st);
      currentY = currentY + 96;
      await connection.write(st.codeUnits, model.serialPrinterSpeed); // Digits below
      await connection.write("BARCODE-TEXT OFF\r\n".codeUnits, model.serialPrinterSpeed); // Show Text
      return await connection.write("LEFT\r\n".codeUnits, model.serialPrinterSpeed);


    } catch (e) {
      Log.shared
          .error("Printer.scanPrinter", "Error when printing barcode", [e]);
    }
  }

  Future<void> writeQRCode(String s) async{
    // Store the data in the symbol storage area

    await connection.write("CENTER\r\n".codeUnits, model.serialPrinterSpeed);
    await connection.write("BARCODE QR 0 $currentY M 2 U 5\r\n".codeUnits, model.serialPrinterSpeed);
    print("BARCODE QR 0 $currentY M 2 U 5\r\n");
    await connection.write(("MA," + s).codeUnits + [13, 10], model.serialPrinterSpeed);
    print(("MA," + s + "\r\n"));
    await connection.write("ENDQR\r\n".codeUnits, model.serialPrinterSpeed);
    print("ENDQR\r\n");
    return await connection.write("LEFT\r\n".codeUnits, model.serialPrinterSpeed);
  }

  Future<void> writeString(String s) async{
    try {
      // First remove white strings ans substitute for  12 pixels * size

      if (s.trim().length == 0) {
        currentY = currentY + lineHeight;
        return;
      }
      int blanks = 0;
      while (s[blanks] == " ") {
        blanks++;
      }

      int xpos = xOffset + blanks * 12 * max(fontSize, 1);

      var converted = s;
      GraphicsKeyboard.graphicsUnicode.keys.forEach((element) {
        converted = converted.replaceAll(element,
            String.fromCharCode(GraphicsKeyboard.graphicsUnicode[element]));
      });

      //await printCharacteristic.write("ENCODING ASCII\r\n".codeUnits);
      var sy = "TEXT 8 0 $xpos $currentY $converted\r\n";
      print(sy);
      currentY = currentY + lineHeight;
      return await connection.write(sy.codeUnits, model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("Printer.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> setEncoding(int i) async{
    try {
      var encodings = ["ASCII", "UTF-8"];
      print("ENCODING ${encodings[i]}\r\n");
      return await connection.write("ENCODING ${encodings[i]}\r\n".codeUnits, model.serialPrinterSpeed);
    } catch (e) {
      Log.shared.error("Printer.scanPrinter", "Error when printing", [e]);
    }
  }

  Future<void> writeImage(img.Image image) async{
    //await writeString("Hello World\n");

    print("Image width : ${image.width} height: ${image.height}");

    List<int> data = [];
    int item = 0;

    String line = "";

    for (int i = 0; i < image.height; i++) {
      line = "";
      for (int j = 0; j < ((image.width) / 8).floor() * 8; j++) {
        int bit = j % 8;

        int pixel = 0;
        if (j < image.width) {
          pixel = img.getRed(image.getPixel(j, i)) & 0x01;
          pixel = pixel == 1 ? 0 : 1;
        }

        if (pixel == 1) {
          line = line + "·";
        } else if (pixel != 0) {
          line = line + "x";
        } else {
          line = line + " ";
        }

        item = ((item * 2) & 0xff) + pixel;

        if (bit == 7) {
          data.add(item);
          item = 0;
        }
      }
      //print("Line: $line");
    }

    var left = ((576 - image.width) / 2).floor();
    var w = (image.width / 8).floor();
    var h = image.height.floor();

    //print("Width ${image.width}, Height : ${image.height}, bytes: ${(image.height * image.width)/8}");

    var header = "CG $w $h $left $currentY ";
    print(header + "\r\n");

    List<int> buffer = header.codeUnits + data +[13, 10];
    print("Data size: ${buffer.length}");

    var chunkSize = 512;
    try {
      await connection.write(buffer, model.serialPrinterSpeed, chunkSize: chunkSize);

    } catch (e) {
      Log.shared.error("Printer.writeImage", "Error in  write Image", [e]);
    }

    currentY = currentY + image.height;
    // await nextPage();


  }

  Future<void> setFontSize(int size) async {
    var s = max(size, 1);
    lineHeight = s * 24;
    fontSize = size;

    print("SETMAG $s $s\r\n");
    return await connection.write("SETMAG $s $s\r\n".codeUnits, model.serialPrinterSpeed);
   }

  Future<void> setCharacterLineSpacing(int size) async {
    var s = max(size, 1);
    lineHeight = s;
  }

  Future<void> setBold(int on) async{   // 3 ho fa similar a la HM300
    print("SETBOLD ${on*3}\r\n");
    return await connection.write("SETBOLD ${on*3}\r\n".codeUnits, model.serialPrinterSpeed);

    //await printCharacteristic.write([27, 69, on]);
  }

  Future<void> centerLine() async{
    return;

    // await printCharacteristic.write([27, 97, 1]);
  }

  Future<void> leftLine() async{
    return;

    //await printCharacteristic.write([27, 97, 0]);
  }

  Future<void> rightLine() async{
    return;

    //await printCharacteristic.write([27, 97, 2]);
  }

  Future<void> nextPage() async{
    await endLabel();
    return await startLabel(1000);
  }

  Future<void> clearData() async{
    return; // await printCharacteristic.write([27, 64]);
  }

  Future<void> doPrint() async{
    startLabel(560);

    List<int> txt = [];
    for (int i = 48; i < 256; i++) {
      txt.add(i);

      if (i % 16 == 15) {
        var sy = "TEXT 8 0 0 $currentY ";
        var buffer = sy.codeUnits + txt + [13, 10];
        print(buffer);
        await connection.write(buffer, model.serialPrinterSpeed);
        currentY += lineHeight;
        txt = [];
      }
    }
    endLabel();
  }
}
