import 'package:flutter/material.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'ScaleDatabase.dart';
import 'GRAMModel.dart';
import 'Scale.dart';
import 'SlideRoutes.dart';
import 'ScaleEditor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'SerialTester.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';


class ScaleSelector extends StatefulWidget {
  _ScaleSelectorState createState() => _ScaleSelectorState();
}

class _ScaleSelectorState extends State<ScaleSelector> {
  ScaleDatabase scales = ScaleDatabase.shared;
  GRAMModel model = GRAMModel.shared;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
  }

  void add() {
    var scale = Scale();
    Navigator.push(context, SlideUpRoute(widget: ScaleEditor(scale)));
  }

  void serialTesterCallback(){


    print("Speed is ${model.scale.port}");

    model.connection.connectionRetries = 0;

    if (model.isConnected()) {
      model.connection.disconnect();
      model.connection.connect();
    }
    else {
      model.connection.connect();
    }
    this.close();

  }
  void select(String name) {
    model.connection.disconnect();  // Afegit

    var scale = scales.scaleForName(name);
    model.scale = scale;

    if( scale.ssid.startsWith("/dev")) {
      model.tester.device = scale.ssid;


      // 115200, 57600, 38400, 19200, 9600
      int speed = model.tester.testConfigurations(
          [9600, 19200, 38400, 57600, 115200]);

      model.scale.port = speed;
     }

    model.saveDefaults();

    model.connection.connectionRetries = 0;

    if (model.isConnected()) {
      model.connection.disconnect();
      model.connection.connect();
    }
    else {
      model.connection.connect();
    }
    this.close();

    return;

    }

  void delete(String name){
    setState(() {
      scales.deleteScale(name);
    });
  }

  void close() {
    Navigator.pop(context);
  }

  void scan(){
    setState((){
      _scanning = true;
    });
     model.connection.active = true;
     model.connection.scanScales(scaleUpdated);
  }
  void scaleUpdated(){
    setState((){
      _scanning = false;
    });
  }
  Widget buildScalesList() {
    List<Widget> children = scales
        .scaleNames()
        .map(
          (name) =>


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Material(
                child: InkWell(
                  child: Container(
                    alignment: Alignment(-1.0, 0.0),
                    height: 40,
                    child: Text(name,
                        style: TextStyle(fontSize: 18.0)),
                  ),
                  onTap: () => select(name),
                  highlightColor: Colors.cyan,
                  focusColor: Colors.red,
                  splashColor: Colors.green,
                ),
              ),
            ),
            activeIcon(Icons.clear, name != "Config" ? () => delete(name) : null, context,),
          ],
        ),


    )
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget buildWidget() {
    return
      ModalProgressHUD(
        inAsyncCall: _scanning,
        child: Container(
      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              activeIcon(Icons.add, add, context,),
              Spacer(),
              activeIcon(Icons.refresh, scan, context,),
              Spacer(),
              activeIcon(Icons.cancel, close, context,),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                  left: 0.0, top: 20.0, right: 0.0, bottom: 0.0)),
          buildScalesList(),
          Spacer(),
        ],
      ), // END OF COLUMN
    ), // End of Container



      ); // End of ModalProgrressHUD
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
