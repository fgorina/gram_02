import "dart:io";
import 'dart:core';

import 'package:csv/csv_settings_autodetection.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'LocalFileSystemUtilities.dart';
import 'package:permission_handler/permission_handler.dart';
import "Log.dart";

class CSVDatabase {
  Uri url;
  List<List<dynamic>> rows = [];

  CSVDatabase(String url)  {

    if(url != null && url != "") {
      this.url = Uri.parse(url);

      if(this.url != null) {
        loadData();
      }
    }
  }

  void loadData()  async{
    if (url != null ) {
      await load();
      await refresh();
    }
  }

  Future<void> refresh() async {

    Log.shared.info("CSVDatatabase refresh", "Refreshing ${this.url}");

    try {
      String bodyData;

      if(url.scheme != "file"){
        var response = await http.get(url);
        bodyData = response.body;

      }else {
        await Permission.storage.request();
        var file = File(url.path);
        bodyData = file.readAsStringSync();

      }

      fromString(bodyData);
      await save(); // Save the data in local file

    }catch(e){
      Log.shared.error("CSVDatatabase refresh error", e.toString());
    }
  }

  void fromString(String data) {
    var d = FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'],
        textDelimiters: ['"', "'"],
        fieldDelimiters: [';', ',', '\t']);

    rows = CsvToListConverter(shouldParseNumbers: false, csvSettingsDetector: d)
        .convert(data);
  }

  String toString() {
    return ListToCsvConverter(delimitAllFields: true).convert(this.rows);
  }

  Future<void> save() async {
    var dir = await localPath();
    var path = dir + "/" + this.url.pathSegments.last;
    var file = File(path);

    String data = toString();

    try {
      file.writeAsStringSync(data);
    }catch(e){
      Log.shared.trace("CSVDatatabase ${url.toString()} save error", e.toString());
    }
  }

  Future<void> load() async {
    if (url != null && url.pathSegments.length > 0) {
      var dir = await localPath();
      var path = dir + "/" + this.url.pathSegments.last;
      var file = File(path);
      print(path);

      try {
        var data = file.readAsStringSync();
        fromString(data);

      } catch (e) {
        Log.shared.trace("CSVDatatabase  ${url.toString()} load error", e.toString());
      }
    }
  }

  String name() {
    if (this.url.pathSegments != null && this.url.pathSegments.length > 0) {
      return this.url.pathSegments.last.replaceAll(".csv", "").toUpperCase();
    }else{
      return "<>";
    }
  }

  void add(element){
    // Only add if exists

    if (!contains(element[1])){

      rows.add(element);
      sort();
      save();
    }

  }

  bool contains(text){
    int index = rows.indexWhere((item) => item[1].compareTo(text) == 0);
    return  (index >= 0);
  }

  List<dynamic> find(pat){

    int index = rows.indexWhere((item) => item[1].compareTo(pat) == 0);

    if(index >= 0){
      return rows[index];
    } else {
      return null;
    }
  }

  List<dynamic> findByCode(pat){

    int index = rows.indexWhere((item) => item[0].compareTo(pat));

    if(index >= 0){
      return rows[index];
    } else {
      return null;
    }
  }

  void sort(){
    rows.sort((a, b) => a[1].compareTo(b[1]) );
  }

  void doPrint() {
    print(rows);
  }

  int count() {
    return rows.length;
  }

  List<dynamic> getRow(int row) {
    return rows[row];
  }

  dynamic getValue(int row, int col) {
    return rows[row][col];
  }
}
