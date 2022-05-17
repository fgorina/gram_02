import 'DataTypesUtilities.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'Units.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode/barcode.dart';


class Measurement {

  double value;
  Unit unit;

  Measurement(value, unit){
    this.value = value;
    this.unit = unit;
  }

  Measurement.fromJson(Map<String, dynamic> json){
    value = json['value'];
    int code = json['unit'];
    Unit u = unitsCodes[code];
    unit = u;

  }

  Map<String, dynamic> toJson(){
    return {
      'value': value,
      'unit': units[unit].code,
    };

  }

  Map<String, dynamic> toJsonT(){
    return {
      'value': value,
      'unit': units[unit].symbol,
    };

  }


  convertedTo(unit){

    if (this.unit == unit){
      return this;
    } else {
      return Measurement(
          this.value * units[this.unit].value / units[unit].value, unit);
    }

  }

  String formatted(int decs){
    //var format = "%1.${decs}f %s";
    //var str =  sprintf(format, [value, units[unit].symbol]);

    var format = NumberFormat.decimalPattern();
    format.minimumFractionDigits = decs;
    format.maximumFractionDigits = decs;

    var u = units[unit];
    var s = "x";
    if (u != null){
      s = units[unit].symbol;
    }

    String f = formattedDecs(value, decs) + " " + s;
    return f;
  }

  String valueFormatted(int decs, {bool grouping: true}){

    return formattedDecs(value, decs, separator: grouping);

  }
  String valueBeginFormatted(int decs, {bool grouping: true}){

    String s = valueFormatted(decs, grouping: grouping);
    return s.substring(0, s.length-1);

  }
  String valueRestFormatted(int decs, {bool grouping: true}){

    String s = valueFormatted(decs, grouping: grouping);
    return s.substring(s.length-1, s.length);

  }

  String symbol(){
    var u = units[unit];

    if (u != null) {
      return units[unit].symbol;
    }else{
      return "x";
    }
  }

  Widget qrcode(int decs, {double size: 200.0, Color bgColor: Colors.white , bool withUnits: false}){

    return BarcodeWidget(
        barcode: Barcode.qrCode(),
        data: withUnits ? valueFormatted(decs, grouping: false).replaceAll(",", ".")  + " " + units[unit].symbol  : valueFormatted(decs, grouping: false).replaceAll(",", "."),
        width: size,
       height: size,
       backgroundColor: bgColor,
    );

  }



  Measurement operator +(Measurement other){

    var converted = other.convertedTo(this.unit);

    return Measurement(this.value + converted.value, this.unit);

  }

  Measurement operator -(Measurement other){

    var converted = other.convertedTo(this.unit);

    return Measurement(this.value - converted.value, this.unit);

  }

  bool operator >(Measurement other){

    var converted = other.convertedTo(this.unit);

    return this.value > converted.value;

  }
  bool operator <(Measurement other){

    var converted = other.convertedTo(this.unit);
    return this.value <  converted.value;

  }


}