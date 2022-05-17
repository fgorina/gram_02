import 'package:flutter/material.dart';
import 'ActiveText.dart';
import 'ColorCompatibility.dart';
import 'package:flutter/cupertino.dart';

Widget labeledSwitch(String name, bool value,  Function(bool) changed, {bool enabled = true}){


  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(name, style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      CupertinoSwitch(value: value, onChanged: enabled ? changed : null,),
    ]
  );
}

Widget labeledLink(String name, String value, Function onTap, BuildContext context, {textAlign: TextAlign.left, bool enabled= true}){
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(name, textAlign: textAlign, style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
        activeText(Text(value, style: TextStyle(color: CC.labelColor(CL.link, 0))), onTap, context, ),
      ]
  );
}
