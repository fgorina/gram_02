import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GRAMModel.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseSettings extends StatefulWidget {
  _DatabaseSettingsState createState() => _DatabaseSettingsState();
}

class _DatabaseSettingsState extends State<DatabaseSettings> {
  GRAMModel model = GRAMModel.shared;

  @override
  void initState() {
    super.initState();
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

  void setUrlSend(String url) {
    model.urlSend = url;
    model.saveDefaults();
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

  Future<bool> requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  Widget build(BuildContext context) {
    return Wrap(runSpacing: 20.0, children: [
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
      TextFormField(
          onChanged: setUrlSend,
          initialValue: model.urlSend,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: model.tr.localize("Send URL"),
          )),
      Row(
        children: [
          Spacer(),
          TextButton(
              onPressed: refresh, child: Text(model.tr.localize("Refresh"))),
          Spacer(),
        ],
      ),
    ]);
  }
}
