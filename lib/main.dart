import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:message_me/screens/dashboard_screen.dart';
import 'package:message_me/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyANmVt9qM6zDrRmkL5e1_4zNsXOVWx7SlE',
        appId: '1:88898136396:android:c38e340604292122ab87e9',
        messagingSenderId: '88898136396',
        projectId: 'pin-you-e886f',
        storageBucket: 'pin-you-e886f.appspot.com'),
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth? firebaseAuth = FirebaseAuth.instance;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notfication Messages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          firebaseAuth.currentUser != null ? DashBoardScreen() : LoginScreen(),
    );
  }
}
