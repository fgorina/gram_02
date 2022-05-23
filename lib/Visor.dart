import 'package:flutter/material.dart';
import 'GRAMConnection.dart';
import 'GRAMMessage.dart';
import 'screensize_reducers.dart';
import 'GRAMModel.dart';
import 'ColorCompatibility.dart';
import 'IconAndFilesUtilities.dart';
import 'ToggleQrProtocol.dart';
import 'package:flutter/foundation.dart';

Widget buildVisor(GRAMModel model, context, ToggleQrProtocol father,
    {showFlags: true, radius: 10.0}) {
  List<Widget> children = [];

  var backColor = CC.widgetColor(WN.backgroundColor, model.theme);
  if (model.isConnected() && model.limitsEnabled && !model.zero) {
    if (model.weight > model.upperLimit) {
      backColor = Colors.red;
    } else if (model.weight < model.lowLimit) {
      backColor = Colors.yellow;
    } else {
      backColor = Colors.green;
    }
  }

  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;


  bool testVisor = false;

  String visorForState(GRAMConnectionState state) {
    switch (state) {
      case GRAMConnectionState.notConnected:
        return "----";
        break;

      case GRAMConnectionState.tryingToGetNetwork:
        return "---";
        break;
      case GRAMConnectionState.tryingToConnect:
        return "--";
        break;
      case GRAMConnectionState.connected:
        return "-" ;
        break;

      case GRAMConnectionState.streaming:
        return "";
        break;
    }
    return "";
  }

  Widget presentedItems;
  if (!model.isStreaming() && !testVisor) {
    presentedItems = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            visorForState(model.connection == null? GRAMConnectionState.notConnected  : model.connection.connectionState),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: width > 700.0 && height >= 400.0 ? 140 : 80,  // Originalment era 80
                color: CC.widgetColor(WN.digitsTextColor, model.theme)),
          ),
        ]);
  } else {
    if (model.deviceState == DeviceError.noError || testVisor) {
      presentedItems = GestureDetector(
        onTap: father.toggleQr,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              model.showQr  && width > 700 && (model.stable || testVisor)
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: 10.0, top: 0.0, right: 0.0, bottom: 0.0),
                      child: model.presentedWeight.qrcode(
                          model.decimalPointPosition,
                          size: width > 700.0 && height >= 400.0 ? 100 : 80,
                          bgColor: backColor,
                      withUnits: model.sealed),
                    )
                  : Text(""),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 0.0, right: 10.0, bottom: 0.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center, // era baseline
                    //textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        model.highResolution
                            ? model.presentedWeight.valueBeginFormatted(
                                model.decimalPointPosition,
                                grouping: false)
                            : model.presentedWeight.valueFormatted(
                                model.decimalPointPosition,
                                grouping: false),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: width > 700.0 && height >= 400.0 ? 140 : 80,  // Originalment era 80
                            color: CC.widgetColor(
                                WN.digitsTextColor, model.theme)),
                      ),
                      Text(
                        model.highResolution
                            ? model.presentedWeight.valueRestFormatted(
                                model.decimalPointPosition,
                                grouping: false)
                            : "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize:   width > 700.0 && height >= 400.0 ? 140 : 80,  // Originalment era 80
                            color: CC.widgetColor(
                                WN.inactiveButtonColor, model.theme)),
                      ),
                      Text(
                        model.nWeight.symbol(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: width > 700.0 && height >= 400.0 ? 80 : 40,
                            color: CC.widgetColor(
                                WN.digitsTextColor, model.theme)),
                      ),

                      Container(
                        height: 120,
                        width: 15,

                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              model.rangeMode == 1 ?
                              Text("R${model.range}",style: TextStyle(fontWeight: FontWeight.bold),)
                              :
                          Text(""),
                              Spacer(),

                            ]

                        ),

                      ),
                    ]),
              ),
            ]),
      );
    } else {
      var message = deviceErrorString[model.deviceState];
      presentedItems = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: width > 700.0 && height >= 400.0 ? 140 : 80,  // Originalment era 80
                  color: CC.widgetColor(WN.digitsTextColor, model.theme)),
            ),
          ]);
    }
  }

  if (showFlags) {
    children.add(
      SizedBox(
        height: 30.0,
        width: screenWidth(context) * 0.9,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Spacer(flex:8),
              Text(model.stable && model.isConnected() ? "⦿": " ",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
              Spacer(),
              Container(
                width: 25,
                height: 25,
                child: model.zero && model.isConnected()
                    ? getImage("zero", 0)
                    : Text("   "),
              ),
              //Text(
              //  model.zero && model.isConnected() ? "→0←" : "   ",
              //   textAlign: TextAlign.center,
              //),
              Spacer(),
              Text(
                model.tareOn && model.isConnected() && model.tareMode == 0
                    ? "T"
                    : (model.tareOn &&
                            model.isConnected() &&
                            model.tareMode == 1
                        ? "PT"
                        : " "),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Text(
                model.netWeight && model.isConnected() ? "N" : " ",
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 8),
            ]),
      ),
    );
  }

  children.add(
    Container(
        height: width > 700.0 && height >= 400.0 ? 140 : 90,  // Originalment era 80
        //width: screenWidth(context)*0.9,

        decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            )),
        child: presentedItems),
  );
  if (showFlags) {
    children.add(Padding(
        padding: EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  model.tr.localize("Tare") + ": ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(model.isConnected()
                    ? model.tare.formatted(model.decimalPointPosition)
                    : ""),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  model.tr.localize("Gross W") + ": ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(model.isConnected()
                    ? model.weight.formatted(model.decimalPointPosition)
                    : ""),
              ],
            ),
          ],
        )));
  }

  if (model != null) {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, children: children);
  }

  return Text("Error");
}
