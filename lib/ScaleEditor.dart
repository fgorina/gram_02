import 'package:flutter/material.dart';
import 'screensize_reducers.dart';
import 'ActiveText.dart';
import 'ScaleDatabase.dart';
import 'GRAMModel.dart';
import 'Scale.dart';
import 'package:flutter/cupertino.dart';
import 'ColorCompatibility.dart';



class ScaleEditor extends StatefulWidget {

  Scale scale;

  ScaleEditor(Scale scale){
    this.scale = scale;
  } // Antigament asignaba

  _ScaleEditorState createState() => _ScaleEditorState(scale);
}

class _ScaleEditorState extends State<ScaleEditor> {


  Scale scale;
  ScaleDatabase scales = ScaleDatabase.shared;
  GRAMModel model = GRAMModel.shared;


  TextEditingController _tfcName = TextEditingController();
  TextEditingController _tfcSsid = TextEditingController();
  TextEditingController _tfcPassphrase = TextEditingController();
  TextEditingController _tfcIp = TextEditingController();
  TextEditingController _tfcPort = TextEditingController();
  TextEditingController _tfcNetworkName = TextEditingController();
  TextEditingController _tfcNetworkPassword = TextEditingController();
  TextEditingController _tfcNetworkPort = TextEditingController();


  _ScaleEditorState(Scale scale){
    this.scale = scale;
  }

  @override
  void initState() {
    super.initState();

    _tfcName.text = scale.name;
    _tfcSsid.text = scale.ssid;
    _tfcPassphrase.text = scale.passphrase;
    _tfcIp.text = scale.ipAddress;
    _tfcPort.text = scale.port.toString();
    _tfcNetworkName.text = scale.networkName;
    _tfcNetworkPassword.text = scale.networkPassword;
    _tfcNetworkPort.text = scale.networkPort.toString();

    _tfcSsid.addListener(() {
      setState(() {

      });
    });
  }

  void close(){
    Navigator.pop(context);
  }

  void addScale(){

    String name = _tfcSsid.text;

    scale.name = name;   // Hauria de ser name però de moment es ssid
    scale.ssid = _tfcSsid.text;
    scale.passphrase = _tfcPassphrase.text;
    scale.ipAddress = _tfcIp.text;
    scale.port = int.parse(_tfcPort.text);
    scale.networkName = _tfcNetworkName.text;
    scale.networkPassword = _tfcNetworkPassword.text;
    scale.networkPort = int.parse(_tfcNetworkPort.text);

    scales.add(scale);

    close();
  }

  void configureScale(){

  }

  Widget attributeWidget(String name, TextEditingController controller, String value, {bool numeric : false}){
    //controller.text = value;

    if(numeric){
      return Container(height: 40,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(name), Container(width: 200, child: CupertinoTextField(
                decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundColor, 0), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                controller: controller,
                keyboardType: TextInputType.number,

              ),),

              ]));
    }else {
      return Container( height: 40,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(name), Container(width: 200, child: CupertinoTextField(
                decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundColor, 0), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                controller: controller,


              ),),

              ]));
    }
  }

  Widget attributeLabel(String name, String value, ){
    //controller.text = value;
      return Container(height: 40,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name),
                Container(width: 200,
                  child: Text(value, textAlign: TextAlign.right),
                ),
              ],
          ),
      );
  }


  Widget buildWidget() {

    return Container(
      height: screenHeight(context),
      padding: EdgeInsets.only(left: 30, top: 20.0, right: 20, bottom: 20.0),
      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              activeIcon(Icons.add, close, context),
              Spacer(),
              activeIcon(Icons.cancel, close, context ),
            ],
          ),



          attributeLabel(model.tr.localize("Name"), _tfcSsid.text),
          attributeWidget(model.tr.localize("Scl SSID"), _tfcSsid, scale.ssid),
          attributeWidget(model.tr.localize("Scl Passwd"), _tfcPassphrase, scale.passphrase),
          attributeWidget(model.tr.localize("Scl IP"), _tfcIp, scale.ipAddress),
          attributeWidget(model.tr.localize("Scale Port"), _tfcPort, scale.port.toString(), numeric: true),
          attributeWidget(model.tr.localize("Net SSID"), _tfcNetworkName, scale.networkName),
          attributeWidget(model.tr.localize("Net Passwd"), _tfcNetworkPassword, scale.networkPassword),
          attributeWidget(model.tr.localize("Net Port"), _tfcNetworkPort, scale.networkPort.toString(), numeric: true),

          Padding(padding: EdgeInsets.only(left: 0.0, top: 40.0, right: 0.0, bottom: 0.0)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              FlatButton(child:
              Text(model.tr.localize('Cancel'),
                  style: TextStyle(fontSize: 18, color: CC.labelColor(CL.link, 0))),
                 onPressed:() => close(),
               ),
              Spacer(),
              FlatButton(child: Text(model.tr.localize('OK'),
                  style: TextStyle(fontSize: 18,color: CC.labelColor(CL.link, 0))),
                onPressed:() => addScale(),
              ),


              Spacer(),

            ],
          ),
          Spacer(),

        ],
      ), // END OF COLUMN

    );// End of Container

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
