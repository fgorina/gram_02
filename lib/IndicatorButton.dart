import 'package:flutter/material.dart';
import 'RoundButton.dart';


Widget indicatorWidget(double size, Color color){

    return Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );


}
Widget indicatorButton(String title, double size, Color color, Color disabledColor, Color textColor, Color indicatorColor,  Function f, BuildContext context, {invertColor: false}) {

  var ssize = size * 0.2; // Mida relativa de l'indicador

  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Align(alignment: Alignment.bottomLeft,
            child: roundButton(title, size * 0.9, color, disabledColor, textColor, f, context, invertColor: invertColor)),
        Align(alignment: Alignment.topRight,
            child: indicatorWidget(ssize, indicatorColor)),
      ],
    ),

  );
}