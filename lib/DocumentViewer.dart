import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'GRAMModel.dart';
import 'ActiveText.dart';

import "ColorCompatibility.dart";


class DocumentViewer extends StatefulWidget {

  final String url;

  DocumentViewer(this.url);
  _DocumentViewerState createState() => _DocumentViewerState(url);
}

class _DocumentViewerState extends State<DocumentViewer> {

  String url;

  GRAMModel model = GRAMModel.shared;
  WebViewController _controller;

  _DocumentViewerState(this.url);


  @override
  void initState() {
    super.initState();

  }
  void close() {
    model.removeSubscriptors(this);
    Navigator.pop(context);
  }




  Widget buildWidget() {

    print("URL : $url");

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row( mainAxisAlignment: MainAxisAlignment.end,
              children: [


                  Spacer(),

                  Container(
                    height: 30,
                    child: activeIcon(Icons.close, close, context),
                ),
      ]
          ),

          Expanded(child:WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) => _controller = webViewController,
          ),
        ),
 // End of expanded
         ],
      ), // End of Column
      ), // End of Container


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
