import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GRAMModel.dart';
import 'package:permission_handler/permission_handler.dart';


class LabeledSlider extends StatefulWidget {

  String _name;
  double _min;
  double _max;
  double _value;
  Function _changed;
  bool enabled = true;

  LabeledSlider(this._name, this._min, this._max, this._value, this._changed, this.enabled);

  _LabeledSliderState createState() => _LabeledSliderState();
}

class _LabeledSliderState extends State<LabeledSlider> {


  @override
  Widget build(BuildContext context) {
    print("Minimum ${widget._min}");

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(widget._name, textAlign: TextAlign.left),
          Spacer(),
          Container(
            width: 40,
            child: Text('${widget._value.round()} %', textAlign: TextAlign.right,),
          ),
          Slider(min: widget._min,
              max: widget._max,
              value: widget._value,
              onChanged:  widget.enabled ? (value) {
                setState(() {
                  widget._value = value;
                });
              } : null,
              onChangeEnd: widget._changed),
        ]
    );
  }



}
