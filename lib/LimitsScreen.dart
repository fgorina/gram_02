import 'package:flutter/material.dart';
import 'Visor.dart';
import 'GRAMModel.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';

import 'ColorCompatibility.dart';

import 'AskLimits.dart';
import 'SlideRoutes.dart';
import 'MainHeader.dart';
import 'ToggleQrProtocol.dart';

class LimitsScreen extends StatefulWidget  {
  _LimitsScreenState createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> with ToggleQrProtocol {
  GRAMModel model = GRAMModel.shared;

  @override
  void initState() {
    super.initState();
    model.addSubscriptor(this);
  }

  void modelUpdated() {
    setState(() {});
  }

  void dummy(bool newValue) {
    print("New Value : $newValue");
  }

  void close() {
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }

  void toggleQr(){
    setState(() {
      model.showQr = !model.showQr;
    });
  }

  Widget buildWidget() {
    // Compute visor height

    var colorHigh = CC.widgetColor(WN.backgroundColor, model.theme);
    var colorLow = CC.widgetColor(WN.backgroundColor, model.theme);

    if (model.limitsEnabled && !model.zero) {
      colorHigh = model.weight > model.upperLimit
          ? Colors.red
          : CC.labelColor(CL.clear, 0);
      colorLow = model.weight < model.lowLimit
          ? Colors.yellow
          : CC.labelColor(CL.clear, 0);
    }

    return Container(
      decoration:
          BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
      height: screenHeight(context),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildMainHeader(model, null, null, null, null,
              null, context),

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            child: activeImage("back_left", close, context),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context, SlideUpRoute(widget: AskLimits())),
                  child: CustomPaint(
                    size: Size(
                      screenWidth(context) - 50.0,
                      screenHeight(context) / 4.0,
                    ),
                    painter: DrawTriangle(0, colorHigh),
                  ),
                ),
                buildVisor(model, context, this, showFlags: false, radius: 0.0),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context, SlideUpRoute(widget: AskLimits())),
                  child: CustomPaint(
                    size: Size(
                      screenWidth(context) - 50.0,
                      screenHeight(context) / 4.0,
                    ),
                    painter: DrawTriangle(1, colorLow),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
        ],
      ), // End of Row
      ]), // End of Column



    ); // End of Container
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
      body: buildWidget(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Direction = 0 -> Point Up// Direction = 1 -> Point Down

class DrawTriangle extends CustomPainter {
  Paint _paint;
  int _direction;

  DrawTriangle(dir, color) {
    _direction = dir;
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    if (_direction == 0) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2.0, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2.0, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
