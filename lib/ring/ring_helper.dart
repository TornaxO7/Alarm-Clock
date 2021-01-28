import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../Classes/alarm_clock.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RingHelper {
  AlarmClock alarmClock;
  List weekdays;

  String debugName = 'Ring';

  // checks the offset of the timezone
  Duration timeZoneOffste = DateTime.now().timeZoneOffset;

  RingHelper(AlarmClock alarmClock) {
    this.alarmClock = alarmClock;
    this.weekdays = this.alarmClock.weekdays;
  }

  // check if the alarm is set for tomorrow
  bool tomorrow(tz.TZDateTime currentTime) {
    // posDay is meant to be used like this:
    // monday = 0
    // tuesday = 0
    // ....
    int posDay;

    tz.TZDateTime tomorrowDateTime = currentTime.add(Duration(days: 1));

    posDay = tomorrowDateTime.weekday - 1;

    String tomorrowDay = DateFormat.EEEE().format(tomorrowDateTime);
    dev.log('Selected day $tomorrowDay', name: debugName);

    if (weekdays[posDay] == 1) {
      return true;
    }
    return false;
  }

  // convert the String that contains the time to tz.TZDateTime
  tz.TZDateTime convertTZDateTime(String selectedTime) {
    var selectedTimes = selectedTime.split(':');
    tz.TZDateTime now = tz.TZDateTime.now(tz.UTC);
    tz.TZDateTime convertedTime = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, int.parse(selectedTimes[0]), int.parse(selectedTimes[1]), 00);

    return convertedTime;
  }

  // returns the next time the selected alarm rings
  tz.TZDateTime nextRing() {
    tz.TZDateTime chosenTime =
        // alarmClock.time is always saved with the offset 0
        // subtracting the current offset prevents problems
        convertTZDateTime(alarmClock.time).add(-timeZoneOffste);
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    dev.log('Time now $now', name: debugName);
    dev.log('chosen time $chosenTime', name: debugName);

    if (chosenTime.isBefore(now)) {
      chosenTime = findNextTime(chosenTime);
      dev.log('${alarmClock.time} has already passed', name: debugName);
      dev.log('New time: ${chosenTime}', name: debugName);
    }

    return chosenTime;
  }

  // determin the next time the alarm rings
  tz.TZDateTime findNextTime(tz.TZDateTime currentTime) {
    do {
      // check if the alarm is set on the next day
      // if this is not the chase a day is added
      currentTime = currentTime.add(Duration(days: 1));
    } while (tomorrow(currentTime) == false);
    dev.log('Next Ring on $currentTime', name: debugName);
    String nextDay = DateFormat.EEEE().format(currentTime);
    dev.log('It will ring on ${nextDay}', name: debugName);

    return currentTime;
  }

  // look in the flutter_local_notification plugin for more infromation
  // if required
  showNotification() async {
    dev.log('Current alarm id: ${alarmClock.id}', name: debugName);

    // add safety function that sets a least on day to true
    // otherwise the 'tomorrow' function will be stuck in loop
    failSafe();

    // debug message that shows the active days of the selected alarm
    activOn();

    var androidDetails = AndroidNotificationDetails(
        alarmClock.id.toString(),
        'alarm nr.${alarmClock.id}',
        'This should display a notification for the alarms',
        fullScreenIntent: true,
        priority: Priority.high,
        importance: Importance.high);
    var platFormDetails = new NotificationDetails(android: androidDetails);
    if (alarmClock.active == 1)
      await flutterLocalNotificationsPlugin.zonedSchedule(alarmClock.id,
          'Wecker App', alarmClock.name, nextRing(), platFormDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          // give the notification screen the alarm name
          payload: alarmClock.name);
  }

  void activOn() {
    for (int i = 0; i < weekdays.length; i++) {
      if (weekdays[i] == 1) {
        dev.log('day ${i + 1} is active', name: debugName);
      }
    }
  }

  void failSafe() {
    if (!weekdays.contains(1)) {
      int today = tz.TZDateTime.now(tz.local).weekday;
      weekdays[today - 1] = 1;
    }
  }
}
