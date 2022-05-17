import 'package:flutter/material.dart';
import 'ActiveText.dart';
import 'ColorCompatibility.dart';
import 'Log.dart';
import 'screensize_reducers.dart';
import 'package:share/share.dart';
class LogViewer extends StatefulWidget {
  _LogViewerState createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  Log log = Log.shared;

  @override
  void initState() {
    super.initState();
    Log.shared.updateSelected();
  }

  void close() {
    print("closing");
    Navigator.pop(context);
  }

  void modelUpdated() {
    setState(() {});
  }

  void changeLevel(LogNivell level, bool value) {
    setState(() {
      Log.shared.selectedLevels[level] = value;
      Log.shared.updateSelected();
    });
  }

  void share() async{
    var s = Log.shared.exportFormat();
    //print(s);
    await Share.share( s, subject: "Log");

  }

  void clear() async{
    setState(() {
      Log.shared.clearLog();

    });

  }

  Widget buildWidget() {
    return SafeArea(

      //padding: EdgeInsets.only(left: 0, top: 0.0, right: 0, bottom: 0.0),
      child: Container(
        height: screenHeight(context),
        decoration:
        BoxDecoration(color: CC.widgetColor(WN.backgroundViewColor, 0)),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
            padding: EdgeInsets.only(left: 20, top: 20.0, right: 20.0, bottom: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                height: 30,
                child: activeIcon(Icons.share, share, context),
              ),
              Container(
                height: 30,
                child: activeIcon(Icons.clear, clear, context),
              ),

              Container(

               height: 30,
                child: activeIcon(Icons.cancel, close, context),
              ),
            ]),
            ),

            Row(
                children: [
                  Checkbox(
                    value: log.selectedLevels[LogNivell.error],
                    onChanged: (x) => changeLevel(LogNivell.error, x),
                  ),

                  Text("Error"),
                  Spacer(),
                  Checkbox(
                    value: log.selectedLevels[LogNivell.warning],
                    onChanged: (x) => changeLevel(LogNivell.warning, x),
                  ),
                  Text("Warning"),
                  Spacer(),
                  Checkbox(
                    value: log.selectedLevels[LogNivell.info],
                    onChanged: (x) => changeLevel(LogNivell.info, x),
                  ),
                  Text("Info"),
                  Spacer(),
                  Checkbox(
                    value: log.selectedLevels[LogNivell.trace],
                    onChanged: (x) => changeLevel(LogNivell.trace, x),
                  ),
                  Text("Trace"),

                ]
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 10.0, right: 0.0, bottom: 0.0)),

            Container(

              height: screenHeight(context) - 150,
             child: ListView.builder(itemCount: Log.shared.selectedCount(),
                itemBuilder: (BuildContext ctxt, int index) {
                  return Container(

                    color: Log.shared
                        .getSelectedLog(index)
                        .color,


                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Log.shared
                            .getSelectedLog(index)
                            .date
                            .toString(),
                          textAlign: TextAlign.right,),

                        Text(Log.shared
                            .getSelectedLog(index)
                            .from),

                        Text(Log.shared
                            .getSelectedLog(index)
                            .contents),

                      ],
                    ),
                  );

                },

            ),
            ),
          ],
        ), // END OF COLUMN
      ),
    ); // End of Container
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
