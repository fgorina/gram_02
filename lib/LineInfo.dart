import 'package:flutter/material.dart';
import 'dart:ui';
import 'DataTypesUtilities.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode/barcode.dart';
import 'VariableInfo.dart';
import 'WeightRecord.dart';
import 'package:image/image.dart' as img;
import 'Units.dart';
import 'Measurement.dart';
import 'GRAMModel.dart';

class LineInfo {

  static List<String> barcodeDesc = ["UPC A", "UPC E", "EAN13", "EAN8", "Code 39", "2 of 5", "CODABAR", "Code 93", "Code128", 'QR'];
  static List<String> barcodeCPCL = ["UPCA", "UPCE", "EAN13", "EAN8", "39", "I2OF5", "CODABAR", "93", "128", 'QR'];
  static WeightRecord testRecord = WeightRecord(
      '123456',
      'Enviaments',
      'Paco',
      'PAC01',
      'Caprabo',
      'CAPA01',
      1,
      DateTime.now(),
      'Prod',
      'PROD1',
      '987654',
      Measurement(500.0, Unit.kilograms),
      Measurement(100.0, Unit.kilograms),
      2);
  int type = 0; // 0 -> Normal, 1-> Barcode, 2-> Logo
  double height = 1; // 1 -> Normal, 2 -> Double Spacing, n -> n n * 1 line
  double width = 36; // Total Line Width
  FontWeight weight = FontWeight.normal;
  int barcodeType = 4; // 0 -> UPC-A, 1 -> UPC-E, 2-> EAN13, 3-> EAN8, 4 -> CODE39, 5 -> I25, 6 -> CODaBAR, 7-> CODE93, 8 -> CODE128 , 9 = QR   Code for printer = barcodeType + 65


  String left = "         ";
  String center = "         ";
  String right = "         ";

  int alignLeft = -1; //  -1 Left, 0 center, 1 Right
  int alignCenter = 0; //  -1 Left, 0 center, 1 Right
  int alignRight = 1; //  -1 Left, 0 center, 1 Right
  Image image;

  LineInfo();
LineInfo.fromJSON(Map<String, dynamic> json, img.Image bw){

    print(json);

    type = json['type'];
    height = json['height'];
    width = json['width'];
    weight = FontWeight.values[(json['weight'])];
    barcodeType = json['barcodeType'];
    left = json['left'];
    center = json['center'];
    right = json['right'];
    alignLeft = json['alignLeft'];
    alignCenter = json['alignCenter'];
    alignRight = json['alignRight'];

    if (height > 2 && GRAMModel.shared.printerName.startsWith("/dev/tty")){
      height = 2;
    }
    if (type == 2) {
      image = Image.memory(img.encodePng(bw));
    } else {
      image = null;
    }


  }

  String toString(){
    return "$type, $left, $center, $right";
  }

  Map<String, dynamic> toJSON(){

    Map<String, dynamic> json =  Map<String, dynamic>();

    json['type'] = type;
    json['height'] = height;
    json['width'] = width;
    json['weight'] = weight.index;
    json['barcodeType'] = barcodeType;
    json['left'] = left;
    json['center'] = center;
    json['right'] = right;
    json['alignLeft'] = alignLeft;
    json['alignCenter'] = alignCenter;
    json['alignRight'] = alignRight;
    return json;

  }



  String description({WeightRecord record, int lwidth = 36}) {
    String vLeft = left;
    String vCenter = center;
    String vRight = right;

    if (record != null) {
      WeightRecord.names.keys.forEach((element) {
        vLeft = vLeft.replaceAll(element, record.printValue(element));
        vCenter = vCenter.replaceAll(element, record.printValue(element));
        vRight = vRight.replaceAll(element, record.printValue(element));
      });
    }

    // Get lengths
    double rest = (lwidth / height) - vCenter.length.toDouble();
    int l = (rest / 2).floor();
    int r = rest.floor() - l;

    var filler = " ";

    if ((vLeft.length > 0) &&
        (vLeft.substring(0, 1) == "┏" ||
            vLeft.substring(0, 1) == "┣" ||
            vLeft.substring(0, 1) == "┗" ||
            vLeft.substring(0, 1) == "━")) {
      filler = "━";
    }

    String sleft;
    if (alignLeft == -1) {
      sleft = justifyRight(vLeft, l, filler);
    } else {
      if (vLeft.length > 0 && vLeft[0] == "┃") {
        sleft = "┃" +
            justifyLeft(vLeft.substring(1, vLeft.length - 1), l - 1, filler);
      } else {
        sleft = justifyLeft(vLeft, l, filler);
      }
    }

    //String sleft = alignLeft == -1 ? justifyRight(vLeft, l, filler) :  justifyLeft(vLeft, l, filler);

    filler = " ";

    if ((vRight.length > 0) &&
        (vRight.substring(vRight.length - 1, vRight.length) == "┓" ||
            vRight.substring(vRight.length - 1, vRight.length) == "┫" ||
            vRight.substring(vRight.length - 1, vRight.length) == "┛" ||
            vRight.substring(vRight.length - 1, vRight.length) == "━")) {
      filler = "━";
    }

    String sright;

    if (alignRight == -1) {
      if (vRight.length > 0 && vRight[vRight.length - 1] == "┃") {
        sright = justifyRight(
                vRight.substring(0, vRight.length - 1), r - 1, filler) +
            "┃";
      } else {
        sright = justifyRight(vRight, r, filler);
      }
    } else {
      sright = justifyLeft(vRight, r, filler);
    }

    //String sright = alignRight == -1 ? justifyRight(vRight, r, filler) : justifyLeft(vRight, r, filler);

    String full = sleft + vCenter + sright;

    return full;
  }

  String leftDescription({WeightRecord record, int lwidth=36}) {
    String vLeft = left;
    String vCenter = center;

    if (record != null) {
      WeightRecord.names.keys.forEach((element) {
        vLeft = vLeft.replaceAll(element, record.printValue(element));
        vCenter = vCenter.replaceAll(element, record.printValue(element));
      });
    }

    // Get lengths
    double rest = (lwidth / height) - vCenter.length.toDouble();
    int l = (rest / 2).floor();

    var filler = " ";

    if ((vLeft.length > 0) &&
        (vLeft.substring(0, 1) == "┏" ||
            vLeft.substring(0, 1) == "┣" ||
            vLeft.substring(0, 1) == "┗" ||
            vLeft.substring(0, 1) == "━")) {
      filler = "━";
    }

    String sleft;
    if (alignLeft == -1) {
      sleft = justifyRight(vLeft, l, filler);
    } else {
      if (vLeft.length > 0 && vLeft[0] == "┃") {
        sleft = "┃" +
            justifyLeft(vLeft.substring(1, vLeft.length - 1), l - 1, filler);
      } else {
        sleft = justifyLeft(vLeft, l, filler);
      }
    }

    //String sleft = alignLeft == -1 ? justifyRight(vLeft, l, filler) :  justifyLeft(vLeft, l, filler);

    return sleft;
  }

  String rightDescription({WeightRecord record, int lwidth = 36}) {
    String vCenter = center;
    String vRight = right;

    if (record != null) {
      WeightRecord.names.keys.forEach((element) {
        vCenter = vCenter.replaceAll(element, record.printValue(element));
        vRight = vRight.replaceAll(element, record.printValue(element));
      });
    }

    // Get lengths
    double rest = (lwidth / height) - vCenter.length.toDouble();
    int l = (rest / 2).floor();
    int r = rest.floor() - l;

    var filler = " ";

    if ((vRight.length > 0) &&
        (vRight.substring(vRight.length - 1, vRight.length) == "┓" ||
            vRight.substring(vRight.length - 1, vRight.length) == "┫" ||
            vRight.substring(vRight.length - 1, vRight.length) == "┛" ||
            vRight.substring(vRight.length - 1, vRight.length) == "━")) {
      filler = "━";
    }

    String sright;

    if (alignRight == -1) {
      if (vRight.length > 0 && vRight[vRight.length - 1] == "┃") {
        sright = justifyRight(
                vRight.substring(0, vRight.length - 1), r - 1, filler) +
            "┃";
      } else {
        sright = justifyRight(vRight, r, filler);
      }
    } else {
      sright = justifyLeft(vRight, r, filler);
    }

    //String sright = alignRight == -1 ? justifyRight(vRight, r, filler) : justifyLeft(vRight, r, filler);

    return sright;
  }

  String centerDescription({WeightRecord record}) {
    String vLeft = left;
    String vCenter = center;

    if (record != null) {
      WeightRecord.names.keys.forEach((element) {
        vLeft = vLeft.replaceAll(element, record.printValue(element));
        vCenter = vCenter.replaceAll(element, record.printValue(element));
      });
    }

    return vCenter;
  }

  String posDescription(int pos, {WeightRecord record}) {
    switch (pos) {
      case -1:
        return leftDescription(record: record);
        break;
      case 0:
        return centerDescription(record: record);
        break;
      case 1:
        return rightDescription(record: record);
        break;
    }
    return "";
  }

  String fill(String s, WeightRecord record) {
    var out = s;
    if (record != null) {
      WeightRecord.names.keys.forEach((element) {
        out = out.replaceAll(element, record.printValue(element));
      });
    }
    return out;
  }

  String getLeft(WeightRecord record) {
    var s = fill(left, record);
    print("Left : $left, subst : $s");
    return s;
  }

  String getRight(WeightRecord record) {
    return fill(center, record);
  }

  String getCenter(WeightRecord record) {
    var s = fill(center, record);
    print("Left : $center, subst : $s");
    return s;
  }

  void setLeft(VariableInfo p) {
    print("Setting left");

    left = p.value;
    type = 0;
    if(height != 1 ){
      height = 1;
    }
  }

  void setCenter(VariableInfo p) {
    print("Setting center");

    center = p.value;
    type = 0;
    if(height != 1){
      height = 1;
    }

  }

  void setRight(VariableInfo p) {
    print("Setting right");

    right = p.value;
    type = 0;
    if(height != 1){
      height = 1;
    }


    alignRight = 1;
  }

  void setImage(Image img, w, h) {
    print("Setting image");

    image = img;
    type = 2;
    height = h.toDouble();
    width = w.toDouble();
  }

  void setBarcode(p) {
    center = p.value;
    type = 1;
    height = 4;
    width = 48;
  }

  Barcode getBarcode(int tipus) {

    switch(tipus){
      case 0:
        return Barcode.upcA();
        break;

      case 1:
        return Barcode.upcE(fallback: true);
        break;

      case 2:
        return Barcode.ean13();
        break;

      case 3:
        return Barcode.ean8();
        break;

      case 4:
        return Barcode.code39();
        break;

      case 5:
        return Barcode.itf();
        break;

      case 6:
        return Barcode.codabar();
        break;

      case 7:
        return Barcode.code93();
        break;

      case 8:
        return Barcode.code128();
        break;

      case 9:  return Barcode.qrCode();
      break;

    }

    return  null;

  }

  // posicio -1 left, 0 center, 1 right

  Widget build(int nitems, int posicio) {
    //print(description());
    if (type == 0) {
      return Text(
        posDescription(posicio),
        style: TextStyle(
            fontFamily: "Inconsolata",
            fontSize: 24 * height,
            fontWeight: weight,
            backgroundColor: nitems > 0 ? Colors.red : Colors.white),
      );
    } else if (type == 1 ) {
      return BarcodeWidget(
        barcode: getBarcode(barcodeType),
        data: fill(center, LineInfo.testRecord).toUpperCase(),
        width: width * 10,
        height: height * 20,
        backgroundColor: nitems > 0 ? Colors.red : Colors.white,
      );
    } else if (type == 2 ) {
      return image;
    } else {
      return Text(
        "***",
        style: TextStyle(
            fontFamily: "Inconsolata",
            fontSize: 24 * height,
            fontWeight: weight,
            backgroundColor: nitems > 0 ? Colors.red : Colors.white),
      );
    }
  }
/*
  Widget buildTarget(int item, MyHomePageState state) {

    if (type == 1 || type ==  2){
      return Container(
        width: getWidth(),
        height: getHeight(),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            DragTarget(builder:
                (context, List<VariableInfo> candidateData, rejectedData) {
              return Center(child: build(candidateData.length, 0));
            }, onWillAccept: (data) {
              if (data.title == "Logo" ||
                  data.title == "Barcode" ||
                  data.value.length == 0) {
                return true;
              }

              var first = data.value[0];
              var last = data.value[data.value.length - 1];

              if (item == 0 &&
                  ("┃┣╋┫┗┻┛".contains(first) || "┃┣╋┫┗┻┛".contains(last))) {
                return false;
              }
              return true;
            }, onAcceptWithDetails: (data) {
              if (data.data.title == "Barcode") {
                this.setBarcode(data.data);
                state.setState(() {

                });

              } else if (data.data.title == "Logo") {
                var logo =
                new Image.memory(img.encodePng(state.label.blackAndWhite));
                setImage(logo, state.label.logoWidth, state.label.logoHeight);
                state.setState(() {

                });

              } else {
                // Left
                state.label.setCenterValue(item, data.data);
                state.setState(() {

                });

              }
            }), // End of DragTarget

          ],
        ), //End of row
      ); // End of container
    } else {
      return Container(
        width: getWidth(),
        height: getHeight(),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Row(
          children: [
            DragTarget(builder:
                (context, List<VariableInfo> candidateData, rejectedData) {
              return Center(child: build(candidateData.length, -1));
            }, onWillAccept: (data) {
              if (data.title == "Logo" ||
                  data.title == "Barcode" ||
                  data.value.length == 0) {
                return true;
              }

              var first = data.value[0];
              var last = data.value[data.value.length - 1];

              if (item == 0) {
                if ("┃┣╋┫┗┻┛┓┳".contains(first)) {
                  return false;
                }
              } else {
                if ("╋┫┻┛┓┳".contains(first)) {
                  return false;
                }
              }
              if (data.title == "Barcode" || data.title == "Logo") {
                return false;
              }
              return true;
            }, onAcceptWithDetails: (data) {
              if (data.data.title == "Barcode") {
                this.setBarcode(data.data);
                state.setState(() {

                });
              } else if (data.data.title == "Logo") {
                var logo =
                new Image.memory(img.encodePng(state.label.blackAndWhite));
                setImage(logo, state.label.logoWidth, state.label.logoHeight);
                state.setState(() {

                });

              } else {
                // Left
                state.label.setLeftValue(item, data.data);
                state.setState(() {

                });

              }
            }), // End of DragTarget

            DragTarget(builder:
                (context, List<VariableInfo> candidateData, rejectedData) {
              return Center(child: build(candidateData.length, 0));
            }, onWillAccept: (data) {
              if (data.title == "Logo" ||
                  data.title == "Barcode" ||
                  data.value.length == 0) {
                return true;
              }

              var first = data.value[0];
              var last = data.value[data.value.length - 1];

              if (item == 0 &&
                  ("┃┣╋┫┗┻┛".contains(first) || "┃┣╋┫┗┻┛".contains(last))) {
                return false;
              }
              return true;
            }, onAcceptWithDetails: (data) {
              if (data.data.title == "Barcode") {
                this.setBarcode(data.data);
                state.setState(() {

                });

              } else if (data.data.title == "Logo") {
                var logo =
                new Image.memory(img.encodePng(state.label.blackAndWhite));
                setImage(logo, state.label.logoWidth, state.label.logoHeight);
                state.setState(() {

                });

              } else {
                // Left
                state.label.setCenterValue(item, data.data);
                state.setState(() {

                });

              }
            }), // End of DragTarget

            DragTarget(builder:
                (context, List<VariableInfo> candidateData, rejectedData) {
              return Center(child: build(candidateData.length, 1));
            }, onWillAccept: (data) {
              if (data.title == "Logo" ||
                  data.title == "Barcode" ||
                  data.value.length == 0) {
                return true;
              }

              var first = data.value[0];
              var last = data.value[data.value.length - 1];

              if (item == 0) {
                if ("┏┳┃┣╋┫┗┻┛".contains(last)) {
                  return false;
                }
              } else {
                if ("┏┳┣╋┗┻".contains(last)) {
                  return false;
                }
              }
              if (data.title == "Barcode" || data.title == "Logo") {
                return false;
              }

              return true;
            }, onAcceptWithDetails: (data) {
              if (data.data.title == "Barcode") {
                this.setBarcode(data.data);
                state.setState(() {

                });

              } else if (data.data.title == "Logo") {
                var logo =
                new Image.memory(img.encodePng(state.label.blackAndWhite));
                setImage(logo, state.label.logoWidth, state.label.logoHeight);
                state.setState(() {

                });

              } else {
                // Left
                state.label.setRightValue(item, data.data);
                state.setState(() {

                });

              }
            }), // End of DragTarget
          ],
        ), //End of row
      ); // End of container
    }
  }

  */



  double getHeight() {
    if (type == 0) {
      return height * 24;
    }
    if (type == 1) {
      return height * (24);
    } else if (type == 2) {
      return height;
    }else{
      return 0;
    }
  }

  double getWidth() {
    if (type == 0) {
      var size = textSize(description(),
          TextStyle(fontFamily: "Inconsolata", fontSize: 24 * height));

      return size.width + 5;
    } else if (type == 1) {
      print(width * 12);
      return width * 12;
    } else if (type == 2) {
      return width;
    }else {
      return 0;
    }
  }
}
