import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotifyUsers extends StatefulWidget {
  const NotifyUsers({super.key});

  @override
  State<NotifyUsers> createState() => _NotifyUsersState();
}

class _NotifyUsersState extends State<NotifyUsers> {
  late Timer _timer;
  String _currentTime = '';
  String? mToken;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var time = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 27);

  var time2 = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 27);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          _currentTime = _getCurrentTime();
        });
      }
    });
    requestPermission();
    getCurrentToken();
    _scheduleNotifications();
    _scheduleNotifications2();
    sendPushMessage();
    sendPushMessage2();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotifications() async {


    await _localScheduleNotification(time);
  }

  Future<void> _scheduleNotifications2() async {


    await _localScheduleNotification2(time2);
  }

  Future<void> _localScheduleNotification(DateTime scheduledTime) async {
    // var currentTime = DateTime.now();
    // var notificationTimes = [Time(10, 27, 0)];
    //
    // for (var time in notificationTimes) {
    //   var scheduledTime = tz.TZDateTime(
    //     tz.local,
    //     currentTime.year,
    //     currentTime.month,
    //     currentTime.day,
    //     time.hour,
    //     time.minute,
    //   );
    //
    //   if (scheduledTime.isAfter(DateTime.now())) {
    //     await _scheduleNotification(scheduledTime);
    //   }
    // }

    var scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print("This is ScheduledTime: ${scheduledTime}");

    print("This is Tz ScheduledTIme: ${scheduledTZTime}");

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'dbNotifyMessage',
      'dbNotifyMessage',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Notification',
      'This is a scheduled notification',
      scheduledTZTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _localScheduleNotification2(DateTime scheduledTime) async {
    // var currentTime = DateTime.now();
    // var notificationTimes = [Time(10, 27, 0)];
    //
    // for (var time in notificationTimes) {
    //   var scheduledTime = tz.TZDateTime(
    //     tz.local,
    //     currentTime.year,
    //     currentTime.month,
    //     currentTime.day,
    //     time.hour,
    //     time.minute,
    //   );
    //
    //   if (scheduledTime.isAfter(DateTime.now())) {
    //     await _scheduleNotification(scheduledTime);
    //   }
    // }

    var scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print("This is ScheduledTime: ${scheduledTime}");

    print("This is Tz ScheduledTIme: ${scheduledTZTime}");

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'dbNotifyMessage2',
      'dbNotifyMessage2',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Scheduled Notification',
      'This is a scheduled notification',
      scheduledTZTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  String _getCurrentTime() {
    var now = DateTime.now();
    return '${_formatTimeUnit(now.hour)}:${_formatTimeUnit(now.minute)}:${_formatTimeUnit(now.second)}';
  }

  String _formatTimeUnit(int unit) {
    return unit < 10 ? '0$unit' : '$unit';
  }

  Future<void> getCurrentToken() async {
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mToken = token;
      });
    });
  }

  void requestPermission() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print("User Granted");
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User Granted Provisional permission");
    } else {
      print("User declined");
    }
  }

  void sendPushMessage() async {

    try {
      print("This is Mtoken: ${mToken}");
      String formattedTime = time.toIso8601String();
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAFLK96Uw:APA91bHXRrKaetf3X1tr-WX-BeilsFJ8MOiT-_jEzhj4R8idA80AbLbppcpzdN0cMdKNgkTgNXyH3q0_nT6MR0CGXrAnV5OgO1dCMomO-57_Bx9LUmJ7qA0QVaYbnpfXJEkec7X-AoMF',
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': 'body',
            'title': 'title',
          },
          "notification": <String, dynamic>{
            "title": 'title',
            "body": 'body',
            "isScheduled" : true,
            "scheduledTime" : formattedTime,
            "android_channel_id": "dbNotifyMessage"
            //"scheduledTime" : "2024-04-27 10:27:00",
          },
          "to": mToken,
        }),
      );
      print("This is TOken: ${mToken}");
    } catch (e) {
      throw e.toString();
    }
  }

  void sendPushMessage2() async {
    try {
      print("This is Mtoken: ${mToken}");
      String formattedTime2 = time2.toIso8601String();
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAFLK96Uw:APA91bHXRrKaetf3X1tr-WX-BeilsFJ8MOiT-_jEzhj4R8idA80AbLbppcpzdN0cMdKNgkTgNXyH3q0_nT6MR0CGXrAnV5OgO1dCMomO-57_Bx9LUmJ7qA0QVaYbnpfXJEkec7X-AoMF',
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': 'body',
            'title': 'title',
          },
          "notification": <String, dynamic>{
            "title": 'title',
            "body": 'body',
            "isScheduled" : true,
            "scheduledTime" : formattedTime2,
            "android_channel_id": "dbNotifyMessage2"
            //"scheduledTime" : "2024-04-27 11:27:00",
          },
          "to": mToken,
        }),
      );
      print("This is TOken: ${mToken}");
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Times"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Time: $_currentTime',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
