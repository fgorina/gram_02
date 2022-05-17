import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GRAMModel.dart';
import 'screensize_reducers.dart';
import 'NumPad.dart';
import 'ActiveText.dart';
import "ColorCompatibility.dart";
import 'IconAndFilesUtilities.dart';

class AskLimits extends StatefulWidget {
  _AskLimitsState createState() => _AskLimitsState();
}

class _AskLimitsState extends State<AskLimits> {
  GRAMModel model = GRAMModel.shared;
  List<String> limits = ["0", "0"];
  int selectedLimit = 0; // 0 -> high, 1 -> Low

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);

    if (model.lowLimit.value != 0.0) {
      var str = model.lowLimit
          .valueFormatted(model.decimalPointPosition)
          .replaceAll(",", ".");
      limits[1] = str;
    }
    if (model.upperLimit.value != 0.0) {
      var str = model.upperLimit
          .valueFormatted(model.decimalPointPosition)
          .replaceAll(",", ".");
      limits[0] = str;
    }
  }

  void keyPressed(String key) {
    setState(() {
      if (key == "←") {
        if (limits[selectedLimit].length > 1) {
          limits[selectedLimit] = limits[selectedLimit]
              .substring(0, limits[selectedLimit].length - 1);
        } else {
          limits[selectedLimit] = "0";
        }
      } else if (key == "C") {
        limits[selectedLimit] = "0";
      } else if (key == "✓") {
        setLimits();
      } else if (limits[selectedLimit].length < 8) {
        if (limits[selectedLimit] == "0") {
          limits[selectedLimit] = key;
        } else {
          limits[selectedLimit] = limits[selectedLimit] + key;
        }
      } else {
        // System beep
      }
    });
  }

  void close() {
    Navigator.pop(context);
  }

  void openSelector() {}

  void setLimits() {
    model.setLimits(double.parse(limits[1]), double.parse(limits[0]));
    model.limitsEnabled = true;
    print("Enabled Limits");

    close();
  }

  Widget buildWidgetVertical() {
    var tareColor = CC.widgetColor(WN.buttonColor, 0);
    var tareTextColor = CC.widgetColor(WN.buttonTextColor, 0);
    var border0 = selectedLimit == 0 ? 5.0 : 0.0;
    var border1 = selectedLimit == 1 ? 5.0 : 0.0;

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
              getSizedImage("triangleUp", 0, 50.0, 41.0),
              GestureDetector(
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CC.widgetColor(WN.normalTextColor, 0),
                      width: border0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(limits[0],
                          style: TextStyle(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            fontSize: 46,
                          )),
                    ],
                  ),
                ),
                onTap: () => setState(() {
                  print("zero");
                  selectedLimit = 0;
                }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Text("→T←", style: TextStyle(fontSize: 24)),
              getSizedImage("triangleDown", 0, 50.0, 41.0),
              GestureDetector(
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CC.widgetColor(WN.normalTextColor, 0),
                      width: border1,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(limits[1],
                          style: TextStyle(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            fontSize: 46,
                          )),
                    ],
                  ),
                ),
                onTap: () => setState(() {
                  print("One");
                  selectedLimit = 1;
                }),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: numpad(context, null, "✓", keyPressed,
                colorButton2: tareColor, textColorButton2: tareTextColor),
          ),
          Spacer(),
        ],
      ), // End of Column
    );
  }

  Widget buildWidgetHoritzontal() {
    var tareColor = CC.widgetColor(WN.buttonColor, 0);
    var tareTextColor = CC.widgetColor(WN.buttonTextColor, 0);
    var border0 = selectedLimit == 0 ? 5.0 : 0.0;
    var border1 = selectedLimit == 1 ? 5.0 : 0.0;
    double bSize =  screenHeight(context) < 400 ? 55.0 : 70.0;

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
            width: screenWidth(context) * 0.4,
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getSizedImage("triangleUp", 0, 50.0, 41.0),
                    GestureDetector(
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            width: border0,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(limits[0],
                                style: TextStyle(
                                  color: CC.widgetColor(WN.normalTextColor, 0),
                                  fontSize: 46,
                                )),
                          ],
                        ),
                      ),
                      onTap: () => setState(() {
                        print("zero");
                        selectedLimit = 0;
                      }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Text("→T←", style: TextStyle(fontSize: 24)),
                    getSizedImage("triangleDown", 0, 50.0, 41.0),
                    GestureDetector(
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CC.widgetColor(WN.normalTextColor, 0),
                            width: border1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(limits[1],
                                style: TextStyle(
                                  color: CC.widgetColor(WN.normalTextColor, 0),
                                  fontSize: 46,
                                )),
                          ],
                        ),
                      ),
                      onTap: () => setState(() {
                        print("One");
                        selectedLimit = 1;
                      }),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ), // End of Column
          ),
          Container(
            width: screenWidth(context) * 0.5,
            alignment: Alignment.topLeft,
            child: Column(children: [
              numpad(context, null, "✓", keyPressed,
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
        ],
      ), // End of Column
    );
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
      body: (screenHeight(context) > screenWidth(context)) ? buildWidgetVertical() :  buildWidgetHoritzontal(),
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
