import 'dart:io';
import 'dart:convert';
import 'LocalFileSystemUtilities.dart';
import "Scale.dart";
import 'GRAMModel.dart';

class ScaleDatabase {

  static final ScaleDatabase shared = ScaleDatabase._constructor();
  static final filename = "scales.json";

  Map<String, Scale> _scaleArray = {};

  ScaleDatabase._constructor() {
    print("Scale Database Constructor");

  }

  void initDatabase(){
    loadRecords();
    if( _scaleArray.length == 0) {

      if (deviceType == DeviceType.terminal){
        print("Afegint bascula a la base de dades per terminal");
        _scaleArray["ttyS3"] = Scale(name: "ttyS3", ssid: "/dev/ttyS3",
            passphrase: "",
            ipAddress : "",
            port : 115200,
            networkName : "tty",
            networkPassword : "",
            networkPort : 4445);
      }else {
        print("Afegint  bascula a la base de dades per phone");

        _scaleArray["Config"] = Scale(name: "Config", ssid: "GRAM_01",
            passphrase: "12345678",
            ipAddress : "192.168.4.1",
            port : 4444,
            networkName : "new",
            networkPassword : "new",
            networkPort : 4445);

      }

    }
  }

  Scale first() {
    if (_scaleArray.isNotEmpty){
      var k = _scaleArray.keys.first;
      return _scaleArray[k];
    }else{
      return null;
    }
  }

  void add(Scale scale){
    _scaleArray[scale.name] = scale;
    doSaveRecords();
  }

  Scale scaleForName(String name){
     return _scaleArray[name];
  }

  List<String> scaleNames(){
    List<String> l = _scaleArray.keys.toList();
    l.sort((x, y) => x.compareTo(y));

    return l;
  }

  void deleteScale(String name){
    _scaleArray.remove(name);
    doSaveRecords();
  }

  toJson(){
    List jsonList = [];
    _scaleArray.keys.map((key) => jsonList.add(_scaleArray[key].toJson())).toList();
    return jsonList;
  }

  void decodeRecordedScales(List<dynamic> jsonList){
    _scaleArray = {};

    jsonList.forEach( (item){
      var sc = Scale.fromJson(item);
      _scaleArray[sc.name] = sc;
    });

    print("Done");


  }

  void doSaveRecords(){
    _saveRecords();
  }

  Future<File> _saveRecords() async {
    var dir = await localPath();
    var path = dir+"/"+ScaleDatabase.filename;
    var file = File(path);

    var jsonData = JsonEncoder().convert(toJson());

    try {
      var afile = await file.writeAsString(jsonData);
      return afile;
    }catch (e) {
      print("Error: $e");
      return  null;
    }

  }

  Future<void> loadRecords() async {
    var dir = await localPath();
    var path = dir + "/" + ScaleDatabase.filename;
    var file = File(path);

    if (file.existsSync()) {
        try {
          var jsonData = await file.readAsString();

          if (jsonData != "Error!") {
            var jsonList = JsonDecoder().convert(jsonData);
            decodeRecordedScales(jsonList);
          }
        }
      catch ( e){
        print("Error al obrir el fitxer ${path} : ${e.toString()}");
      }

    }else {
      print("Base de dades de bàscules NO trobada");

    }
  }

}
