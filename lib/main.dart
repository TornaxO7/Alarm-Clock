/* =======================
 * Imports
 * ======================= */
import 'package:flutter/material.dart';
import 'package:wecker/alert_clock_list.dart';
import 'package:wecker/old_screen.dart';
import 'create_alarm/create_alarm.dart';

import 'dart:developer' as dev;

void main() {
  dev.log("Application installed!", name: "Application");

  runApp(MaterialApp(initialRoute: '/', routes: {
    '/': (context) => _HomeScreen(),
    '/createAlarmClock': (context) => CreateAlarm(),
    '/oldscreen': (context) => OldScreen(),
    '/forth': (context) => CreateAlarm(),
    '/AlarmClockListScreen': (context) => AclScreen()
  }));
}

/* =======================
 * The main routes
 * ======================= */
class _HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Alter App (DEV -- Version!'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(children: <Widget>[
          RaisedButton(
              child: Text('Create Alarm'),
              onPressed: () {
                Navigator.pushNamed(context, '/forth');
              }),
          RaisedButton(
            child: Text('Alarm Clock List'),
            onPressed: () {
              Navigator.pushNamed(context, '/AlarmClockListScreen');
            },
          ),
        ]),
      ),
    );
  }
}
