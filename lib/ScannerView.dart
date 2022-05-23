import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'GRAMModel.dart';
import 'Visor.dart';
import 'ColorCompatibility.dart';
import 'ActiveText.dart';
import 'package:sprintf/sprintf.dart';
import 'ToggleQrProtocol.dart';



class ScannerView extends StatefulWidget {
  ScannerView({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with  ToggleQrProtocol {
  GRAMModel model = GRAMModel.shared;

  var qrText = "";
  bool goneToZero = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,

    ]);
    model.addSubscriptor(this);
  }

  void modelUpdated() {


    setState(() {});
  }

  void toggleQr() {


    setState(() {
      model.showQr = !model.showQr;
    });
  }


  bool isActive(){
    return qrText != "" && model.isStreaming() && model.stable && model.weight.value != 0 && (model.zeroSinceLastRecord || !model.recordsToZero) && !model.zero;
  }

  Color getButtonColor(){

    if(isActive()) {
      return Colors.cyan;
    } else {
      return CC.widgetColor(WN.normalTextColor, 0);
    }
  }

  void resetCounter(){
    setState(() {
      model.resetCounter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      SafeArea(
        minimum: EdgeInsets.only(left:20.0, right:20.0, top: 20.0, bottom:20.0),
        child:Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(

              children:[
                Spacer(),
                activeIcon(Icons.cancel, () => Navigator.pop(context), context),


              ],)
          ),

          Expanded(
            flex: 15,
            child: buildVisor(model, context, this),
          ),

          Expanded(
            flex: 5,
            child: Row(
              children: [
                FlatButton.icon(
                  color: CC.widgetColor(WN.buttonColor, 0),
                  onPressed: !isActive() ?  null : () {
                    model.setItem(["0", qrText, qrText]);
                    model.recordWeight();
                    goneToZero = false;
                    qrText = "";
                  },
                  icon: Icon(Icons.add, color: getButtonColor()),
                  label: Text(qrText != "" ? ' $qrText' : model.tr.localize("Waiting for code") , style: TextStyle(color: getButtonColor(), fontSize: 18 )  ),

                ),
                Spacer(),

                FlatButton.icon(
                  color: CC.widgetColor(WN.buttonColor, 0),
                  onPressed:resetCounter,
                  icon: Icon(Icons.cancel, color: getButtonColor()),
                  label: Text(sprintf("%d", [model.counter+1]) , style: TextStyle(color: getButtonColor(), fontSize: 18 )  ),

                ),



              ],
            ),
          ),

          Expanded(
             flex: 40,
            child:MobileScanner(
                allowDuplicates: false,
                controller: MobileScannerController(
                    facing: CameraFacing.back, torchEnabled: true),
                onDetect: (barcode, args) {
                  if (barcode.rawValue == null) {
                    debugPrint('Failed to scan Barcode');
                  } else {

                    setState(() {
                      qrText = barcode.rawValue;
                      debugPrint('Barcode found! $qrText');
                    });


                  }
                }),
          ),
        ],
      ),
    ),
    );
  }


  @override
  void dispose() {
    model.removeSubscriptors(this);


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
