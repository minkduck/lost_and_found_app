import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');

}

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

class FirebaseNotification {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future initPushNotifications() async {
    print('initPushNotifications called');
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );

    LocalNotificationService.initilize();

    FirebaseMessaging.instance.getInitialMessage().then((event) {});

    //Forground State
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.showNotificationOnForeground(event);
    });

    //Background State
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
    });

  }


  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', fCMToken.toString());
    // print("fcmToken: " + fCMToken.toString());
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotifications();
  }
}