import 'package:flutter/material.dart';
import 'screensize_reducers.dart';
import 'GRAMModel.dart';
import 'ColorCompatibility.dart';


Widget  buildWeighRecordsList(GRAMModel model, double height, context) {

  // compute widths

  var stdWidths = {DisplayFields.user: 0.096,
  DisplayFields.customer: 0.133,
  DisplayFields.number: 0.084,
  DisplayFields.date: 0.108,
  DisplayFields.time: 0.108,
  DisplayFields.item: 0.145,
  DisplayFields.netWeight: 0.108,
  DisplayFields.tare: 0.108,
  DisplayFields.grossWeight: 0.108};

  var shortStdWidths = {DisplayFields.user: 0.0,
    DisplayFields.customer: 0.0,
    DisplayFields.number: 0.0,
    DisplayFields.date: 0.0,
    DisplayFields.time: 0.3,
    DisplayFields.item: 0.4,
    DisplayFields.netWeight: 0.3,
    DisplayFields.tare: 0.0,
    DisplayFields.grossWeight: 0.0};

  var resizable = {DisplayFields.user: true,
    DisplayFields.customer: true,
    DisplayFields.number:false,
    DisplayFields.date: false,
    DisplayFields.time: false,
    DisplayFields.item: true,
    DisplayFields.netWeight: false,
    DisplayFields.tare: false,
    DisplayFields.grossWeight: false};


  var alignment = {DisplayFields.user: Alignment.centerLeft,
    DisplayFields.customer: Alignment.centerLeft,
    DisplayFields.number:Alignment.centerRight,
    DisplayFields.date: Alignment.center,
    DisplayFields.time: Alignment.center,
    DisplayFields.item: Alignment.centerLeft,
    DisplayFields.netWeight: Alignment.centerRight,
    DisplayFields.tare: Alignment.centerRight,
    DisplayFields.grossWeight: Alignment.centerRight};


  var compactDisplayedFields = {
    DisplayFields.user: false,
    DisplayFields.customer: false,
    DisplayFields.number:false,
    DisplayFields.date: false,
    DisplayFields.time: true,
    DisplayFields.item: true,
    DisplayFields.netWeight: true,
    DisplayFields.tare: false,
    DisplayFields.grossWeight: false
  };


  Map<DisplayFields, bool> myDisplayedFields ;

  var widths = stdWidths;
  var rowHeight = 30.0;
  var rowWidth = screenWidth(context) - 17;

  var color0 = CC.widgetColor(WN.tableBackgroundColor, 0);
  var color1 = CC.widgetColor(WN.alternateTableBackgroundColor, 0);
  var colorLines = CC.labelColor(CL.lightGray, 0);

  //print(screenWidth(context));

  var compact = screenWidth(context) < 500;
  if (compact){
      widths = shortStdWidths ;
      rowWidth = rowWidth - 2;
      myDisplayedFields = compactDisplayedFields;

  } else {
    myDisplayedFields = model.displayedFields;
    var total  = 0.0;
    var scalable = 0.0;
    fields.forEach((f) {
      if (myDisplayedFields[f]){
        rowWidth = rowWidth - 1;
        total += stdWidths[f];

        if (resizable[f]){
          scalable += stdWidths[f];
        }
      }
      }) ;

    var factor = 1 + ((1-total) / (scalable));

    fields.forEach((f) {
      if (myDisplayedFields[f]){

       if (resizable[f]){
          widths[f] =  stdWidths[f] * factor;
        }
        else {
          widths[f] =  stdWidths[f];
        }
      } else {
        widths[f] = 0.0;
      }
    }) ;

  }
  // Compute the children

  List<Widget> headerFields = [];
  fields.forEach((f) {
    if (myDisplayedFields[f] && widths[f] > 0.0){
      var label = model.tr.localize(displayFieldsTitles[f]);
      headerFields.add(
        Container(height: rowHeight, width: widths[f] * rowWidth, color:  color1, alignment:Alignment.center, child: Text(label, style: TextStyle(color:CC.widgetColor(WN.normalTextColor, 0),fontWeight: FontWeight.bold,))),
      );
      headerFields.add( Container(height: rowHeight, width: 1.0, color: colorLines));
    }
  });

  List<Widget> dataFields = [];

  var n = model.recordedWeights.length;

  for (int index = 0; index < n; index++) {
    var wr = model.recordedWeights[index];

    List<Widget> rowFields = [];
    fields.forEach((f) {
      if (myDisplayedFields[f] && widths[f] > 0.0) {
        var value = wr.stringValue(f);
        if (value == null){
          value = "****";

        }
        rowFields.add(
          Container(height: rowHeight,
              width: widths[f] * rowWidth,
              color: index % 2 == 0 ? color0 : color1,
              alignment: alignment[f],
              padding: EdgeInsets.only(
                  left: 3.0, top: 0.0, right: 3.0, bottom: 0.0),
              child: Text(value, style: TextStyle(color:CC.widgetColor(WN.normalTextColor, 0)))),
        );
        rowFields.add(
            Container(height: rowHeight, width: 1.0, color: colorLines));
      }
    });

    dataFields.add(Row(children: rowFields));
  }


  return Padding(
        padding: EdgeInsets.only(left: 8.0, top: 10.0, right: 8.0, bottom: 0.0),
        child:Container(
        height: height,
        alignment: Alignment.topCenter,
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: headerFields,
          ),
          Container( height: height - rowHeight,
            child:
          SingleChildScrollView( scrollDirection: Axis.vertical,
         child:Column(
          children: dataFields,// End of Map
         ), // End of Column
      ),),]),),);// End of Single ScrollView
}