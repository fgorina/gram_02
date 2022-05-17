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

class LicenseSettings extends StatefulWidget {
  _LicenseSettingsState createState() => _LicenseSettingsState();
}

class _LicenseSettingsState extends State<LicenseSettings> {
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

      widgets.add(
        Row(children: [
          Spacer(),
          FlatButton(
            onPressed: ((lics != null && lics.length > 0) ? import : null),
            child: Text(
              "Import License",
              style: TextStyle(
                color: CC.labelColor(CL.link, 0),
              ),
            ),
          ),
          Spacer(),
        ]),
      );

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

  void showState(String state) {
    print("Showing state : " + state);
    setState(() {});
  }

  Widget build(BuildContext context) {
    licenses = LicenseDatabase.shared.asArray();

    List<Widget> widgets = [
      FlatButton(
        onPressed: scan,
        child: Row(children: [
          Spacer(),
          Text(
            "Scan License QR Code",
            style: TextStyle(
              color: CC.labelColor(CL.link, 0),
            ),
          ),
          Spacer(),
        ]),
      ),
    ];
    widgets.addAll(buildImportLicenses());
    widgets.addAll([
      Text(""),
      FlatButton(
        onPressed: (() {}),
        child: Row(children: [
          Spacer(),
          Text(
            "Installed Licenses",
            style: TextStyle(
              color: CC.labelColor(CL.link, 0),
            ),
          ),
          Spacer(),
        ]),
      ),
    ]);
    widgets.addAll(buildExistingLicenses());

    return Column(
      children: widgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
