import 'package:flutter/material.dart';
import 'GRAMConnection.dart';
import 'screensize_reducers.dart';
import 'GRAMModel.dart';
import 'ColorCompatibility.dart';
import 'DataTypesUtilities.dart';
import 'ActiveText.dart';
import 'SlideRoutes.dart';
import 'Units.dart';


import 'ScaleSelector.dart';

Widget buildMainHeader(
    GRAMModel model,
    Function connect,
    Function disconnect,
    Function userDialog,
    Function customerDialog,
    Function itemDialog,
    context) {
  if (screenWidth(context) < 500) {
    return buildShortHeader(model, connect, disconnect, userDialog,
        customerDialog, itemDialog, context);
  } else {
    return buildWideHeader(model, connect, disconnect, userDialog,
        customerDialog, itemDialog, context);
  }
}

Widget iconForConnectionState(GRAMModel model, Function connect,
    Function disconnect, BuildContext context) {
  switch (model.connection.connectionState) {
    case GRAMConnectionState.notConnected:
      return activeIcon(Icons.portable_wifi_off, connect, context, size: 18.0);

      break;

    case GRAMConnectionState.tryingToGetNetwork:
      return activeIcon(Icons.wifi, disconnect, context,
          size: 18.0, color: Colors.purple);
      break;

    case GRAMConnectionState.tryingToConnect:
      return activeIcon(Icons.wifi, disconnect, context,
          size: 18.0, color: Colors.red);
      break;

    case GRAMConnectionState.connected:
      return activeIcon(Icons.wifi, disconnect, context,
          size: 18.0, color: Colors.orange);
      break;

    case GRAMConnectionState.streaming:
      return activeIcon(Icons.wifi, disconnect, context,
          size: 18.0, color: Colors.green);
      break;
  }
  return null;
}

String textForScaleNameWidget(GRAMModel model) {
  if (model.isStreaming()) {
    return model.scaleName;
  } else if (model.isConnected()) {
    if (model.scale != null) {
      return model.scale.name;
    } else {
      return "Unknown";
    }
  } else {
    return "Disconnected";
  }
}

Widget buildShortHeader(
    GRAMModel model,
    Function connect,
    Function disconnect,
    Function userDialog,
    Function customerDialog,
    Function itemDialog,
    context) {
  if (model != null) {
    return Container(
      height: 90,
      width: screenWidth(context),
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      decoration: BoxDecoration(
        color: CC.widgetColor(WN.backgroundColor, model.theme),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () =>
                Navigator.push(context, SlideUpRoute(widget: ScaleSelector())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    activeIcon(
                        model.isConnected()
                            ? Icons.wifi
                            : Icons.portable_wifi_off,
                        model.isConnected() ? disconnect : connect,
                        context,
                        size: 18.0),
                    Text(textForScaleNameWidget(model),
                        style: TextStyle(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            fontWeight: FontWeight.bold)),
                    Text(model.isConnected()
                        ? (model.sealed
                        ? "   XTREM TC12136  ${model.serialNumber}  "
                        : "   XTREM  ${model.serialNumber}")
                        : ""),
                    Container(
                        height: 20,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                        child: class_iii_widget(model)

                      //FlatButton(child: getImage("class_III_icon", 0),),
                    ),
                    // Icon(model.sealed ? Icons.lock : Icons.lock_open, size: 15.0),
                  ],
                ), // Scale
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Max: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      model.isStreaming()
                          ? formattedDecs(model.modes[0].max, 0) +
                              " " +
                              units[model.scaleUnit].symbol
                          : "",
                      textAlign: TextAlign.left,
                      style: TextStyle(),
                    ),
                  ],
                ), // Max
                Row(
                  children: <Widget>[
                    Text(
                      "e: ",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      model.isStreaming()
                          ? formattedDecs(model.modes[1].e,
                                  model.decimalPointPosition) +
                              " " +
                              units[model.scaleUnit].symbol
                          : "",
                      textAlign: TextAlign.left,
                      style: TextStyle(),
                    ),
                  ],
                ), // Max
              ], // End of Scale widgets
            ), // Scale
          ),
          Spacer(),
          GestureDetector(
            onTap: itemDialog,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(model.tr.localize("User") + ": ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      model.getUser(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(),
                    ),
                  ],
                ), // Scale
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(model.tr.localize("Customer") + ": ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      model.getCustomer(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(),
                    ),
                  ],
                ), //
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(model.tr.localize("Item") + ": ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      model.getItem(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(),
                    ),
                  ],
                ), //
              ], // End of Scale widgets
            ),
          ), // End og gesture
        ],
      ),
    ); // End of First Row

  }
  return null;
}

Widget class_iii_widget(GRAMModel model) {
  if (model.isConnected() && model.sealed) {
    return Container(
        height: 20,
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
        child: Image.asset("class_III_icon_clar.png")

        //FlatButton(child: getImage("class_III_icon", 0),),
        );
  } else {
    return Text(" ");
  }
}

List<Widget> scaleSpecs(GRAMModel model) {
  switch (model.rangeMode) {
    case 0:
      return scaleSpecs0(model);
      break;
    case 1:
      return scaleSpecs1(model);
      break;
    case 2:
      return scaleSpecs1(model);
      break;
  }

  return scaleSpecs0(model);
}

List<Widget> scaleSpecs0(GRAMModel model) {

  var u = units[model.scaleUnit];
  var c = "x";

  if (u != null){
    c = u.symbol;
  }
  return [
    Row(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Max ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].max, 0) +
                    " " +
                    c
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Min
      Text("    "),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Min ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e * 20.0, 0) +
                    " " +
                    c
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Max
      Text("    "),
      Row(
        children: <Widget>[
          Text(
            "e = ",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e, model.decimalPointPosition) +
                    " " +
                    c
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // e
    ]),
  ]; // Range 0
}

List<Widget> scaleSpecs1(GRAMModel model) {
  return [
    Row(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Max ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].max, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Min
      Text("    "),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Min ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e * 20.0, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Max
      Text("    "),
      Row(
        children: <Widget>[
          Text(
            "e = ",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e, model.decimalPointPosition) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // e
    ]),
    Row(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Max ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].max, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Max
      Text("    "),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Min ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].e * 20.0, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Min
      Text("    "),
      Row(
        children: <Widget>[
          Text(
            "e = ",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].e, model.decimalPointPosition) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // e
    ]),
  ];
}

List<Widget> scaleSpecs2(GRAMModel model) {

  return [
    Row(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Max ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].max, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(" / ", style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].max, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Min
      Text("    "),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Min ",
              style: TextStyle(
                  color: CC.widgetColor(WN.normalTextColor, 0),
                  fontWeight: FontWeight.bold)),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e * 20.0, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(" / ", style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].e * 20.0, 0) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // Max
      Text("    "),
      Row(
        children: <Widget>[
          Text(
            "e = ",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[0].e, model.decimalPointPosition) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
          Text(" / ", style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),),
          Text(
            model.isStreaming()
                ? formattedDecs(model.modes[1].e, model.decimalPointPosition) +
                " " +
                units[model.scaleUnit].symbol
                : "",
            textAlign: TextAlign.left,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)),
          ),
        ],
      ), // e
    ]),
  ];
}

Widget buildWideHeader(
    GRAMModel model,
    Function connect,
    Function disconnect,
    Function userDialog,
    Function customerDialog,
    Function itemDialog,
    context) {
  if (model != null) {
    return Container(
      height: 60,
      width: screenWidth(context),
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      decoration: BoxDecoration(
        color: CC.widgetColor(WN.backgroundColor, model.theme),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () =>
                Navigator.push(context, SlideUpRoute(widget: ScaleSelector())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    activeIcon(
                        model.isConnected()
                            ? Icons.wifi
                            : Icons.portable_wifi_off,
                        model.isConnected() ? disconnect : connect,
                        context,
                        size: 18.0),
                    Text(textForScaleNameWidget(model),
                        style: TextStyle(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            fontWeight: FontWeight.bold)),
                    Text(model.isConnected()
                        ? (model.sealed
                            ? "   XTREM TC12136  ${model.serialNumber}  "
                            : "   XTREM  ${model.serialNumber}")
                        : ""),
                    Container(
                        height: 20,
                        padding: EdgeInsets.only(
                            left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
                        child: class_iii_widget(model)

                        //FlatButton(child: getImage("class_III_icon", 0),),
                        ),
                    // Icon(model.sealed ? Icons.lock : Icons.lock_open, size: 15.0),
                  ],
                ), // Scale

              ] + scaleSpecs( model), // End of Scale widgets
            ), // Scale
          ),
          Spacer(),
          GestureDetector(
            onTap: itemDialog,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    activeText(
                      Text(model.tr.localize("User") + ": ",
                          style: TextStyle(
                              color: CC.widgetColor(WN.normalTextColor, 0),
                              fontWeight: FontWeight.bold)),
                      userDialog,
                      context,
                    ),
                    Text(
                      model.getUser(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: CC.widgetColor(WN.normalTextColor, 0)),
                    ),
                  ],
                ), // Scale

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    activeText(
                      Text(model.tr.localize("Customer") + ": ",
                          style: TextStyle(
                              color: CC.widgetColor(WN.normalTextColor, 0),
                              fontWeight: FontWeight.bold)),
                      customerDialog,
                      context,
                    ),
                    Text(
                      model.getCustomer(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: CC.widgetColor(WN.normalTextColor, 0)),
                    ),
                  ],
                ), //

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    activeText(
                      Text(model.tr.localize("Item") + ": ",
                          style: TextStyle(
                              color: CC.widgetColor(WN.normalTextColor, 0),
                              fontWeight: FontWeight.bold)),
                      itemDialog,
                      context,
                    ),
                    Text(
                      model.getItem(max: 24),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: CC.widgetColor(WN.normalTextColor, 0)),
                    ),
                  ],
                ), //
              ], // End of Scale widgets
            ),
          ),
        ],
      ),
    ); // End of First Row

  }

  return null;
}
