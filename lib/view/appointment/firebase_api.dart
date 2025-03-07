import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pim/core/constants/api_constants.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Store notifications for foreground display
  List<RemoteMessage> notifications = [];

  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> initNotifications(String fullName) async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await getFcmToken();
    print("FCM Token: $fcmToken");

    if (fcmToken != null) {
      await sendFcmTokenToBackend(fullName, fcmToken);
    } else {
      print("No FCM Token available!");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      print("New Notification: ${message.notification?.body}");
      print("Received at: ${DateTime.now()}");

      bool isDuplicate = notifications.any((existingMessage) =>
          existingMessage.notification?.title == message.notification?.title &&
          existingMessage.notification?.body == message.notification?.body);

      if (!isDuplicate) {
        notifications.add(message);

        await _showNotification(
          message.notification?.title,
          message.notification?.body,
        );
      }

      print("Notification count: ${notifications.length}");
    });
  }

  Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pimpim-e4b35', // Channel ID
      'PimPim', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    int uniqueId = DateTime.now()
        .millisecondsSinceEpoch
        .remainder(100000); // Ensuring unique notification ID

    await _flutterLocalNotificationsPlugin.show(
      uniqueId,
      title,
      body,
      platformDetails,
      payload: 'notification_payload_$uniqueId',
    );
  }

  Future<void> sendFcmTokenToBackend(String fullName, String fcmToken) async {
    final url = Uri.parse(ApiConstants.updateFcmTokenEndpoint);
    await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"fullName": fullName, "fcmToken": fcmToken}),
    );
  }
}
