import 'PrinterConnectionProtocol.dart';
import 'package:image/image.dart' as img;



enum PrinterType {
  ESC,
  CPCL
}

abstract class PrinterProtocol{

  PrinterConnectionProtocol connection;

  Future<void> connect(String name, Function(String) callback) ;

  Future<void> startLabel(int height);
  Future<void> endLabel();
  Future<void> writeString(String s) ;
  Future<void> writeBarcode(String s, int type) ;
  Future<void> writeQRCode(String s) ;
  Future<void> writeImage(img.Image image) ;
  Future<void> setCharacterLineSpacing(int size) ;
  Future<void> setFontSize(int size);
  Future<void> setBold(int on);
  Future<void> centerLine();
  Future<void> leftLine();
  Future<void> rightLine();
  Future<void> doPrint();
  String state();
  PrinterType printerType();
}