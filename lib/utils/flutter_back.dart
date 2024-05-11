import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool notificationShown = false; // Variable to track notification state

Future<void> initializeServices() async {
  final service = FlutterBackgroundService();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'script acedmy',
    "foreground",
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: 'script acedmy',
        initialNotificationTitle: 'foreground',
        initialNotificationContent: 'initalizing',
        foregroundServiceNotificationId: 888,
      ));
  service.startService();
}

@pragma('vm-entry-point')
void onStart(ServiceInstance serviceInstance) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (serviceInstance is AndroidServiceInstance) {
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });
    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }

  serviceInstance.on('stopService').listen((event) {
    serviceInstance.stopSelf();
  });

  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (serviceInstance is AndroidServiceInstance) {
      if (await serviceInstance.isForegroundService() && !notificationShown) {
        // Check if the service is in foreground and notification hasn't been shown yet
        flutterLocalNotificationsPlugin.show(
            888,
            "women safety App",
            'women safety',
            NotificationDetails(
                android: AndroidNotificationDetails(
                  'script acedmy',
                  "foreground",
                  icon: '@mipmap/ic_launcher',
                  ongoing: true,
                )));
        notificationShown = true; // Update the state to indicate notification shown
      }
    }
  });
}
