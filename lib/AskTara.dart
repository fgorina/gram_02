import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GRAMModel.dart';
import 'screensize_reducers.dart';
import 'NumPad.dart';
import 'ActiveText.dart';
import "ColorCompatibility.dart";
import 'GRAMMessage.dart';
import 'TareSelector.dart';
import 'TareRecord.dart';
import 'Measurement.dart';
import 'Dialogs.dart';
import 'IconAndFilesUtilities.dart';

class AskTara extends StatefulWidget {
  _AskTaraState createState() => _AskTaraState();
}

class _AskTaraState extends State<AskTara> {
  GRAMModel model = GRAMModel.shared;
  String tara = "0";
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  void keyPressed(String key) {
    setState(() {
      if (key == "←") {
        if (tara.length > 1) {
          tara = tara.substring(0, tara.length - 1);
        } else {
          tara = "0";
        }
      } else if (key == "C") {
        tara = "0";
      } else if (key == "✓") {
        setTara();
      } else if (key == "+") {
        addTara();
      } else if (tara.length < 8) {
        if (tara == "0") {
          tara = key;
        } else {
          tara = tara + key;
        }
      } else {
        // System beep
      }
    });
  }

  void close() {
    Navigator.pop(context);
  }

  void openSelector() async {
    final Measurement result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TareSelector()));
    if (result != null) {
      setState(() {
        tara = result
            .valueFormatted(model.decimalPointPosition, grouping: false)
            .replaceAll(",", ".");
      });
    }
  }

  void addTara() {
    double value = double.parse(tara);
    Measurement m = Measurement(value, model.scaleUnit);
    displayDialog(context, "Enter Tare Name", "Name", _textEditingController,
        (name) => TareDatabase.shared.add(name, m));
  }

  void setTara() {
    double value = double.parse(tara);
    model.connection.enqueueMessage(GRAMMessage.setTareValue(
        value, model.modes[0].e, model.decimalPointPosition));
    close();
  }

  Widget buildWidgetVertical() {
    var tareColor = CC.widgetColor(WN.tareButtonColor, 0);
    var tareTextColor = CC.widgetColor(WN.tareButtonText, 0);

    return Container(
      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 0.0),
      decoration:
          BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              activeIcon(Icons.cancel, close, context),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                  height: 24 * 0.9,
                  width: 72,
                  child: getImage("tare", model.darkMode ? 1 : 0)),
              Container(
                width: 200,
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CC.widgetColor(WN.normalTextColor, 0),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(tara,
                        style: TextStyle(
                          color: CC.widgetColor(WN.normalTextColor, 0),
                          fontSize: 46,
                        )),
                  ],
                ),
              ),
              activeIcon(Icons.menu, openSelector, context),
              Spacer(),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: numpad(context, "+", "✓", keyPressed,
                colorButton2: tareColor, textColorButton2: tareTextColor,),
          ),
          Spacer(),
        ],
      ), // End of Column
    );
  }

  Widget buildWidgetHorizontal() {
    var tareColor = CC.widgetColor(WN.tareButtonColor, 0);
    var tareTextColor = CC.widgetColor(WN.tareButtonText, 0);
    double bSize =  screenHeight(context) < 400 ? 50.0 : 70.0;

    print("Size: ${bSize}");

    return Container(
        height: screenHeight(context),
        width: screenWidth(context),
        padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 0.0),
        decoration:
            BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: screenWidth(context) * 0.5,
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Container(
                            height: 24 * 0.9,
                            width: 72,
                            child: getImage("tare", model.darkMode ? 1 : 0)),
                        Container(
                          width: 200,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CC.widgetColor(WN.normalTextColor, 0),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(tara,
                                  style: TextStyle(
                                    color:
                                        CC.widgetColor(WN.normalTextColor, 0),
                                    fontSize: 46,
                                  )),
                            ],
                          ),
                        ),
                        activeIcon(Icons.menu, openSelector, context),

                      ],
                    ),
                  ],
                ), // End of Column
              ),
              Container(
                width: screenWidth(context) * 0.4,
                alignment: Alignment.topLeft,
                child: Column(children: [
                  numpad(context, "+", "✓", keyPressed,
                      colorButton2: tareColor, textColorButton2: tareTextColor, buttonSize: bSize),
                ]),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  activeIcon(Icons.cancel, close, context),
                  Spacer(),
                ],
              ),
              Spacer(),
            ]));
  }

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      body: (screenHeight(context) > screenWidth(context)) ? buildWidgetVertical() :  buildWidgetHorizontal(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
