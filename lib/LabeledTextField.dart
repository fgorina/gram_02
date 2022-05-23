import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gram_01/GRAMMessage.dart';
import 'ColorCompatibility.dart';
import 'GenericVisorField.dart';

Widget labeledText(String name, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 150,
        child: Text(value, textAlign: TextAlign.right),
      ),
    ],
  );
}

Widget labeledGenericText(String name, AddressType field, Duration refresh){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 150,
        child: GenericVisorField(field, refresh),
      ),
    ],
  );

}

Widget labeledTextField(String name, String value, Function(String) changed, {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 150,
        child: TextFormField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          onFieldSubmitted: changed,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}

Widget labeled2TextField(String name, String value1, String value2,
    Function(String) changed1, Function(String) changed2, {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 100,
        child: TextFormField(
          enabled: enabled,
          controller: TextEditingController(text: value1),
          onFieldSubmitted: changed1,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Container(
        width: 10,
      ),
      Container(
        width: 100,
        child: TextFormField(
          enabled: enabled,
          controller: TextEditingController(text: value2),
          onFieldSubmitted: changed2,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}

Widget labeledNumericField(
    String name, String value, Function(String) changed, {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Container(
    width: 150,
    child:
      Text(name,
          style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
    ),
      Spacer(),
      Container(
        width: 100,
        child: TextFormField(
            enabled: enabled,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(),
            ),
            textAlign: TextAlign.right,
            controller: TextEditingController(text: value),
            keyboardType: TextInputType.number,
            onFieldSubmitted: changed),
      ),
    ],
  );
}

Widget labeledNumericFieldButton(String name, String value, String buttonText,
    Function(String) changed, Function pushed, {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 100,
        child: TextFormField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          keyboardType: TextInputType.number,
          onFieldSubmitted: changed,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Container(width: 10),
      Container(
        width: 100,
        child: TextButton(
          onPressed: enabled ? pushed : null,
          child: Text(buttonText),
        ),
      ),
    ],
  );
}

Widget labeled2NumericField(String name, String value1, String value2,
    Function(String) changed1, Function(String) changed2, {bool enabled = true, bool enabled1 = true, bool visible = true, bool visible1 = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),
      Container(
        width: 100,
        child: visible ? TextFormField(
          enabled: enabled,
          controller: TextEditingController(text: value1),
          keyboardType: TextInputType.number,
          onFieldSubmitted: changed1,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ) : Text(" "),
      ),
      Container(
        width: 10,
      ),
      Container(
        width: 100,
        child: visible1 ? TextFormField(
          enabled: enabled1,
          controller: TextEditingController(text: value2),
          keyboardType: TextInputType.number,
          onFieldSubmitted: changed2,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
        ) : Text(" "),
      ),
    ],
  );
}





Widget labeled2PopupField(String name, int index1, int index2, List<int> values,
    Function(int) changed1, Function(int) changed2, {bool enabled = true, bool enabled1 = true, bool visible = true, bool visible1 = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),


        Container(
          width: 100,
          height: 40,
          alignment: Alignment.centerRight,
          decoration:BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          ),
          child: visible ? DropdownButtonHideUnderline(
            child: DropdownButton<int>(value: index1, icon:const Icon(Icons.arrow_downward),
            onChanged:  changed1,
            items: values.map((entry) { return DropdownMenuItem<int>(value: entry, child: Text(entry.toString()));} ).toList()),
          )  : Text(" "),
        ),

      Container(
        width: 10,
      ),
      Container(
        width: 100,
        height: 40,
        alignment: Alignment.centerRight,
        decoration:BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: visible ? DropdownButtonHideUnderline(
          child: DropdownButton<int>(value: index2, icon:const Icon(Icons.arrow_downward),
              onChanged:  changed2,
              items: values.map((entry) { return DropdownMenuItem<int>(value: entry, child: Text(entry.toString()));} ).toList()),
        )  : Text(" "),
      ),

    ],
  );
}

Widget labeled1PopupField(String name, int index1,  List<int> values,
    Function(int) changed1,  {bool enabled = true,  bool visible = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),


      Container(
        width: 100,
        height: 40,
        alignment: Alignment.centerRight,
        decoration:BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: visible ? DropdownButtonHideUnderline(
          child: DropdownButton<int>(value: index1, icon:const Icon(Icons.arrow_downward),
              onChanged:  changed1,
              items: values.map((entry) { return DropdownMenuItem<int>(value: entry, child: Text(entry.toString()));} ).toList()),
        )  : Text(" "),
      ),


    ],
  );
}

Widget labeledStringPopupField(String name, int index1,  List<String> values,
    Function(int) changed1,  {bool enabled = true,  bool visible = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 150,
        child: Text(name,
            style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      ),
      Spacer(),


      Container(
        width: 100,
        height: 40,
        alignment: Alignment.centerRight,
        decoration:BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: visible ? DropdownButtonHideUnderline(
          child: DropdownButton<int>(value: index1, icon:const Icon(Icons.arrow_downward),
              onChanged:  changed1,
              items: values.asMap().entries.map((entry) { return DropdownMenuItem<int>(value: entry.key, child: Text(entry.value));} ).toList()),
        )  : Text(" "),
      ),


    ],
  );
}