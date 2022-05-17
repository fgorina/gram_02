import 'package:flutter/material.dart';
import 'Dialogs.dart';
import 'GRAMModel.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'WeightRecordsList.dart';
import 'ColumnSelector.dart';
import 'package:share/share.dart';
import 'ColorCompatibility.dart';
import 'SlideRoutes.dart';
import 'LicenseView.dart';
import 'LocalFileSystemUtilities.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class WeightRecordsScreen extends StatefulWidget {
  _WeightRecordsState createState() => _WeightRecordsState();
}

class _WeightRecordsState extends State<WeightRecordsScreen> {
  GRAMModel model = GRAMModel.shared;

  @override
  void initState() {
    super.initState();
    model.addSubscriptor(this);
  }

  void clearRecords() {
    model.clearRecords();
  }

  // TODO: Remove model.disableRestrictions in production version

  void askExportRecords(){
    displayOptionsAlert(context,  "Export Records", "Do you really want to export records to a .csv file??", "Yes", exportRecords);
  }

  void exportRecords() async {


    int exp = model.exportableRecords();
    model.exportEnabled = exp != 0;

    if (model.exportEnabled || model.disableRestrictions) {
      // Ask for a directory where to save the fil
      //await Permission.storage.request();

      var status = await Permission.storage.request();

      if (status == PermissionStatus.granted){
        print("Permissos concedits");
      }else{
        print("Permisos denegats ${status}");
      }

      String root = await dataPath();

 /*     String dir = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: Directory(root),
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
        folderIconColor: Colors.teal,
      );
      */

      String dir = root;

      var now = DateTime.now();
      String name = "data_" + DateFormat('yyMMdd_HHmmss').format(now) + '.csv';

      String path = dir + '/' + name;

      print(path);

      int exp = model.exportableRecords();
      model.exportEnabled = exp != 0;

      status = await Permission.storage.request();

      if (status == PermissionStatus.granted){
        print("Permissos concedits");
      }else{
        print("Permisos denegats ${status}");
      }


      var f = await model.doSaveCSVRecords(path);
    } else {

      displayOptionsAlert(context, "Export not implemented",  "Please, contact your dealer.", "Enter License",
              () => Navigator.push(context, SlideLeftRoute(widget: LicenseView())));


    }
  }

  void shareRecords() async {

    // check if there is any record with expoer enabled

    int exp = model.exportableRecords();
    model.exportEnabled = exp != 0;

    if (model.exportEnabled || model.disableRestrictions) {

      model.doSaveAsCSV();

      var dir = await localPath();
      var name = model.weightsName;
      var path = "$dir/$name.csv";


      await Share.shareFiles([path], text: "Records", subject:"GRAM Xtrerm records");
    } else {

      displayOptionsAlert(context, "Export not implemented",  "Please, contact your dealer.", "Enter License",
              () => Navigator.push(context, SlideLeftRoute(widget: LicenseView())));


    }
  }


  void close() {
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }

  void modelUpdated() {
    setState(() {});
  }

  Widget buildWidget() {
    return SafeArea(
      //height: screenHeight(context),
      //padding: EdgeInsets.only(left: 0, top: 0.0, right: 0, bottom: 0.0),
      child: Container(
        decoration:
            BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Padding(padding: EdgeInsets.only(left: 0.0, top: 30.0, right: 0.0, bottom: 0.0)),
            Container(
              height: 30,
              child: activeImage(
                "back",
                close,
                context,
              ),
            ),

            Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 10.0, right: 0.0, bottom: 0.0)),

            buildWeighRecordsList(model, screenHeight(context) - 100, context),

            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlatButton.icon(
                    onPressed: clearRecords,
                    icon: Icon(Icons.delete, color: CC.widgetColor(WN.normalTextColor, 0)),
                    label: Text(model.tr.localize("Clear"), style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  ),
                  FlatButton.icon(
                    onPressed: deviceType == DeviceType.terminal ? askExportRecords : shareRecords,
                    icon: Icon(Icons.share, color: CC.widgetColor(WN.normalTextColor, 0)),
                    label: Text(model.tr.localize("Export"), style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  ),
                  FlatButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ColumnSelector())),
                    icon: Icon(Icons.view_column, color: CC.widgetColor(WN.normalTextColor, 0)),
                    label: Text(model.tr.localize("Columns"), style: TextStyle(color: CC.widgetColor(WN.normalTextColor, 0))),
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  ),
                ]),
          ],
        ), // END OF COLUMN
      ),
    ); // End of Container
  }

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      body: buildWidget(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
