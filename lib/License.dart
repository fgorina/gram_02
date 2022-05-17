import 'package:simple_rsa2/simple_rsa2.dart';
import 'package:flutter/services.dart';
import 'LocalFileSystemUtilities.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class License implements Comparable<License> {
  bool _valid;
  int licenseNumber;
  String serialNumber;
  DateTime expiration;
  List<bool> features;

  License(this._valid, this.licenseNumber, this.serialNumber, this.expiration,
      this.features);

  bool isValid() {
    return _valid && (expiration.compareTo(DateTime.now()) >= 0);
  }

  int count() {
    return features.length;
  }

  int countEnabledOptions() {

    return features.map((bool v) => v ? 1 : 0).reduce((int v, int e) => v + e);
  }

  bool checkFeature(int feature) {
    if (feature < 0 || feature >= features.length) {
      return false;
    } else {
      return isValid() && features[feature];
    }
  }

  String _featureString() {
    return features.map((e) => e ? "1" : "0").reduce((value, e) => value + e);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is License &&
          this.licenseNumber == other.licenseNumber &&
          this.serialNumber == other.serialNumber &&
          this.expiration == other.expiration &&
          this.features == other.features);

  @override
  int get hashCode =>
      "$licenseNumber$serialNumber${expiration.toIso8601String()}${_featureString()}"
          .hashCode;

  bool operator <(Object rhs) =>
      rhs is License &&
      (this.licenseNumber < rhs.licenseNumber ||
          (this.licenseNumber == rhs.licenseNumber &&
                  this.serialNumber.compareTo(rhs.serialNumber) < 0 ||
              (this.licenseNumber == rhs.licenseNumber &&
                  this.serialNumber == rhs.serialNumber &&
                  this.expiration.millisecondsSinceEpoch <
                      rhs.expiration.millisecondsSinceEpoch) ||
              (this.licenseNumber == rhs.licenseNumber &&
                  this.serialNumber == rhs.serialNumber &&
                  this.expiration == rhs.expiration &&
                  this.countEnabledOptions() < rhs.countEnabledOptions())));

  int compareTo(License rhs) {
    if (this == rhs) {
      return 0;
    } else if (this < rhs) {
      return -1;
    } else {
      return 1;
    }
  }

  // parsing stringd

  static Future<List<License>> parse(String contents) async {
    final beginSignature = "---- BEGIN SIGNATURE ----";
    final endSignature = "---- END SIGNATURE ----";
    final beginData = "---- BEGIN DATA ----";
    final endData = "---- END DATA ----";
    final versionString =
        "VERSION: "; // Version of the file. Must be first line
    final licenseString = "LICENSE: "; // Serial number of license file

    String pubkey = await loadAsset("public.pem");

    List<String> lines = contents.split("\n");

    int state = 0; // 0 -> Wait, 1->Signature, 2-> Data

    String signatureBuff = "";
    String dataBuff = "";
    int version = 0;
    int licenseNumber = 0;

    for (String line in lines) {
      if (state == 0) {
        if (line == beginSignature) {
          state = 1;
        } else if (line == beginData) {
          state = 2;
        } else if (line.startsWith(versionString)) {
          version = int.parse(
              line.substring(9, line.length).trim()); // -1 is removing \n
        }
      } else if (state == 1) {
        if (line == endSignature) {
          state = 0;
        } else {
          signatureBuff += line;
        }
      } else if (state == 2) {
        if (line == endData) {
          state = 0;
        } else if (line.startsWith(licenseString)) {
          licenseNumber = int.parse(
              line.substring(9, line.length).trim()); // -1 is removing \n
          dataBuff += (line + "\n");
        }else {
          dataBuff += (line + "\n");
        }
      }
    }

    try {
      var verified = await verifyString(dataBuff, signatureBuff, pubkey);
      if (verified && licenseNumber != 0) {
        List<License> licenses = [];

        List<String> licenseList = dataBuff.split("\n");

        licenseList.forEach((license) {
          if(!license.startsWith(licenseString)) {
            var clean = license.replaceAll("\n", "");
            if (clean.length > 18) {
              var vSerialNumber = clean.substring(0, 10);
              var vExpiration = DateTime.parse(clean.substring(10, 18));
              var vFeatures =
              clean
                  .substring(18)
                  .codeUnits
                  .map((c) => c == 0x31)
                  .toList();

              License l = License(
                  true, licenseNumber, vSerialNumber, vExpiration,
                  vFeatures);
              licenses.add(l);
            }
          }
        });
        return licenses;
      }
    } catch (error) {
      print("Error verifying licenses $error");
    }
    return [];
  }

  static Future<List<License>> parseFile(String path) async {
    String contents = await load(path);
    return await License.parse(contents);
  }

  static Future<String> loadAsset(String name) async {
    return await rootBundle.loadString('assets/' + name);
  }

  // Loads from a path.

  static Future<String> load(String path) async {
    var file = File(path);
    try {
      var contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return null;
    }
  }

  static void save(String contents, String path)  {
    var bytes = contents.codeUnits;
    new File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
  }
}

/**
 *  LicenseDatabase Singleton

 */

class LicenseDatabase {
  static final LicenseDatabase shared = LicenseDatabase._constructor();

  Map<String, License> _licenses = {};

  LicenseDatabase._constructor() {
    _licenses = {}; // Ensure it is an empty lisr
    loadLicenses();
  }

  Future<void> loadLicenses() async {
    // Check license directory existence

    var licenseDirPath = await localPath() + "/licenses";
    var licenseDir = Directory(licenseDirPath);
    if (licenseDir.existsSync()) {
      for (var entity in licenseDir.listSync()) {
        if (entity.path.endsWith(".lic")) {
          var licenses = await License.parseFile(entity.path);
          for (var license in licenses) {
            if (license.isValid()) {
              var oldOne = _licenses[license.serialNumber];
              if (oldOne == null || oldOne < license) {
                _licenses[license.serialNumber] = license;
              }
            }
          }
        }
      }
    } else {
      licenseDir.createSync(recursive: true);
    }
  }

  Future<void> addLicense(String contents) async {
    var licenses = await License.parse(contents);
    int addedLicenses = 0;

    var licenseDirPath = await localPath() + "/licenses/";
    var format = NumberFormat("0000000000");

    for (var license in licenses) {
      if (license.isValid()) {
        var oldOne = _licenses[license.serialNumber];
        if (oldOne == null || oldOne < license) {
          _licenses[license.serialNumber] = license;
          addedLicenses += 1;
        }
      }
    }

    // Now save the file

    if (licenses.length > 0 && addedLicenses > 0) {
      var path =
          licenseDirPath + format.format(licenses[0].licenseNumber) + ".lic";
      License.save(contents, path);
    }
  }

  License getLicenseFor(String sn) {
    return _licenses[sn];
  }

  bool isEnabled(String sn, int feature) {
    if (sn == null){
      return false;
    }
    var sa = sn;
    while(sa.length < 10){
      sa = '0' + sa;
    }
    var lc = getLicenseFor(sa);

    if (lc != null) {
      return lc.checkFeature(feature);
    }
    return false;
  }

  List<License> asArray() {
    var keys = _licenses.keys;
    List<License> arr = keys.map((k) => _licenses[k]).toList();
    arr.sort();
    return arr;
  }
}
