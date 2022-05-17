import 'dart:typed_data';
import 'package:sprintf/sprintf.dart';

enum FunctionType {
  read,
  read_response,
  write,
  write_response,
  execution,
  execution_response
}

const functionCodes = {
  FunctionType.read: 0x52,
  FunctionType.read_response: 0x72,
  FunctionType.write: 0x57,
  FunctionType.write_response: 0x77,
  FunctionType.execution: 0x45,
  FunctionType.execution_response: 0x65,
};

const functionValue = {
  0x52: FunctionType.read,
  0x72: FunctionType.read_response,
  0x57: FunctionType.write,
  0x77: FunctionType.write_response,
  0x45: FunctionType.execution,
  0x65: FunctionType.execution_response,
};

enum AddressType {
  unknown,
  serialNumber,
  deviceId,
  moduleBoardCode,
  firmwareVersion,
   sealing,
  optionalBoard,

  baudRate,
  outputRate,
  streamData,
  stopStreaming,
  measurementData,
  scaleUnit, // 1-> g 2->kg 3->lb 4-> oz
  rangeMode,
  maxValue_1,
  e_1,
  maxValue_2,
  e_2,
  decimalPosition,
  resolutionFactor,
  allowNegativeWeight,
  initialZeroCounts,
  slopeDivisor,
  geoCode,
  geoCodeAdjustment,
  adSpeed,
  autoTare,
  tareOnStability,
  zeroTrackingDevice,
  zeroTrackingRange,
  initialZero,
  initialZeroRange,
  filterLevel,
  motionFilter,
  livestockFilter,
  stabilityRange,
  highResolutionMode,
  deviceStateInformation,
  tareValue,
  clearTare,
  switchTareOn,
  presetManualTare,
  adcCountsFiltered,

  zeroIndicator,
  ssidName,
  ssidPassword,
  ipAddress,
  accessPoint,

  networkName,
  networkPassword,
  netIp,
  netDhcp,

  udpRemotePort,
  udpLocalPort,
  tcpServerPort,

  dateLastCalibration,
  changeCalibrationCounter,

  getState,
  hashMessage,

  resetScale,
  resetFactory
}

const addressCodes = {
  AddressType.unknown: -1,
  AddressType.serialNumber: 0x0000,
  AddressType.deviceId: 0x0001,
  AddressType.moduleBoardCode: 0x0007,
  AddressType.firmwareVersion: 0x0008,
  AddressType.sealing: 0x0009,
  AddressType.optionalBoard: 0x000a,
  AddressType.getState: 0x000e,
  AddressType.baudRate: 0x0010,
  AddressType.outputRate: 0x0013,
  AddressType.scaleUnit: 0x0020, // 1-> g 2->kg 3->lb 4-> oz,
  AddressType.rangeMode: 0x0021,
  AddressType.maxValue_1: 0x0022,
  AddressType.e_1: 0x0023,
  AddressType.maxValue_2: 0x0024,
  AddressType.e_2: 0x0025,
  AddressType.decimalPosition: 0x0026,
  AddressType.resolutionFactor: 0x0028,
  AddressType.allowNegativeWeight: 0x0029,
  AddressType.initialZeroCounts: 0x0030,
  AddressType.slopeDivisor: 0x0031,

  AddressType.adSpeed: 0x0038,
  AddressType.geoCode: 0x0041,
  AddressType.geoCodeAdjustment: 0x0042,
  AddressType.autoTare: 0x0061,
  AddressType.tareOnStability: 0x0062,
  AddressType.zeroTrackingDevice: 0x0050,
  AddressType.zeroTrackingRange: 0x0051,
  AddressType.initialZero: 0x0052,
  AddressType.initialZeroRange: 0x053,
  AddressType.filterLevel: 0x0070,
  AddressType.motionFilter: 0x0071,
  AddressType.livestockFilter: 0x0072,
  AddressType.stabilityRange: 0x0073,
  AddressType.deviceStateInformation: 0x0100,
  AddressType.tareValue: 0x0102,
  AddressType.zeroIndicator: 0x0105,
  AddressType.measurementData: 0x0107,
  AddressType.presetManualTare: 0x0108,
  AddressType.adcCountsFiltered: 0x0111,

  AddressType.ssidName: 0x0500,
  AddressType.ssidPassword: 0x0501,
  AddressType.ipAddress: 0x0502,
  AddressType.accessPoint: 0x0504,

  AddressType.networkName: 0x0600,
  AddressType.networkPassword: 0x0601,
  AddressType.netIp: 0x0602,
  AddressType.netDhcp: 0x0603,

  AddressType.udpRemotePort: 0x0700,
  AddressType.udpLocalPort: 0x0701,
  AddressType.tcpServerPort: 0x0702,

  AddressType.dateLastCalibration: 0x0910,
  AddressType.changeCalibrationCounter : 0x0911,
  AddressType.stopStreaming: 0x1010,
  AddressType.streamData: 0x1011,
  AddressType.switchTareOn: 0x1060,
  AddressType.clearTare: 0x1103,
  AddressType.highResolutionMode: 0x1104,


  AddressType.hashMessage: 0xaa55,

  AddressType.resetScale: 0x9999,
  AddressType.resetFactory: 0xeeee,

};

const addressValue = {
  -1: AddressType.unknown,
  0x0000: AddressType.serialNumber,
  0x0001: AddressType.deviceId,
  0x0007: AddressType.moduleBoardCode,
  0x0008: AddressType.firmwareVersion,
  0x0009: AddressType.sealing,
  0x000a: AddressType.optionalBoard,
  0x000e: AddressType.getState,
  0x0010: AddressType.baudRate,
  0x0013: AddressType.outputRate,
  0x0020: AddressType.scaleUnit,
  0x0021: AddressType.rangeMode,
  0x0022: AddressType.maxValue_1,
  0x0023: AddressType.e_1,
  0x0024: AddressType.maxValue_2,
  0x0025: AddressType.e_2,
  0x0026: AddressType.decimalPosition,
  0x0028: AddressType.resolutionFactor,
  0x0029: AddressType.allowNegativeWeight,
  0x0030: AddressType.initialZeroCounts,
  0x0031: AddressType.slopeDivisor,
  0x0038: AddressType.adSpeed,
  0x0041: AddressType.geoCode,
  0x0042: AddressType.geoCodeAdjustment,
  0x0050: AddressType.zeroTrackingDevice,
  0x0051: AddressType.zeroTrackingRange,
  0x0052: AddressType.initialZero,
  0x0053: AddressType.initialZeroRange,
  0x0061: AddressType.autoTare,
  0x0062: AddressType.tareOnStability,
  0x0070: AddressType.filterLevel,
  0x0071: AddressType.motionFilter,
  0x0072: AddressType.livestockFilter,
  0x0073: AddressType.stabilityRange,
  0x0100: AddressType.deviceStateInformation,
  0x0102: AddressType.tareValue,
  0x0105: AddressType.zeroIndicator,
  0x0107: AddressType.measurementData,
  0x0108: AddressType.presetManualTare,
  0x0111: AddressType.adcCountsFiltered,
  0x0500: AddressType.ssidName,
  0x0501: AddressType.ssidPassword,
  0x0502: AddressType.ipAddress,
  0x0504: AddressType.accessPoint,
  0x0600: AddressType.networkName,
  0x0601: AddressType.networkPassword,
  0x0602: AddressType.netIp,
  0x0603: AddressType.netDhcp,
  0x0700: AddressType.udpRemotePort,
  0x0701: AddressType.udpLocalPort,
  0x0702: AddressType.tcpServerPort,
  0x0910: AddressType.dateLastCalibration,
  0x0911: AddressType.changeCalibrationCounter,
  0x1010: AddressType.stopStreaming,
  0x1011: AddressType.streamData,
  0x1060: AddressType.switchTareOn,
  0x1103: AddressType.clearTare,
  0x1104: AddressType.highResolutionMode,

  0xaa55: AddressType.hashMessage,

  0x9999: AddressType.resetScale,
  0xeeee: AddressType.resetFactory,

};

enum DeviceError {
  noError,
  flashError,
  adcError,
  inputSignalOutOfRange,
  inputSignalTooHigh,
  inputSignalTooLow,
  vecTooHigh,
  overload,
  negativeWeight
}

const deviceErrorValue = {
  0: DeviceError.noError,
  1: DeviceError.flashError,
  2: DeviceError.adcError,
  3: DeviceError.inputSignalOutOfRange,
  4: DeviceError.inputSignalTooHigh,
  5: DeviceError.inputSignalTooLow,
  6: DeviceError.vecTooHigh,
  7: DeviceError.overload,
  8: DeviceError.negativeWeight
};

const deviceErrorString = {
  DeviceError.noError: "No Error",
  DeviceError.flashError: "Error 01",
  DeviceError.adcError: "Error 02",
  DeviceError.inputSignalOutOfRange: "Error 03",
  DeviceError.inputSignalTooHigh: "ADC H",
  DeviceError.inputSignalTooLow: "ADC L",
  DeviceError.vecTooHigh: "Error 06",
  DeviceError.overload: "Overload",
  DeviceError.negativeWeight: "--------"
};

// Converteix un int que correspon a un caracter Ascii Hexa a un numero amb el seu valor.  Es a dir
// converteix '4' -> 4, 'F' -> 15
int intFromHexDigit(int hex) {
  if (hex >= 0x30 && hex <= 0x39) {
    return hex - 0x30;
  } else if (hex >= 0x41 && hex <= 0x46) {
    return hex - 0x41 + 0x0A;
  } else if (hex >= 0x61 && hex <= 0x66) {
    return hex - 0x61 + 0x0A;
  } else {
    return -1; // Error
  }
}

// Converteix un array de chars que representen digits hexa en el seu valor

int intFromHexArray(List<int> hexArray) {
  int acum = 0;

  for (int h in hexArray) {
    int v = intFromHexDigit(h);
    acum *= 16;
    if (v >= 0 && v <= 15) {
      acum += v;
    } else {
      return -1;
    }
  }
  return acum;
}

int intFromDecArray(List<int> decArray) {
  int acum = 0;

  for (int h in decArray) {
    int v = intFromHexDigit(h);
    acum *= 10;
    if (v >= 0 && v <= 9) {
      acum += v;
    } else {
      return -1;
    }
  }
  return acum;
}

List<int> int2List(value, len) {
  String slen = sprintf("%d", [len]);
  String format = "%0" + slen + "X";
  String data = sprintf(format, [value]);
  return data.codeUnits;
}

List<int> decArray(int value, int len) {
  String slen = sprintf("%d", [len]);
  String format = "%0" + slen + "d";
  String data = sprintf(format, [value]);
  return data.codeUnits;
}

class GRAMMessage {
  int from;
  int to;
  FunctionType function;
  AddressType address;
  int dataLength;
  List<int> dataSent;
  String ipOrigin;

  String get stringValue => String.fromCharCodes(dataSent);

  int get intValue => intFromDecArray(dataSent);

  double get doubleValue => intFromDecArray(dataSent).toDouble();

  GRAMMessage(
      int from, int to, FunctionType func, AddressType addr, List<int> dat, String ipOrigin) {
    this.from = from;
    this.to = to;
    this.function = func;
    this.address = addr;
    this.dataLength = dat.length;
    this.dataSent = dat;
    this.ipOrigin = ipOrigin;
  }

  GRAMMessage.fromData(List<int> data, String ipOrigin) {
    if (data != null && data.length > 12) {
      // minimum size is 13
      this.from = intFromHexArray(data.sublist(1, 3));
      this.to = intFromHexArray(data.sublist(3, 5));
      this.function = functionValue[data[5]];
      this.address = addressValue[intFromHexArray(data.sublist(6, 10))];
      this.dataLength = intFromHexArray(data.sublist(10, 12));
      this.ipOrigin = ipOrigin;
      if (this.dataLength > 0) {
        this.dataSent = data.sublist(12, 12 + this.dataLength);
      } else {
        this.dataSent = [];
      }
    } else {
      this.from = -1; // Signal error
    }
  }

  String toString() {
    return "from: $from to: $to F: $function a: $address";
  }

  String data() {
    List<int> buffer = [0x02];
    buffer.addAll(int2List(from, 2));
    buffer.addAll(int2List(to, 2));
    buffer.add(functionCodes[function]);
    buffer.addAll(int2List(addressCodes[address], 4));
    buffer.addAll(int2List(dataSent.length, 2));
    buffer.addAll(dataSent);

    //  OK now compute the check
    int acum = 0;
    for (int i = 1; i < buffer.length; i++) {
      acum = acum ^ buffer[i];
    }


    acum = acum & 0xFF; // Per si les mosques

    buffer.addAll(int2List(acum, 2));

    buffer.add(0x03);
    buffer.add(0x0D); // CR
    buffer.add(0x0A); // NL



    return String.fromCharCodes(
        Uint8List.fromList(buffer)); // Hope it will trunc everything
  }

  bool iseq(GRAMMessage m) {
    return m.function == this.function &&
        m.address == this.address &&
        m.dataLength == this.dataLength &&
        m.dataSent == this.dataSent;
  }

  String writeErrorMessage() {
    if (function == FunctionType.write_response) {
      switch (dataSent[0]) {
        case 0x30:
          {
            // No error
            return null;
          }
          break;

        case 0x31:
          {
            return "Protected by Sealing Switch";
          }
          break;

        case 0x32:
          {
            return "Read only record";
          }
          break;

        case 0x33:
          {
            return "Incorrect Value / Out of range";
          }
          break;

        default:
          {
            return "Unknown error ${dataSent[0]}";
          }
      }
    }
    return null;
  }

  String executionErrorMessage() {
    if (function == FunctionType.execution_response) {
      switch (dataSent[0]) {
        case 0x30:
          {
            // No error
            return null;
          }
          break;

        case 0x31:
          {
            return "Protected by Sealing Switch";
          }
          break;

        default:
          {
            return "Unknown error ${dataSent[0]}";
          }
      }
    }
    return null;
  }

  DeviceError deviceError() {
    if (address == AddressType.deviceStateInformation && dataSent.length >= 2) {
      return deviceErrorValue[intFromHexDigit(dataSent[1])];
    } else {
      return DeviceError.noError;
    }
  }

  // Static functions that create messages






  static GRAMMessage readAddress(AddressType address) {
    return GRAMMessage(0, 0xff, FunctionType.read, address, [], "");
  }

  static GRAMMessage executeAddress(AddressType address) {
    return GRAMMessage(0, 0xff, FunctionType.execution, address, [], "");
  }


  static GRAMMessage outputRate(int rate){
    var s = rate.toString();
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.outputRate, s.codeUnits, "");
  }

  static getOutputRate(){
    return readAddress(AddressType.outputRate);

  }

  // Geo Codes

  static GRAMMessage geoCode(int geocode){
    var s = geocode.toString();
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.geoCode, s.codeUnits, "");

  }

  static getGeoCode(){
    return readAddress(AddressType.geoCode);
  }


  static GRAMMessage geoCodeAdjustment(int geocode){
    var s = geocode.toString();
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.geoCodeAdjustment, s.codeUnits, "");

  }

  static getGeoCodeAdjustment(){
    return readAddress(AddressType.geoCodeAdjustment);
  }






  static GRAMMessage adSpeed(int speed){
    var s = speed.toString();
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.adSpeed, s.codeUnits, "");

  }

  static getAdSpeed(){
    return readAddress(AddressType.adSpeed);
  }
  static GRAMMessage deviceId(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.deviceId, s.codeUnits, "");
  }



  static GRAMMessage getDeviceId() {
    return readAddress(AddressType.deviceId);
  }

  static GRAMMessage baudRate(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.baudRate, s.codeUnits, "");
  }



  static GRAMMessage getBaudRate() {
    return readAddress(AddressType.baudRate);
  }


  static GRAMMessage getModuleBoardCode() {
    return readAddress(AddressType.moduleBoardCode);
  }

  static GRAMMessage getFirmwareVersion() {
    return readAddress(AddressType.firmwareVersion);
  }

  static GRAMMessage getOptionalBoard() {
    return readAddress(AddressType.optionalBoard);
  }


  static GRAMMessage startStreaming() {
    return executeAddress(AddressType.streamData);
  }

  static GRAMMessage stopStreaming() {
    return executeAddress(AddressType.stopStreaming);
  }

  static GRAMMessage getSerialNumber() {
    return readAddress(AddressType.serialNumber);
  }


  static GRAMMessage scaleUnit(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.scaleUnit, s.codeUnits, "");
  }



  static GRAMMessage getScaleUnit() {
    return readAddress(AddressType.scaleUnit);
  }


  static GRAMMessage rangeMode(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.rangeMode, s.codeUnits, "");
  }


  static GRAMMessage getRangeMode() {
    return readAddress(AddressType.rangeMode);
  }

  static GRAMMessage setMax1(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.maxValue_1, s.codeUnits, "");
  }


  static GRAMMessage getMax1() {
    return readAddress(AddressType.maxValue_1);
  }

  static GRAMMessage setMax2(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.maxValue_2, s.codeUnits, "");
  }


  static GRAMMessage getMax2() {
    return readAddress(AddressType.maxValue_2);
  }

  static GRAMMessage sete1(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.e_1, s.codeUnits, "");
  }

  static GRAMMessage gete1() {
    return readAddress(AddressType.e_1);
  }

  static GRAMMessage sete2(int id) {

    var s = id.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.e_2, s.codeUnits, "");
  }

  static GRAMMessage gete2() {
    return readAddress(AddressType.e_2);
  }

  static GRAMMessage decimalPointPosition(int pos) {

    var s = pos.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.decimalPosition, s.codeUnits, "");
  }


  static GRAMMessage getDecimalPointPosition() {
    return readAddress(AddressType.decimalPosition);
  }


  static GRAMMessage initialZeroCounts(int counts) {

    var s = counts.toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.initialZeroCounts, s.codeUnits, "");
  }


  static GRAMMessage getInitialZeroCounts() {
    return readAddress(AddressType.initialZeroCounts);
  }


  static GRAMMessage slopeDivisor(double slope) {

    var s = (slope*10000).round().toString();

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.slopeDivisor, s.codeUnits, "");
  }


  static GRAMMessage getSlopeDivisor() {
    return readAddress(AddressType.slopeDivisor);
  }



  static GRAMMessage getResolutionFactor() {
    return readAddress(AddressType.resolutionFactor);
  }

  static GRAMMessage setTare() {
    return executeAddress(AddressType.tareValue);
  }

  static GRAMMessage setTareValue(double value, double e, int digits) {
    // Convert double to Hexa

    var v = (value / e).round() * e; // Arrodonit a multiples de e

    for (var i = 0; i < digits; i++) {
      v *= 10.0;
    }

    var ivalue = v.floor(); // Cal veure que fem amb els decimals
    var hValue = decArray(ivalue, 8);

    return GRAMMessage(
        0, 0xff, FunctionType.write, AddressType.presetManualTare, hValue, "");
  }


  static GRAMMessage getAdcCountsFiltered() {
    return readAddress(AddressType.adcCountsFiltered);
  }

  static GRAMMessage clearTare() {
    return GRAMMessage.executeAddress(AddressType.clearTare);
  }

  static GRAMMessage toggleTareMode() {
    return executeAddress(AddressType.switchTareOn);
  }

  static GRAMMessage setZero() {
    return executeAddress(AddressType.zeroIndicator);
  }

  static GRAMMessage autoTare(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.autoTare,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getAutoTare() {
    return readAddress(AddressType.autoTare);
  }

  static GRAMMessage allowNegativeWeight(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.allowNegativeWeight,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getAllowNegativeWeight() {
    return readAddress(AddressType.allowNegativeWeight);
  }

  static GRAMMessage tareOnStability(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.tareOnStability,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getTareOnStability() {
    return readAddress(AddressType.tareOnStability);
  }

  static GRAMMessage initialZero(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.initialZero, [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getInitialZero() {
    return readAddress(AddressType.initialZero);
  }

  static GRAMMessage initialZeroRange(int value) {
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.initialZeroRange, decArray(value, 3), "");
  }

  static GRAMMessage getInitialZeroRange() {
    return readAddress(AddressType.initialZeroRange);
  }


  static GRAMMessage zeroTracking(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.zeroTrackingDevice, [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getZeroTracking() {
    return readAddress(AddressType.zeroTrackingDevice);
  }

  static GRAMMessage zeroTrackingRange(int value) {
    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.zeroTrackingRange, decArray(value, 1), "");
  }

  static GRAMMessage getZeroTrackingRange() {
    return readAddress(AddressType.zeroTrackingRange);
  }

  static GRAMMessage motionFilter(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.motionFilter,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getMotionFilter() {
    return readAddress(AddressType.motionFilter);
  }

  static GRAMMessage livestockFilter(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.livestockFilter,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getLivestockFilter() {
    return readAddress(AddressType.livestockFilter);
  }

  static GRAMMessage filterLevel(int value) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.filterLevel,
        decArray(value, 1), "");
  }

  static GRAMMessage getFilterLevel() {
    return readAddress(AddressType.filterLevel);
  }

  static GRAMMessage stabilityRange(int value) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.stabilityRange,
        decArray(value, 1), "");
  }

  static GRAMMessage getStabilityRange() {
    return readAddress(AddressType.stabilityRange);
  }

  static GRAMMessage highResolutionMode() {
    return executeAddress(AddressType.highResolutionMode);
  }


  // Access Point


  static GRAMMessage getSSIDName() {
    return readAddress(AddressType.ssidName);
  }

  static GRAMMessage ssidName(String name) {
    if (name.isEmpty) {
      return null;
    }

    var checkedName = name;
    if (name.length > 32) {
      checkedName = name.substring(0, 31);
    }
    return GRAMMessage(
        0, 1, FunctionType.write, AddressType.ssidName, checkedName.codeUnits, "");
  }

  static GRAMMessage getSSIDPassword() {
    return readAddress(AddressType.ssidPassword);
  }

  static GRAMMessage ssidPassword(String pwd) {
    if (pwd.isEmpty) {
      return null;
    }

    var checkedPwd = pwd;
    if (pwd.length > 32) {
      checkedPwd = pwd.substring(0, 31);
    }
    return GRAMMessage(0, 1, FunctionType.write, AddressType.ssidPassword,
        checkedPwd.codeUnits, "");
  }


  static GRAMMessage getIPAddress() {
    return readAddress(AddressType.ipAddress);
  }

  static GRAMMessage ipAddress(String ip) {
    if (ip.isEmpty) {
      return null;
    }

    var checkedIp = ip;
    if (ip.length > 32) {
      checkedIp = ip.substring(0, 31);
    }
    return GRAMMessage(0, 1, FunctionType.write, AddressType.ipAddress,
        checkedIp.codeUnits, "");
  }



  static GRAMMessage accessPoint(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.accessPoint,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getAccessPoint() {
    return readAddress(AddressType.accessPoint);
  }


  // Network
  static GRAMMessage getNetworkName() {
    return readAddress(AddressType.networkName);
  }

  static GRAMMessage networkName(String name) {
    if (name.isEmpty) {
      return null;
    }

    var checkedName = name;
    if (name.length > 32) {
      checkedName = name.substring(0, 31);
    }
    return GRAMMessage(
        0, 1, FunctionType.write, AddressType.networkName, checkedName.codeUnits, "");
  }

  static GRAMMessage getNetworkPassword() {
    return readAddress(AddressType.networkPassword);
  }

  static GRAMMessage networkPassword(String pwd) {
    if (pwd.isEmpty) {
      return null;
    }

    var checkedPwd = pwd;
    if (pwd.length > 32) {
      checkedPwd = pwd.substring(0, 31);
    }
    return GRAMMessage(0, 1, FunctionType.write, AddressType.networkPassword,
        checkedPwd.codeUnits, "");
  }

  static GRAMMessage netDhcp(bool state) {
    return GRAMMessage(0, 0xff, FunctionType.write, AddressType.netDhcp,
        [state ? 0x31 : 0x30], "");
  }

  static GRAMMessage getNetDhcp() {
    return readAddress(AddressType.netDhcp);
  }

  static GRAMMessage getNetIp() {
    return readAddress(AddressType.netIp);
  }

  static GRAMMessage netIp(String ip) {
    if (ip.isEmpty) {
      return null;
    }

    var checkedIp = ip;
    if (ip.length > 32) {
      checkedIp = ip.substring(0, 31);
    }
    return GRAMMessage(0, 1, FunctionType.write, AddressType.netIp,
        checkedIp.codeUnits, "");
  }

  static GRAMMessage tcpServerPort(int port){

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.tcpServerPort, decArray(port, 3), "");

  }

  static GRAMMessage getTCPServerPort(){
    return readAddress(AddressType.tcpServerPort);
  }

  static GRAMMessage udpRemotePort(int port){

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.udpRemotePort, decArray(port, 3), "");

  }

  static GRAMMessage getUDPRemotePort(){
    return readAddress(AddressType.udpRemotePort);
  }

  static GRAMMessage udpLocalPort(int port){

    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.udpLocalPort, decArray(port, 3), "");

  }


  static GRAMMessage getUDPLocalPort(){
    return readAddress(AddressType.udpLocalPort);
  }



  static GRAMMessage dateLastCalibration(String s) {


    return GRAMMessage(0, 0xff, FunctionType.write,
        AddressType.dateLastCalibration, s.codeUnits, "");
  }

  static GRAMMessage getDateLastCalibration() {
    return readAddress(AddressType.dateLastCalibration);
  }

  static GRAMMessage getChangeCalibrationCounter() {
    return readAddress(AddressType.changeCalibrationCounter);
  }

  static GRAMMessage getState() {
    return readAddress(AddressType.getState);
  }

  static GRAMMessage getHashMessage() {
    return readAddress(AddressType.hashMessage);
  }

  static GRAMMessage resetScale(){
    return executeAddress(AddressType.resetScale);
  }

  static GRAMMessage resetFactory(){
    return executeAddress(AddressType.resetFactory);
  }

}
