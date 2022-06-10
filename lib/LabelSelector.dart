import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'LocalFileSystemUtilities.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class LabelSelector extends StatefulWidget {
  List<String> labels;
  Function callback;
  Function closeCallback;
  Function deleteCallback;


  LabelSelector(List<String> labels, Function callback, Function closeCallback, Function deleteCallback) {
    this.labels = labels;
    this.callback = callback;
    this.closeCallback = closeCallback;
    this.deleteCallback = deleteCallback;

  }

  _LabelSelectorState createState() => _LabelSelectorState();
}

class _LabelSelectorState extends State<LabelSelector> {
  final ScrollController _scrollController  = ScrollController();

  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children:[
              Text("Select a label", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              IconButton(onPressed: widget.closeCallback, icon: Icon(Icons.close)),
            ],
          ),

          Divider(
            color: Theme.of(context).primaryColor,
          ),
          Container(
            width: 200,
            height: 280,
            child:
            Scrollbar(
            controller: _scrollController,
            child: ListView.separated(
                itemCount: widget.labels.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, index) {
                  return Container(

                    child: ListTile(
                      enabled: true,
                      isThreeLine: false,
                      title: Text(p.basename(widget.labels[index]), style: TextStyle(fontSize: 12
                      )),
                      dense: true,

                      onTap:(){
                        print(widget.labels[index]);
                        widget.callback(widget.labels[index]);

                        },
                      trailing: IconButton(onPressed: (){
                        widget.deleteCallback(widget.labels[index]);
                      }, icon: Icon(Icons.delete)),

                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Theme.of(context).primaryColor,
                  );
                }),
            ),
          ),
        ],
      ),
    );
  }
}
