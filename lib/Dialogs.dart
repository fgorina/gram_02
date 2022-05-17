
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ColorCompatibility.dart';
import 'GRAMModel.dart';
import 'Translation.dart';

displayDialog(BuildContext context, String title, String comment, TextEditingController textFieldController,
    Function(String) assign) async {

  Translation tr = GRAMModel.shared.tr;

  return showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(tr.localize(title)),
          content: CupertinoTextField(
            decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundColor, 0), borderRadius: BorderRadius.all(Radius.circular(5.0))),
        style: TextStyle(color:CC.widgetColor(WN.normalTextColor, 0)),
            controller: textFieldController,
          ),
          actions: <Widget>[
            new FlatButton(
              child:  Text(tr.localize('Cancel'), style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text(tr.localize('OK'), style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
              onPressed: () {
                assign(textFieldController.text);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

displayAlert(BuildContext context, String title, String message) async {

  Translation tr = GRAMModel.shared.tr;

  return showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(tr.localize(title)),
          content: Text(tr.localize(message),),
          actions: <Widget>[

            new FlatButton(
              child: new Text(tr.localize('OK'), style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

displayOptionsAlert(BuildContext context, String title, String message, String okmessage, Function() doIt) async {

  Translation tr = GRAMModel.shared.tr;

  return showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(tr.localize(title)),
          content: Text(tr.localize(message),),
          actions: <Widget>[

            new FlatButton(
              child:  Text(tr.localize(okmessage),style: TextStyle(fontSize: 18, color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                doIt();

              },
            ),


            new FlatButton(
              child: new Text(tr.localize('Cancel'), style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),


          ],
        );
      });
}


displayYesNoDialog(BuildContext context, String title, String comment, TextEditingController textFieldController,
    Function(String) assign, {okButton: "Yes", cancelButton: "No"}) async {

  Translation tr = GRAMModel.shared.tr;

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr.localize(title)),
          content: CupertinoTextField(

            controller: textFieldController,
            decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundColor, 0), borderRadius: BorderRadius.all(Radius.circular(5.0))),
            style: TextStyle(color:CC.widgetColor(WN.normalTextColor, 0), ),
          ),
          actions: <Widget>[
            new FlatButton(
              child:  Text(tr.localize(cancelButton), style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child:  Text(tr.localize(okButton),style: TextStyle(fontSize: 18, color: Colors.red)),
              onPressed: () {
                assign(textFieldController.text);
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      });
}
