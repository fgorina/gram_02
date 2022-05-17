import 'package:intl/intl.dart' as intl;
import 'package:sprintf/sprintf.dart';
import 'package:flutter/material.dart';

// In Swift they are extensions. here redone as functions


// Date Formatting

var dateFormat = intl.DateFormat("dd/MM/yy");
var timeFormat = intl.DateFormat("HH:mm:ss");
var shortTimeFormat = intl.DateFormat("HH:mm");
String locale = "en_US";


String dateString(date){
  return dateFormat.format(date);
}

timeString(date){
  return timeFormat.format(date);
}

shortTimeString(date){
  return shortTimeFormat.format(date);
}

// Double Formatting

String doubleFormatted(d){
  return sprintf("%10.1f", [d]);
}

String formatted(double d, String f){
  return sprintf(f, d);
}

String formattedDecs(double d, int decs, {separator: true}){

  var format = intl.NumberFormat.decimalPattern(locale);
  format.minimumFractionDigits = decs;
  format.maximumFractionDigits = decs;
  if (!separator) {
    format.turnOffGrouping();
  }
  var ff = format.format(d);
  return ff;
}

String justifyRight(String s, int len, String sep){
  if (len < 0){
    return "";
  }
  if (s.length > len){
    return s.substring(0, len);
  }else {
    var s1 = s;

    while(s1.length < len){
      s1 = s1 + sep;
    }

    return s1;
  }


}

String justifyLeft(String s, int len, String sep) {
  if (len < 0){
    return "";
  }
  if (s.length > len) {
    return s.substring(0, len);
  } else {
    var s1 = s;

    while (s1.length < len) {
      s1 = sep + s1;
    }

    return s1;
  }
}
String justifyCenter(String s, int len, String sep){

  if (s.length > len){
    return s.substring(0, len);
  }else {
    var s1 = s;

    while(s1.length < len){
      s1 = sep +  s1 + sep;
    }

    return s1.substring(0, len);
  }


}


Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}