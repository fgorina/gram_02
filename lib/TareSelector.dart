import 'package:flutter/material.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'GRAMModel.dart';
import 'ColorCompatibility.dart';
import 'TareRecord.dart';
import 'Measurement.dart';
import 'package:flutter/cupertino.dart';

class TareSelector extends StatefulWidget {
  _TareSelectorState createState() => _TareSelectorState();
}

class _TareSelectorState extends State<TareSelector> {
  TareDatabase tares = TareDatabase.shared;
  GRAMModel model = GRAMModel.shared;

  @override
  void initState() {
    super.initState();
  }

  void select(String name) {
    var tare = tares.tareForName(name);
    close(measurement: tare.tare);
  }

  void delete(String name) {
    setState(() {
      tares.deleteTare(name);
    });
  }

  void close({Measurement measurement}) {
    if (measurement != null) {
      Navigator.pop(context, measurement);
    } else {
      Navigator.pop(context);
    }
  }

  Widget buildTaresList() {
    List<Widget> children = tares
        .tareNames()
        .map(
          (name) => Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Material(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
                        alignment: Alignment(-1.0, 0.0),
                        height: 40,
                        child: Dismissible(
                          key: ValueKey(name),
                          background: Container(color: Colors.red),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(name, style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0), fontSize: 18.0)),
                                Text(
                                    tares
                                        .tareForName(name)
                                        .tare
                                        .formatted(model.decimalPointPosition),
                                    style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0), fontSize: 18.0)),
                              ]),
                          onDismissed: (direction) {
                            tares.deleteTare(name);
                          },
                        ),
                      ),
                      onTap: () => select(name),
                      highlightColor: Colors.cyan,
                      focusColor: Colors.red,
                      splashColor: Colors.green,
                    ),
                  ),
                ),
                activeIcon(
                  Icons.clear,
                  () => delete(name),
                  context,
                ),
              ],
            ),
            Divider(),
          ]),
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
    return Container(
      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 20.0),
      decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              activeIcon(
                Icons.cancel,
                close,
                context,
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                  left: 0.0, top: 20.0, right: 0.0, bottom: 0.0)),
          buildTaresList(),
          Spacer(),
        ],
      ), // END OF COLUMN
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
