import 'package:flutter/material.dart';
import 'CSVDatabase.dart';
import 'ActiveText.dart';
import 'LabeledSegments.dart';

class CSVDatabaseView extends StatefulWidget {
  List<CSVDatabase> databases;
  Function action;
  Function cancel;

  CSVDatabaseView(
      List<CSVDatabase> databases, Function action, Function cancel) {
    this.databases = databases;
    this.action = action;
    this.cancel = cancel;
  }

  _CSVDatabaseViewState createState() =>
      _CSVDatabaseViewState(databases, action, cancel);
}

class _CSVDatabaseViewState extends State<CSVDatabaseView> {
  List<CSVDatabase> databases;
  int currentDatabase = 0;
  Function action;
  Function cancel;

  String searchString = '';

  _CSVDatabaseViewState(
      List<CSVDatabase> databases, Function action, Function cancel) {
    this.databases = databases;
    this.action = action;
    this.cancel = cancel;
    this.currentDatabase = 0;
  }

  @override
  void initState() {
    super.initState();
  }

  void searchChanged(String text) {
    setState(() {
      searchString = text.toUpperCase();
    });
  }

  void doIt(element) {
    action([currentDatabase, element]);
  }

  void add(text){
    setState(() {

      if (currentDatabase == 0){
        databases[currentDatabase].add([text, text, text]);
      } else {
        databases[currentDatabase].add([text, text]);
      }
      searchChanged(text);

    });

  }

  Widget buildDatabaseSelector(Function f) {
    return Container(
      width: 350, //boxSize.width + 5,
      height: 420,
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              labeledSegmentsFromTextNoTitle(databases.map((e) => e.name()).toList(), currentDatabase,  (int i) {
                  setState(() {
                    currentDatabase = i % databases.length;
                  });
              }),

              /*Text(databases[currentDatabase].name()),
              Spacer(),
              Container(
                height: 40,
                width: 40,
                child: activeIcon(Icons.arrow_right, next, context),
              ),
*/
              Spacer(),
              Container(
                height: 40,
                width: 40,
                child: activeIcon(Icons.cancel, close, context),
              ),

            ],
          ),
          Row(
              children: [

                Container(
                  width: 290,
                  child:
                  TextField(
                      onChanged: searchChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search',
                      )),
                ),
                IconButton(
                    onPressed: () => add(searchString),
                    icon: const Icon(Icons.add)),

              ]),
          Spacer(),
          Container(
            height: 295,
            width: 350,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: buildRowList(f),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowList(Function f) {
    List<Widget> childrens = [];

    var titles = true;
    print("Current Database $currentDatabase  Len ${databases[currentDatabase].count()}");
    databases[currentDatabase].rows.forEach((element) {
      String s = element[1].toString().toUpperCase();

      if (titles) {
        titles = false;
      } else if (searchString.length == 0 || s.contains(searchString)) {
        childrens.add(
          Container(
              height: 30,
              width: 350,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => f([currentDatabase, element]),
                child: Text(element[1].toString(), textAlign: TextAlign.left),
              )),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childrens,
    );
  }

  void close() {
    this.cancel();
  }
  void next() {
    setState(() {
      currentDatabase = (currentDatabase + 1) % databases.length;
    });

  }

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return buildDatabaseSelector(action);
  }
}
