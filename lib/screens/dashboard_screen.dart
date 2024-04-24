import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  DatabaseReference userRef = FirebaseDatabase.instance.ref();

  TextEditingController sendMessageController = TextEditingController();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String? mToken = "";

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    try {
      if (title != null && title.isNotEmpty) {

        print("Yes");

      } else {

        print("No");

      }
    } catch (e) {
      throw e.toString();
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse? response) {
    if (response != null) {

      print("hello");

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    getCurrentToken();
    initInfo();
  }

  void initInfo() async {
    var androidInitialize =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitialize,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'dbMessage',
        'dbMessage',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      NotificationDetails platformChannelSpecifies = NotificationDetails(
          android: androidNotificationDetails,
          iOS:  DarwinNotificationDetails());

      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifies,
          payload: message.data['title']);
    });
  }

  Future<void> getCurrentToken() async {
    await firebaseMessaging.getToken().then((token) {
      setState(() {
        mToken = token;
      });

      saveToken(token!);
    });
  }

  void saveToken(String token) {
    // DatabaseReference userAttendanceRef = userRef
    //     .child("UsersToken")
    //     .child(firebaseAuth.currentUser!.email!.replaceAll(".", "_"));

    DatabaseReference userAttendanceRef = userRef
        .child("UsersToken")
        .child(firebaseAuth.currentUser!.displayName!);

    userAttendanceRef.set({'token': token});
  }

  void requestPermission() async {
    NotificationSettings notificationSettings =
    await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

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

  void sendPushMessageToOtherUsers(String body, String title) async {
    try {
      // Retrieve all user tokens from the database
      DatabaseEvent dataSnapshot = await userRef.child("UsersToken").once();
      if (dataSnapshot.snapshot.value != null) {
        Map<dynamic, dynamic>? usersData =
        dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;


        print("This is userData: $usersData");


        if (usersData != null) {
          for (var entry in usersData.entries) {
            var value = entry.value;
            var key = entry.key;

            print("this is Key: $key");


            String? recipientToken = value['token'];
            if (recipientToken != null && recipientToken.isNotEmpty && firebaseAuth.currentUser!.displayName != key) {

              print("Sending notification to: $recipientToken");


              // Send the notification to the recipient's token
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
                    'body': body,
                    'title': title,
                  },
                  "notification": <String, dynamic>{
                    "title": title,
                    "body": body,
                    "android_channel_id": "dbMessage"
                  },
                  "to": recipientToken,
                }),
              );
            } else {

              print("Recipient token is empty or null for user: ${entry.key}");

            }
          }
        }
      } else {

        print('No user data found');

      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(firebaseAuth.currentUser!.displayName!),
        centerTitle: true,

      ),
      body: Center(
        child: Column(

          children: [
            Padding(
              padding:  EdgeInsets.only(top: 150, left: 30, right: 30),
              child: TextFormField(
                controller: sendMessageController,
                decoration:  InputDecoration(
                    border: OutlineInputBorder(), hintText: "Enter a Message"),
              ),
            ),
            SizedBox(height: 100,),
            MaterialButton(
              color: Colors.black,
              onPressed: () {
                sendPushMessageToOtherUsers(sendMessageController.text, 'AAS');
              },
              child:  Text(
                "Send a Message",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
