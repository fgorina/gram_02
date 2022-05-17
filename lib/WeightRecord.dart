

import 'GRAMModel.dart';

import 'Measurement.dart';
import 'Units.dart';
import 'DataTypesUtilities.dart';
import 'GRAMModel.dart';

/*
enum DisplayFields {
  user,
  userCode,
  customer,
  customerCode,
  number,
  date,
  time,
  item,
  netWeight,
  tare,
  grossWeight,
  code,
  codeCode,
  codeBarcode
}

*/

class WeightRecord  {

  static Map names = {
    '%user%': DisplayFields.user,
    '%userCode%': DisplayFields.userCode,
    '%customer%' : DisplayFields.customer,
    '%customerCode%' : DisplayFields.customerCode,
    '%number%' : DisplayFields.number,
    '%data%' : DisplayFields.date,
    '%time%' : DisplayFields.time,
    '%item%' : DisplayFields.item,
    '%weight%' : DisplayFields.netWeight,
    '%tare%' : DisplayFields.tare,
    '%gross%' : DisplayFields.grossWeight,
    '%product%' :  DisplayFields.code,
    '%productCode%' :  DisplayFields.codeCode,
    '%productBarcode%' :  DisplayFields.codeBarcode,
    '%weigh#%' : DisplayFields.netWeightNumber,
    '%gros#%' : DisplayFields.grossWeightNumber,


  };


  var serialNumber = "";
  var scale = "";
  var  user = "";
  var userCode = "";
  var  customer = "";
  var customerCode = "";
  int  number ;
  DateTime when;
  var code = "";
  var codeCode = "";
  var codeBarcode = "";
  Measurement grossWeight;
  Measurement tare;
  int decimals;
  Measurement get netWeight => grossWeight - tare;

  set netWeight(Measurement netWeight) {

  }


  WeightRecord(sn, scale, user, userCode, customer, customerCode, number, when, code, codeCode, codeBarcode, grossWeight, tare, decimals){
    this.serialNumber = sn;
    this.scale = scale;
    this.user = user;
    this.userCode = userCode;
    this.customer = customer;
    this.customerCode = customerCode;
    this.number = number;
    this.when = when;
    this.code = code;
    this.codeCode = codeCode;
    this.codeBarcode = codeBarcode;
    this.grossWeight = grossWeight;
    this.tare = tare;
    this.decimals = decimals;
  }

  WeightRecord.fromJson(Map<String, dynamic> json){
    serialNumber = json['serialNumber'];
    scale = json['scale'];
    user = json['user'];
    userCode = json['userCode'];
    customer = json['customer'];
    customerCode = json['customerCode'];
    number = json['number'];
    when =  DateTime.fromMillisecondsSinceEpoch(json['when'])   ;
    code = json['code'];
    codeCode = json['codeCode'];
    codeBarcode = json['codeBarcode'];

    grossWeight = Measurement.fromJson(json['grossWeight']);
    tare = Measurement.fromJson(json['tare']);
    decimals = json['decimals'];

  }

  Map<String, dynamic> toJson() {
    return{
      'serialNumber' : serialNumber,
      'scale' : scale,
      'user' : user,
      'userCode' : userCode,
      'customer' : customer,
      'customerCode' : customerCode,
      'number' : number,
      'when' : when.millisecondsSinceEpoch,
      'code' : code,
      'codeCode' : codeCode,
      'codeBarcode' : codeBarcode,
      'grossWeight' : grossWeight.toJson(),
      'tare' : tare.toJson(),
      'decimals' : decimals,

    };
  }

  Map<String, dynamic> toJsonT() {
    return{
      'serialNumber' : serialNumber,
      'scale' : scale,
      'user' : user,
      'userCode' : userCode,
      'customer' : customer,
      'customerCode' : customerCode,
      'number' : number,
      'when' : when.toIso8601String(),
      'code' : code,
      'codeCode' : codeCode,
      'codeBarcode' : codeBarcode,
      'grossWeight' : grossWeight.toJsonT(),
      'tare' : tare.toJsonT(),
      'decimals' : decimals,

    };
  }


  String printValue(String literal){

    return formattedValue(WeightRecord.names[literal]);

  }

  String stringValue(DisplayFields f){

    switch(f) {

      case DisplayFields.user:
        return user;
        break;

      case DisplayFields.userCode:
        return userCode;
        break;


      case DisplayFields.customer:
        return customer;
        break;

      case DisplayFields.customerCode:
        return customerCode;
        break;

      case DisplayFields.number:
        return number.toString();
        break;

      case DisplayFields.date:
        return dateString(when);
        break;

      case DisplayFields.time:
        return timeString(when);
        break;

      case DisplayFields.item:
        return code;
        break;

      case DisplayFields.netWeight:
        return this.netWeight.valueFormatted(decimals);
        break;

      case DisplayFields.tare:
        return tare.valueFormatted(decimals);
        break;

      case DisplayFields.grossWeight:
        return grossWeight.valueFormatted(decimals);
        break;

      case DisplayFields.code:
        return code;
        break;

      case DisplayFields.codeCode:
        return codeCode;
        break;

      case DisplayFields.codeBarcode:
        return codeBarcode;
        break;

      case DisplayFields.netWeightNumber:
        return this.netWeight.valueFormatted(decimals);
        break;

      case DisplayFields.grossWeightNumber:
        return grossWeight.valueFormatted(decimals);
        break;

      default:
        return "";
        break;
    }

  }

  String formattedValue(DisplayFields f){

    switch(f) {

      case DisplayFields.user:
        return user;
        break;

      case DisplayFields.userCode:
        return userCode;
        break;


      case DisplayFields.customer:
        return customer;
        break;

      case DisplayFields.customerCode:
        return customerCode;
        break;

      case DisplayFields.number:
        return number.toString();
        break;

      case DisplayFields.date:
        return dateString(when);
        break;

      case DisplayFields.time:
        return timeString(when);
        break;

      case DisplayFields.item:
        return code;
        break;

      case DisplayFields.netWeight:
        return this.netWeight.formatted(decimals);
        break;

      case DisplayFields.tare:
        return tare.formatted(decimals);
        break;

      case DisplayFields.grossWeight:
        return grossWeight.formatted(decimals);
        break;

      case DisplayFields.code:
        return code;
        break;

      case DisplayFields.codeCode:
        return codeCode;
        break;

      case DisplayFields.codeBarcode:
        return codeBarcode;
        break;

      case DisplayFields.netWeightNumber:
        return this.netWeight.valueFormatted(decimals);
        break;

      case DisplayFields.grossWeightNumber:
        return grossWeight.valueFormatted(decimals);


      default:
        return "";
        break;
    }

  }


  recordAsCSV(separator , eol) {

    var  s =  "\"$scale\"$separator\"$serialNumber\"$separator\"$user\"$separator\"$userCode\"$separator\"$customer\"$separator\"$customerCode\"$separator\"$number\"$separator\"${dateString(when)}\"$separator\"${timeString(when)}\"$separator\"$code\"$separator\"$codeCode\"$separator\"$codeBarcode\"$separator\"${formattedDecs(grossWeight.value, decimals, separator: false)}\"$separator\"${formattedDecs(tare.value, decimals, separator: false)}\"$separator\"${formattedDecs(netWeight.value, decimals, separator: false)}\"$separator\"${units[grossWeight.unit].symbol}\"${eol}";
    return s;
  }


  static titlesAsCSV(separator , eol) {
    return "\"scale\"$separator\"sn\"$separator\"user\"$separator\"userCode\"$separator\"customer\"$separator\"customerCode\"$separator\"number\"$separator\"date\"$separator\"time\"$separator\"item\"$separator\"itemCode\"$separator\"itemBarcode\"$separator\"grossweight\"$separator\"tare\"$separator\"netweight\"$separator\"units\"${eol}"   ;
  }



}
