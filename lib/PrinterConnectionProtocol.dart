

abstract class PrinterConnectionProtocol {
  String printerState;


  Future<void> scanPrinter(String name, Function(String) callback, int speed)  ;
  Future<dynamic> write(List<int> data,  int speed , {int chunkSize : 0}) ;
  String name();
  bool  autoClose();
  void close();

}