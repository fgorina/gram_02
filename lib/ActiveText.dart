import 'package:flutter/material.dart';
import 'IconAndFilesUtilities.dart';


Widget activeText(Text text, Function f, context){

  return GestureDetector(
    child: text,
    onTap: Feedback.wrapForTap(f, context),
  );
}

Widget activeTextFromString(String text, Function f, context){

  return GestureDetector(
    child: Text(text),
    onTap: Feedback.wrapForTap(f, context),
  );
}



Widget activeImage(String name, Function f, context){
  return GestureDetector(
    child: getImage(name, 0),
    onTap: Feedback.wrapForTap(f, context),
  );
}

Widget activeIcon(icon, Function f, context, {double size : 0.0, Color color : Colors.black}){
  return GestureDetector(
    child: size == 0.0 ? Icon(icon, color:color) : Icon(icon, size: size, color:color),
    onTap: Feedback.wrapForTap(f, context),
  );
}

Widget activeLine({Widget child, double height: 40.0, Function onTap, Function onSlide}){
  return InkWell(
      child: child,
      splashColor: Colors.cyan,
      onTap: onTap(),

  );
}