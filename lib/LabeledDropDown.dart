import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ColorCompatibility.dart';


Widget labeledDropDown(String name, List<String> items, int selected,  Function(int) changed, {bool enabled = true, width = 150.0}){

  var entries = items.asMap().entries;


  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(name, style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0)), ),
      Spacer(),
      Container(
       width: width,
      height: 40,
      alignment: Alignment.centerRight,
      decoration:BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,

      ),

      child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(value: selected, icon:const Icon(Icons.arrow_downward),
        onChanged:  enabled ? changed : null,
      items: entries.map((entry) { return DropdownMenuItem<int>(value: entry.key, child: Text(entry.value));} ).toList()),
      ),
      ),
    ],
  );

}


