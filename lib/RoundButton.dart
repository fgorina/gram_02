import 'package:flutter/material.dart';
import 'ColorCompatibility.dart';
import 'IconAndFilesUtilities.dart';


Widget roundButton(String title, double size, Color color, Color disabledColor,  Color textColor, Function f, BuildContext context, {double textSize: 14.0, invertColor: false}){

  Widget widget;

  if (title.startsWith("^")){
    String name = title.substring(1); // Rest is image name
    widget = Container( height: textSize*0.9, child: getImage(name, invertColor ? 1 : 0));

  } else {
    widget = Text(title, overflow: TextOverflow.visible ,textAlign: TextAlign.center , style: TextStyle(fontSize: textSize, color: textColor, backgroundColor: CC.labelColor(CL.clear, invertColor ? 1 : 0)));
  }
  return ElevatedButton(
     // color: color,
    //  disabledColor: disabledColor,
      child:widget,// End of Text
      //end of Container
      onPressed: f != null ? Feedback.wrapForTap(f, context) : null,
      style: ElevatedButton.styleFrom(

        fixedSize: Size(size, size),
        primary: f != null ? color : disabledColor,

        shape: CircleBorder(),
      ),

    // end RaisedButton
  );
}

