import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';

class Logger extends StatefulWidget {
  @override
  _LoggerState createState() => _LoggerState();
}

class _LoggerState extends State<Logger> {
  int selectedIndex = 1;

  DateTime selectedDate = DateTime.now(); //get current time and date

  List<Map> data = List();

  @override
  void initState() {
    //actions exectued at the start of this widget
    getData(selectedDate.toString().substring(0, 10));
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2019, 11),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        this.getData(selectedDate.toString().substring(0, 10));
      });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (selectedIndex == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'Gas Logger')),
        );
      }
    });
  }

  Future<Null> getData(String datePicked) async {
    final response = await http.get(
        'https://api.thingspeak.com/channels/1245213/feeds.json?api_key=9WVZPJCIUQ41KRW8');
    setState(() {
      var resp = json.decode(response.body); //get a json object
      var feeds = resp["feeds"];
      if (data.isNotEmpty) {
        data.clear();
      }
      for (var elem in feeds) {
        //transforming and filtering json object
        var d = elem["created_at"];
        d = d.substring(0, 10);
        if (d == datePicked) {
          data.add(elem);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Logger"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Selected date:" +
                    selectedDate.toString().substring(0, 10)),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Time")),
                    DataColumn(label: Text("Gas level"))
                  ],
                  rows: data
                      .map(
                        ((element) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(element["created_at"].substring(
                                  11,
                                ))),
                                DataCell(Text(element["field1"])),
                              ],
                            )),
                      )
                      .toList(),
                ),
              )
            ]),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Logger",
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
