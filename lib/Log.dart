import 'package:flutter/material.dart';

enum LogNivell { error, warning, info, trace }

class LogEntry {

  final LogNivell level;
  final DateTime date;
  final String from;
  final String title;
  final List<dynamic> data;

  String get contents => title + "\n" + data.map((e) => e.toString()).join("\n");

  String get description => "$level : $date @ $from : " + contents;

  String get datajson => data.map((e) => ("\"" + e.toString()) + "\"").join(", \n");

  String get json => "{\"level\": \"$level\", \"date\": \"$date\", \"from\": \"$from\", \"title\": \"$title\", \"data\": [ $datajson ]}";

  Color get color {
    switch (level) {
      case LogNivell.error:
        return (Colors.red);
        break;

      case LogNivell.warning:
        return Colors.orange;
        break;

      case LogNivell.info:
        return Colors.cyan;
        break;

      case LogNivell.trace:
        return Colors.lightGreen;
        break;
    }

    return Colors.white;
  }

  LogEntry(this.level, this.date, this.from, this.title, this.data);

  String toString() {
    return description;
  }
}

class Log {
  static final Log shared = Log._constructor();

  final maxLogs = 1000;
  var debugPrint = true;
  var selectedLevels = {
    LogNivell.error: true,
    LogNivell.warning: true,
    LogNivell.info: true,
    LogNivell.trace: false
  };

  List<LogEntry> logArray = [];
  List<LogEntry> selectedArray = [];

  Log._constructor();

  int count() => logArray.length;

  int selectedCount() => selectedArray.length;

  LogEntry getLog(int i) {
    if (i < 0 || i >= count()) {
      return null;
    } else {
      return logArray[i];
    }
  }

  LogEntry getSelectedLog(int i) {
    var n = selectedCount();
    if (i >= 0 && i < n) {
      return selectedArray[i];
    } else {
      print("Error a getSelectedLog $i is not between 0 and $n");
      return null;
    }
  }

  addLog(LogNivell level, String from, String title,
      [List<dynamic> data = const []]) {
    if (maxLogs > 0) {

      while (logArray.length >= maxLogs - 1) {
        logArray.removeLast();
        //logArray.removeAt(0);
      }
    }

    var entry = LogEntry(level, DateTime.now(), from, title, data);
    logArray.insert(0, entry);
    //logArray.add(entry);

    if (selectedLevels[level]) {
      //selectedArray.add(entry);
      if (debugPrint) {
        print(entry.description);
      }
    }
  }

  updateSelected() {
    selectedArray = [];

    logArray.asMap().forEach((i, v) {
      if (selectedLevels[v.level]) {
        selectedArray.add(v);
      }
    });
  }

  error(String from, String title, [dynamic error = const []]) {
    addLog(LogNivell.error, from, title, error);
  }

  warning(String from, String title, [dynamic error = const []]) {
    addLog(LogNivell.warning, from, title, error);
  }

  info(String from, String title, [dynamic data = const []]) {
    addLog(LogNivell.info, from, title, data);
  }

  trace(String from, String title, [dynamic data = const []]) {
    addLog(LogNivell.trace, from, title, data);
  }

  clearLog() {
    logArray = [];
    selectedArray = [];
  }

  select(LogNivell level) {
    selectedLevels[level] = true;
    updateSelected();
  }

  unSelect(LogNivell level) {
    selectedLevels[level] = false;
    updateSelected();
  }

  toggle(LogNivell level) {
    selectedLevels[level] = !selectedLevels[level];
    updateSelected();
  }

  bool isSelected(LogNivell level) {
    return selectedLevels[level];
  }

  String exportFormat(){

  String textLog = "[";
  bool first = true;

  selectedArray.forEach(
    (LogEntry entry)

    {
      if(!first){
        textLog += ", \n";
       }
      textLog += entry.json;
      first = false;
    }
  );
  textLog += "]";
  return textLog;
}



}
