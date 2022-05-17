

import 'GRAMMessage.dart';

class GRAMWeightRecord {

  double weight = 0.0;
  String wunit = "g ";
  double tare = 0.0;
  String tunit = "g ";

  // flags

  int decimalPosition = 0;
  bool zero = false;
  bool tareOn = false;
  bool stable = false;
  bool netWeight = false;
  int tareMode = 0;
  bool highResolution = false;
  bool initialZero = false;
  bool overload = false;
  bool negative = false;
  int range = 1;
  bool presetTare  = false;

  GRAMWeightRecord(List<int> data){

    if (data[0] != 0x57){
      throw FormatException;
    }

    weight = listToDouble(data.sublist(1,9));
    wunit = String.fromCharCodes(data.sublist(9, 11));


    if (data[11] != 0x54){
      throw FormatException;
    }

    tare = listToDouble(data.sublist(12,20));
    tunit = String.fromCharCodes(data.sublist(20, 22));

    if (data[22] != 0x53){
      throw FormatException;
    }

    int s1 = intFromHexDigit(data[23]);
    int s2 = intFromHexDigit(data[24]);
    int s3 = intFromHexDigit(data[25]);

    zero = (s3 & 0x0001) != 0 ;
    tareOn  = (s3 & 0x0002) != 0 ;
    stable  = (s3 & 0x0004) != 0 ;
    netWeight  = (s3 & 0x0008) != 0 ;
    tareMode = s2 & 0x0001 ;
    highResolution  = (s2 & 0x0002) != 0 ;
    initialZero  = (s2 & 0x0004) != 0 ;  // Sembla que no funciona
    overload  = (s2 & 0x0008) != 0 ;
    negative  = (s1 & 0x0001) != 0 ;
    range = (s1 & 0x0002) == 0 ? 1 : 2 ;   // Convert to range 1 or 2
    presetTare  = (s1 & 0x0004) != 0 ;


    var send = String.fromCharCodes(data.sublist(1,9));
    var sEnd = send.length - 1;   // Last index
    var p = send.indexOf(".");    // p Position

    if(p == -1) {
      decimalPosition = 0;
    } else {
      decimalPosition = sEnd - p ;
    }

  }

  bool iseq(GRAMWeightRecord rhs){
    return this.weight == rhs.weight &&
      this.wunit == rhs.wunit &&
    this.tare == rhs.tare &&
    this.tunit == rhs.tunit &&
    this.decimalPosition == rhs.decimalPosition &&
    this.zero == rhs.zero &&
    this.stable == rhs.stable &&
    this.netWeight == rhs.netWeight &&
    this.tareMode == rhs.tareMode &&
    this.highResolution == rhs.highResolution &&
    this.initialZero == rhs.initialZero &&
    this.overload == rhs.overload &&
    this.negative == rhs.negative &&
    this.range ==  rhs.range &&
    this.presetTare == rhs.presetTare;


  }
  double listToDouble(List<int> data) {

    String sData = String.fromCharCodes(data).replaceAll(" ", "");

    if (sData.indexOf("." ) == -1){
      sData = sData + ".0";
    }

    double d = double.parse(sData);
    return d;

  }


}