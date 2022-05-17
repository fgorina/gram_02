import 'package:flutter/material.dart';
import 'Configure.dart';
import 'IconAndFilesUtilities.dart';
import 'GRAMModel.dart';
import "ColorCompatibility.dart";
import 'screensize_reducers.dart';

import 'ActiveText.dart';
import 'Scanner.dart';
import 'License.dart';
import 'DataTypesUtilities.dart';

import 'SlideRoutes.dart';
import 'DocumentViewer.dart';
import 'Log.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';

final featureNames = ["Scanner", "Export"];

class LicenseView extends StatefulWidget {
  _LicenseViewState createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  GRAMModel model = GRAMModel.shared;
  License license;

  List<License> licenses = [];
  List<License> lics = [];
  String signature = "";

  String contents = "";
  String versionString = "xxx";

  @override
  void initState() {
    super.initState();
    getLicenses();
  }

  void close() {
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }

  void getLicenses() async {
    licenses = LicenseDatabase.shared.asArray();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      versionString = "Version $version ($buildNumber)";
      signature = packageInfo.buildSignature;

      setState(() {});
    });


  }

  Future<String> getPackageCodePath() async{
    return (await DeviceApps.getApp(".gram_01")).apkFilePath;

  }

  Future apkVerifyWithCRC() async{

    String apkFilePath = await getPackageCodePath();
    Log.shared.info("LicenseView.apkVerifyWithCRC", apkFilePath);

    var extractDir = Directory("extract");
    var zipFile = File(apkFilePath);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: extractDir,
          onExtracting: (zipEntry, progress) {

            if (zipEntry.name.endsWith(".dex")){
              Log.shared.info("LicenseView.apkVerifyWithCRC", "${zipEntry.name} : ${zipEntry.crc}");
              print('progress: ${progress.toStringAsFixed(1)}%');
              print('name: ${zipEntry.name}');
              print('isDirectory: ${zipEntry.isDirectory}');
              print(
                  'modificationDate: ${zipEntry.modificationDate.toLocal().toIso8601String()}');
              print('uncompressedSize: ${zipEntry.uncompressedSize}');
              print('compressedSize: ${zipEntry.compressedSize}');
              print('compressionMethod: ${zipEntry.compressionMethod}');
              print('crc: ${zipEntry.crc}');
            }
            return ZipFileOperation.skipItem;

          });

    }catch(e){
      Log.shared.error("LicenseView.apkVerifyWithCRC", e.toString());
    }
  }

  void scan() async {
    await scanQR((String s) {
      print("S is $s");
      contents = s;
    });

    lics = await License.parse(contents);
    setState(() {});
  }

  void import() async {
    if (lics.length > 0) {
      await LicenseDatabase.shared.addLicense(contents);
      lics = [];
      setState(() {});
    }
  }

  List<Widget> buildImportLicenses() {
    if (lics == null || lics.length == 0) {
      return [Text(" ")];
    } else {
      List<Widget> widgets = [
        Text("License: ${lics[0].licenseNumber}",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ];

      widgets.addAll(lics
          .map((lic) =>
          Text(lic.serialNumber + "   Exp. " + dateString(lic.expiration)))
          .toList());

      widgets.add(FlatButton(
        onPressed: ((lics != null && lics.length > 0) ? import : null),
        child: Text(
          "Import License",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ));

      return widgets;
    }
  }

  List<Widget> buildExistingLicenses() {
    List<Widget> childrens = [];

    int oldLicense = -1;

    licenses.forEach((License l) {
      if (l.licenseNumber != oldLicense) {
        childrens.add(Text("",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )));
        childrens.add(Text("License ${l.licenseNumber}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )));
        oldLicense = l.licenseNumber;
      }

      childrens.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            l.serialNumber,
            style: TextStyle(
              color: CC.widgetColor(WN.normalTextColor, 0),
            ),
          ),
          Spacer(),
          Text(
            dateString(l.expiration),
            style: TextStyle(
              color: CC.widgetColor(WN.normalTextColor, 0),
            ),
          ),

        ],
      ));
    });

    return childrens;
  }

  /*
  void doPrint() async {
    try {

      if(model.printer.scanning){
        await model.printer.flutterBlue.stopScan();
      } else if (model.printer.printCharacteristic != null){
        await model.printer.disconnect();
      }

      await model.printer.scanPrinter("ME31");

    }catch(e){
      Log.shared.error("Printer.scanPrinter", "Starting Scan", [e]);
    }
  }
  */
  void showState(String state) {
    print("Showing state : " + state);
    setState(() {});
  }

  void doPrint() async {
    try {
      await model.aprinter.connect(model.printerName, showState);
    } catch (e) {
      Log.shared.error("LicenseView.scanPrinter", "Starting Scan", [e]);
    }
  }

  String printStatus() {
    return model.aprinter.state();
  }
  /*String printStatus() {

    if (model.printer.printCharacteristic != null){
      return model.tr.localize("Connected");
    }
    return  model.printer.scanning ? model.tr.localize("Scanning") : model.tr.localize("Connect to Printer");

  }*/

  Widget buildWidget() {
    licenses = LicenseDatabase.shared.asArray();

    List<Widget> widgets = [
      FlatButton(
        onPressed: () => Navigator.push(
            context, SlideLeftRoute(widget: DocumentViewer(model.manualURL))),
        child: Text(
          "Help",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      FlatButton(
        onPressed: () => Navigator.push(
            context,
            SlideLeftRoute(
                widget: DocumentViewer(
                    "https://gram-group.com/xtrem-presentation/"))),
        child: Text(
          "Support",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      Text(""),
      FlatButton(
        onPressed: () =>
            Navigator.push(context, SlideLeftRoute(widget: Configure())),
        child: Text(
          model.tr.localize("Configure"),
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      Text(""),
      FlatButton(
        onPressed: () => doPrint(),
        child: Text(
          model.tr.localize(printStatus()),
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      Text(""),
      FlatButton(
        onPressed: scan,
        child: Text(
          "Scan License QR Code",
          style: TextStyle(
            color: CC.labelColor(CL.link, 0),
          ),
        ),
      ),
      Text(""),
    ];
    widgets.addAll(buildImportLicenses());
    widgets.addAll([
      Text(""),
      FlatButton(
        onPressed: (()  {}),
        child: Text(
          "Installed Licenses",
          style: TextStyle(
              color: CC.widgetColor(WN.normalTextColor, 0),
              fontWeight: FontWeight.bold),
        ),
      ),
      Text(""),
    ]);
    widgets.addAll(buildExistingLicenses());

    return SafeArea(
      child: Container(
        decoration:
        BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
        height: screenHeight(context),
        padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 0.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 50.0,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Spacer(),
                Container(
                  height: 30,
                  child: activeIcon(Icons.cancel, close, context),
                ),
              ]),
            ),
            Container(
              height: screenHeight(context) - 70.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 150.0,
                    height: 50.0,
                    child: getImage("logo", 0),
                  ),
                  SizedBox(height: 10.0),
                  Text(versionString),
                  Text("Signature : ${signature}"),
                  Text("MD5 Digest : ${model.apkHash}"),
                  Spacer(),
                  Container(
                    height: screenHeight(context) - 150.0,
                    width: screenWidth(context) - 70.0,

                    child: ListView(children: widgets), // End of ListView
                  ), // End of Container
                ],
              ),
            ),
          ],
        ), // End of Row
      ),
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
}
