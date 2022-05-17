import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ESCPrinter.dart';
import 'dart:io';

import 'GRAMModel.dart';
import 'LabeledSegments.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'LocalFileSystemUtilities.dart';

import 'ColorCompatibility.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as pth;
import 'Label.dart';
import "ESCPrinter.dart";
import "CPCLPrinter.dart";
import 'package:flutter_blue/flutter_blue.dart';
import "BlueConnection.dart";
import "SerialPrinterConnection.dart";

class Configure extends StatefulWidget {
  _ConfigureState createState() => _ConfigureState();
}

class _ConfigureState extends State<Configure> {
  GRAMModel model = GRAMModel.shared;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

   /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    */
    controller.text = model.labelName;
  }

  void modelUpdated() {
    setState(() {});
  }

  void setUrlUsers(String url) {
    model.urlUsers = url;
    model.saveDefaults();
  }

  void setUrlCustomers(String url) {
    model.urlCustomers = url;
    model.saveDefaults();
    print(url);
  }

  void setUrlProducts(String url) {
    model.urlProducts = url;
    model.saveDefaults();
  }

  void setPrinterName(String name){
    model.printerName = name;
    model.saveDefaults();

    model.printerConnection = name.startsWith("/dev/tty") ? SerialPrinterConnection() :  BlueConnection(FlutterBlue.instance);
    if (model.printerType == "ESC"){
      model.aprinter = ESCPrinter(model.printerConnection);
    }else {
      model.aprinter = CPCLPrinter(model.printerConnection);
    }
  }

  void setPrinterType(int type){
    setState(() {
      model.printerType = ["ESC", "CPCL"][type];
      model.saveDefaults();
      if (type == 0){
        model.aprinter = ESCPrinter(model.printerConnection);
      }else {
        model.aprinter = CPCLPrinter(model.printerConnection);
      }

    });

   }


  void refresh() async {
    model.databases[0].url = Uri.parse(model.urlProducts);
    model.databases[1].url = Uri.parse(model.urlCustomers);
    model.databases[2].url = Uri.parse(model.urlUsers);

    await model.databases[0].refresh();
    await model.databases[1].refresh();
    await model.databases[2].refresh();

    print(model.databases[0]);
  }

  Future<bool> requestPermission() async{
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  void importLabel() async{

    var path = await localPath()+"/Labels";
    var labelsDir = Directory(path);

    if (!await labelsDir.exists()){
      await labelsDir.create(recursive: true);
    }
    var importDir = await downloadsDirectory();

    print("External dir ${importDir.path}");
    String labelPath = await FilesystemPicker.open(
      title: model.tr.localize("Import Label"),
      context: context,
      rootDirectory: importDir,
      fsType: FilesystemType.all,
      permissionText: model.tr.localize("Permission was not granted"),
      //allowedExtensions: ['.zip'],
      pickText:  model.tr.localize("Select a label "),
      folderIconColor: Colors.teal,
        requestPermission: requestPermission,
    );

    if (labelPath == null){
      return;
    }

    // Now we must extract the zip into our labels directory

    var inFile = File(labelPath);

    var destDir = path+ "/" + pth.basename(labelPath).replaceAll(".zip", "");

    ZipFile.extractToDirectory(zipFile: inFile, destinationDir: Directory(destDir));

  }

  void selectLabel() async{
    await Permission.storage.request();
    var path = await labelPath();
    var labelsDir = Directory(path);

    String label = await FilesystemPicker.open(
      title:  model.tr.localize('Select Label'),
      context: context,
      rootDirectory: labelsDir,
      fsType: FilesystemType.all,
      permissionText:  model.tr.localize("Permission was not granted"),
      //allowedExtensions: ['.zip'],
      pickText: model.tr.localize("Select a label "),
      folderIconColor: Colors.teal,
      requestPermission: requestPermission,
    );

    if (label != null){
      setState(() {
        var name = pth.basename(label);
        model.labelName = name;
        model.label = Label();
        model.label.load(name);
        controller.text = name;
        print(name);

      });

    }
  }

  void close() {
    Navigator.pop(context);
  }

  Widget buildWidget() {
    return Container(
      decoration:
          BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),

      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 30.0, right: 5, bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(model.tr.localize('URL s'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: CC.widgetColor(WN.normalTextColor, 0),
                      fontSize: 24)),
              Spacer(),
              Container(
                height: 30,
                child: activeIcon(Icons.cancel, close, context),
              ),
            ],
          ),
          SizedBox(height: 10.0),

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              height: screenHeight(context) - 70.0,
              width: screenWidth(context) - 70.0,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) => [
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 50.0, right: 0.0, bottom: 0.0)),
                  //Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Setup", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),],),
                  //Padding(padding: EdgeInsets.only(left: 0.0, top: 50.0, right: 0.0, bottom: 0.0)),
                  TextFormField(
                      onChanged: setUrlUsers,
                      initialValue: model.urlUsers,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: model.tr.localize("Users"),
                      )),
                  TextFormField(
                      onChanged: setUrlCustomers,
                      initialValue: model.urlCustomers,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: model.tr.localize("Customers"),
                      )),
                  TextFormField(
                      onChanged: setUrlProducts,
                      initialValue: model.urlProducts,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: model.tr.localize("Products"),
                      )),
                  TextButton(onPressed: refresh, child: Text(model.tr.localize("Refresh"))),


                  TextFormField(
                      onChanged: setPrinterName,
                      initialValue: model.printerName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: model.tr.localize("Printer Name"),
                      )),

                  labeledSegmentsFromText(model.tr.localize("Protocol"), ["ESC", "CPCL"],
                      model.printerType == 'ESC' ? 0 : 1 , setPrinterType),

                  Row(children:[
                    Container(
                      width: screenWidth(context) - 120.0,
                      child:
                      TextFormField(
                          controller: controller,
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: model.tr.localize('Current Label'),
                          )),

                    ),
                        IconButton(icon: Icon(Icons.adjust), onPressed: selectLabel),
                  ]),

                  TextButton(onPressed: importLabel, child: Text('Import Label')),






                ][index],
              ), // END OF ListView
            ),

          ]), // End of row
        ],
      ), // End of Column
    );
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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
