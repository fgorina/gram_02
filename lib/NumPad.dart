import 'package:flutter/material.dart';
import 'RoundButton.dart';
import 'ColorCompatibility.dart';


Widget numpad(context, String button1, String button2, Function(String) f, {Color colorButton1, Color colorButton2, Color textColorButton1, Color textColorButton2, double buttonSize = 70.0}){


  int rows = 5;
  int columns = 3;

  var labels = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", ".", "←", button1, "C", button2];


  List<Widget> columnWidgets = [];

  for (int row =0; row < rows; row++){
    List<Widget> rowWidgets = [];

    for (int col = 0; col < columns; col++){
      int index = (row * columns) + col;

      var bColor = CC.widgetColor(WN.buttonColor, 0);
      var tColor = CC.widgetColor(WN.buttonTextColor, 0);

      if (labels[index] == "C"){
        bColor = CC.widgetColor(WN.alternativeButtonColor, 0);
      }

        if (labels[index] == button1){
        if (colorButton1 != null){
          bColor = colorButton1;
        }
        if (textColorButton1 != null){
          tColor = textColorButton1;
        }
      }

      if (labels[index] == button2){
        if (colorButton2 != null){
          bColor = colorButton2;
        }
        if (textColorButton2 != null){
          tColor = textColorButton2;
        }
      }


      Widget but;

      if (labels[index] == null){
        but = SizedBox(width: buttonSize, height: buttonSize,);
      }else {
        but = roundButton(labels[index],
            buttonSize,
            bColor,
            bColor,
            tColor,
                () => {f(labels[index])},
            context,
            textSize: 24.0);
      }
      rowWidgets.add(but);
      rowWidgets.add(SizedBox(width:10, height:10));
    }

    var rowWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowWidgets );
    columnWidgets.add(rowWidget);
    columnWidgets.add(SizedBox(width:10, height:10));


  }

  return Column( crossAxisAlignment: CrossAxisAlignment.center,
      children: columnWidgets);
}