import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initilize() {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _notificationsPlugin.initialize(initializationSettings);
  }

  static void showNotificationOnForeground(RemoteMessage message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'com.example.lost_and_find_app',
      'lost_and_find_app',
      channelDescription: 'Lost and Find App Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/launcher_icon", // Add your custom icon here
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    _notificationsPlugin.show(
      DateTime.now().microsecond,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data["message"],
    );
  }

}