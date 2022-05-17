import 'package:flutter/services.dart';
import 'dart:io';
import 'GRAMModel.dart';

class Translation {
  Map<String, String> _map = {};
  String locale;
  bool debug = true;
  bool loaded = false;


  Translation({String locale}) {
    _init(locale: locale);
  }

  void _init({String locale}) async {
    String myLocale;

    if (locale == null ){
      loaded = true;
      GRAMModel.shared.didReceiveData();
    }else {
      myLocale = locale.substring(0, 2);

      //Change from ISO 639m to ISO 3166
      if(myLocale == "in"){
        myLocale = "id";
      }
      this.locale = myLocale;
      String filename = myLocale + "_localizable.strings";
      _map = await _loadAsset(filename);
      loaded = true;
      GRAMModel.shared.didReceiveData();
    }

  }

  String localize(String term){
    var outTerm = _map[term];

    if (outTerm == null){
      if (debug) {
        return term.toUpperCase();
      } else {
        return term;
      }
    } else {
      return outTerm;
    }
  }

  Future<Map<String, String>> _loadAsset(String name) async {
    try {
      String s = await rootBundle.loadString('assets/' + name);
      return _parse(s);
    } catch (error){
      print(error);
      return {};
    }
  }

  Future<void> _load(String path) async {
    var file = File(path);
    try {
      String contents = await file.readAsString();
      _parse(contents);

      // Returning the contents of the file
    } catch (e) {
      // If encountering an error, return

    }
  }

  Map<String, String> _parse(String s) {
    Map<String, String> out = {};

    List<String> lines = s.split("\n");

    for (String line in lines) {
      String cleanLine = line.trim();

      if (cleanLine.startsWith('"')) {
        RegExp exp = new RegExp(r'"(.*)" *= *"(.*)";');
        Match m = exp.firstMatch(line);
        if (m != null && m.groupCount == 2) {
          String s1 = m.group(1);
          String s2 = m.group(2);
          print("$s1 => $s2");
          out[s1] = s2;
        }
      }
    }
    print(out);
    return out;
  }
}
