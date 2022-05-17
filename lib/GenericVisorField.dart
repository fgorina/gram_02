import 'package:flutter/material.dart';
import 'GRAMModel.dart';
import 'GRAMMessage.dart';
import 'dart:async';


class GenericVisorField extends StatefulWidget {

  AddressType _variable;

  Duration _refresh;

  GenericVisorField(this._variable,  this._refresh);

  _GenericVisorFieldState createState() => _GenericVisorFieldState();

}

class _GenericVisorFieldState extends State<GenericVisorField>{
  GRAMModel model = GRAMModel.shared;
  String _value = "";
  Timer timex;

  void initState() {
    super.initState();
    model.addSubscriptor(this, tecnic: true);

    startTimer();
  }

  void dispose() {
    if (timex != null) {
      timex.cancel();
    }

    model.removeSubscriptors(this);

    super.dispose();
  }

  void startTimer(){
    if (timex != null) {
      timex.cancel();
    }
    model.connection.enqueueMessage(GRAMMessage.readAddress(widget._variable));

    timex = Timer(widget._refresh, () {
      startTimer();
    });

  }

  void tecnicUpdated(AddressType someType, String data) {
    if (someType == widget._variable && data != _value ){
      setState((){
        _value = data;
      });
    }

  }

  @override
  Widget build(BuildContext context){

    return Text(_value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold),);
  }


}