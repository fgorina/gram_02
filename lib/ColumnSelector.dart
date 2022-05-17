import 'package:flutter/material.dart';
import 'GRAMModel.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'LabeledSwitch.dart';
import 'ColorCompatibility.dart';


class ColumnSelector extends StatefulWidget {


  _ColumnSelectorState createState() => _ColumnSelectorState();
}


class _ColumnSelectorState extends State<ColumnSelector> {


  GRAMModel model = GRAMModel.shared;

  @override
  void initState(){
    super.initState();
  }


  void dummy(bool newValue){
    print("New Value : $newValue");
  }


  void close(){
    Navigator.pop(context);
  }

  Widget columnSwitch(DisplayFields field){

    return Container(height: 40, child: labeledSwitch(model.tr.localize(displayFieldsTitles[field]), model.displayedFields[field],  (bool v) {
      setState(() {
        model.displayedFields[field] = v;
      });

    }));
  }


  Widget buildWidget(){

    return Container(
      height: screenHeight(context),
      width: screenWidth(context),
      padding: EdgeInsets.only(left: 30, top: 0.0, right: 20, bottom: 0.0),
      decoration:  BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(left: 0.0, top: 20.0, right: 0.0, bottom: 0.0)),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Text(model.tr.localize("Displayed Fields"), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CC.widgetColor(WN.normalTextColor, 0))),
                  Spacer(),
                  activeIcon(Icons.cancel, close, context),
                ],
              ),

          Padding(padding: EdgeInsets.only(left: 0.0, top: 100.0, right: 0.0, bottom: 0.0)),
          columnSwitch(DisplayFields.user),
          columnSwitch(DisplayFields.customer),
          columnSwitch(DisplayFields.number),
          columnSwitch(DisplayFields.date),
          columnSwitch(DisplayFields.time),
          columnSwitch(DisplayFields.item),
          columnSwitch(DisplayFields.netWeight),
          columnSwitch(DisplayFields.tare),
          columnSwitch(DisplayFields.grossWeight),

          Spacer(),
        ],
      ), // END OF COLUMN


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
      body: buildWidget(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}