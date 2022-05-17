
import 'Units.dart';
import 'Measurement.dart';
import 'dart:io';
import 'dart:convert';
import 'LocalFileSystemUtilities.dart';
import 'Log.dart';


class TareRecord {

  var name = "";
  var tare = Measurement(0.0, Unit.grams);

  TareRecord(name, measurement){
    this.name = name;
    this.tare = measurement;
  }


  TareRecord.fromJson(Map<String, dynamic> json){
    name = json['name'];
    tare = Measurement.fromJson(json['tare']);
  }

  Map<String, dynamic> toJson() {
    return{
      'name' : name,
      'tare' : tare.toJson(),
    };
  }

}


class TareDatabase {

  static final TareDatabase shared = TareDatabase._constructor();
  static final filename = "tares.json";

  Map<String, TareRecord> _tareArray = {};

  TareDatabase._constructor() {

    loadRecords();
   }


  void add(String name, Measurement tare){
    _tareArray[name] = TareRecord(name, tare);
    doSaveRecords();
  }

  TareRecord tareForName(String name){
    return _tareArray[name];
  }

  List<String> tareNames(){
    return _tareArray.keys.toList();
  }

  void deleteTare(String name){
    _tareArray.remove(name);
    doSaveRecords();
  }

  toJson(){
    List jsonList = [];
    _tareArray.keys.map((key) => jsonList.add(_tareArray[key].toJson())).toList();
    return jsonList;
  }

  void decodeRecordedScales(List<dynamic> jsonList){
    _tareArray = {};

    jsonList.forEach( (item){
      var sc = TareRecord.fromJson(item);
      _tareArray[sc.name] = sc;
    });

    print("Done decoding tares");


  }



  void doSaveRecords(){
     _saveRecords();
  }

  Future<File> _saveRecords() async {
    var dir = await localPath();
    var path = dir+"/"+TareDatabase.filename;
    var file = File(path);

    var jsonData = JsonEncoder().convert(toJson());

    try {
      var afile = await file.writeAsString(jsonData);
      return afile;
    }catch (e) {
      Log.shared.error("TareRecord Saving Tares", e.toString());
      return  null;
    }

  }

  Future<void> loadRecords() async{
    var dir = await localPath();
    var path = dir+"/"+TareDatabase.filename;
    var file = File(path);

    try {
      var jsonData = await file.readAsString();

      if (jsonData != "Error!") {
        var jsonList = JsonDecoder().convert(jsonData);
        decodeRecordedScales(jsonList);
      }
    }catch(e) {
      Log.shared.error("TareRecord Loading tares", e.toString());
    }
  }

}