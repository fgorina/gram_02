import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ColorCompatibility.dart';

Widget labeledSegments(
    String name, Map<int, Widget> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(name,
          style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      Spacer(),
      enabled
          ? CupertinoSegmentedControl(
              children: segments, onValueChanged: changed, groupValue: selected)
          : segments[selected],
    ],
  );
}

Widget labeledSegmentsFromTextNoTitle(
    List<String> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  Map<int, Widget> children = {};

  for (int i = 0; i < segments.length; i++) {
    children[i] = Padding(
        padding: EdgeInsets.only(left: 5, top: 0.0, right: 5.0, bottom: 0.0),
        child: Text(segments[i]));
  }
  return enabled
      ? CupertinoSegmentedControl(
          children: children, onValueChanged: changed, groupValue: selected)
      : segments[selected];
}

Widget labeledSegmentsFromText(
    String name, List<String> segments, int selected, Function(int) changed,
    {bool enabled = true}) {
  Map<int, Widget> children = {};

  for (int i = 0; i < segments.length; i++) {
    children[i] = Padding(
        padding: EdgeInsets.only(left: 5, top: 0.0, right: 5.0, bottom: 0.0),
        child: Text(segments[i]));
  }
  return labeledSegments(name, children, selected, changed, enabled: enabled);
}

Widget stepper(String name, int value, Function(int) changed,
    {bool enabled = true}) {
  // 0 -> -, 1-> +

  Map<int, Widget> children = {
    0: Padding(
        padding: EdgeInsets.only(left: 15, top: 0.0, right: 15.0, bottom: 0.0),
        child: Text("-")),
    1: Padding(
        padding: EdgeInsets.only(left: 15, top: 0.0, right: 15.0, bottom: 0.0),
        child: Text("+")),
  };

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(name,
          style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
      Spacer(),
      enabled
          ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(value.toString()),
              CupertinoSegmentedControl(
                  children: children,
                  onValueChanged: changed,
                  groupValue: null),
            ])
          : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(value.toString()),
            ]),
    ],
  );
}
