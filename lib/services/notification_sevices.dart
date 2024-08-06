import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:notes_sharing_application/const/firebase_constants.dart';
import 'package:notes_sharing_application/views/auth_screen/login.dart';

class NotificationServices {
  final String fireBaseEndPoint = 'https://www.googleapis.com/auth/firebase.messaging';
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission');
    }
  }

  Future<void> firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      initLocalNotification(context, message);
      showNotification(message);
    });
  }

  Future<void> initLocalNotification(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          handleMessage(context, message);
        });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      enableVibration: true,
      enableLights: true,
      playSound: true,
      ledColor: Colors.cyan,
      Random.secure().nextInt(10000).toString(),
      'High Importance Notification',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      icon: '@mipmap/ic_launcher', // Replace with your app's launcher icon,
      channelDescription: 'Your Channel Description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      enableLights: true,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      color: Colors.red,
      category: AndroidNotificationCategory.reminder,
      colorized: true,
      channelShowBadge: true,
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  Future<String?> getDeviceToken() async {
    return await messaging.getToken();
  }

  Future<void> saveTokenToFirestore(String token) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({'token': token});
  }

  Future<void> sendNotificationToAllUsers(List<Map<String, dynamic>> usersInRange, String title, String body) async {
    Map<String, String> allUserTokens = await _getAllUserTokens();

    String accessToken = await getAccessToken();

    for (var user in usersInRange) {
      if (allUserTokens.containsKey(user['id'])) {
        String token = allUserTokens[user['id']]!;
        await _sendNotification(token, title, body, accessToken);
      }
    }
  }

  Future<Map<String, String>> _getAllUserTokens() async {
    Map<String, String> tokens = {};
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in querySnapshot.docs) {
        String? token = doc.get('token');
        if (token != null) {
          tokens[doc.id] = token;
        }
      }
    } catch (e) {
      print('Error retrieving tokens: $e');
    }
    return tokens;
  }

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "notesharingapp-6ff5c",
        "private_key_id": "3d40dc61836ba5df94d614ecf712c87afd1422dc",
        "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCvSPz+QG8Shtak\nWlZWB/qYM3LEGu5Nyii2atONSkKMNG3yyEJ8ldR+RwyuPFzzzploQnIKesROVncI\n4fGwSJ3/P4st3sQV1tysac4s8f2hoeBWLu6bEgGgp0SFcXltpJl9een/+hssdNWx\n1EvouVewHAgf3XU3Dj1LGWue8qkTRumFF5rA3c4XHHKiBGzvnqWghh9ywxXTsa/a\n5mZH+6f4xlqGEXLVAMqg744l/4YeIdPMx6mO1iJdxiBUhpjPo1JaHFZFE1qf4g8H\n/ezPOCLC1X2n5CxMCfwQaber2Iio9ZKfLX0MfDgaUrax/YP0vhLYQPk1/y8VmCb1\nZ5nHfNG7AgMBAAECggEAHV9XtatKcYpS0Xup2ATCQ1rrslzo7fQgWmEQTi7Rc/kd\nK3/PVF0vHHH/d/r5gIlwP35S6dqkppPqonxqKaYhg7I8OlWH+jjlBac9O17Zp4oe\ns5JtvWKJD0i4PLxFItBgQBx7z78zaoGxhXkTt03HmeU4n05W5ADo2HrMA/iZyHbk\nkCu6/AuCuc7FdViSxcZ5eE5QNKaYTWwrI37nBwdPOWpzWHA7FZaXxF00XHZZKxaV\nwr9dh7Ezy1FqokT19cjPNSnBJLieM+d85m1JVp81BILB2wtoKSKYIuc7pzQrQZB6\nzFKscecFKWYcWXRQYBm2GWb3fpCpazJSWuvXagYo8QKBgQDUFEEaWIfbYKBME/Ch\nOncufPq58QGUa6ifItwzzcfkAaTl2HKyqZV47QT+kgVASv5KZLZ3tWXRUUq6dQqk\n8qLJqrnAp4HJ29eh7R9+eLz2NG5CawjiHfK1UQ09f0gOHPazyztQthc1oeSXhOw0\nhwMbPrE3qAY+jRLctqrvg/fx/QKBgQDTlgkDO8D5QXniHI15yPxnjIqvbS1RwjDe\nAJUSN3qICh0CS1nytjg8m4Krst8N5E0mcbEN4R0/pY9CioCQE0xpN0/J6fy6M0mU\ndKhy0M3L0p25Qst091biqY6VKGtPeX4vmszPr8fqizBmhHfJ8OASzQ3A9ZviCYdx\n8BTdmPCkFwKBgGsrqRKFNnI3zAll8i2ne960LYeVMLUuClIQrbJIBQFFi2zTCnMa\nm3w2WlXCuICa5RH2/vZTZpZ2PAspZi2gp369lYyzmTTGsZsUVtv0a5kHOci6igyq\nEaJqyQQQs/rdzBVjWCAbRHNH0lp3Q13v9DPqZGe5sx4c8DE05gCPcdaJAoGAfdIu\nsdmKu66QCEHqb41xazJMFl3aIVBVNu8ptpd/Kf65mW+toYNylbf0UJ4hvmUQ69eX\n7iT7+6k8M9mg8gxH2BmoPO4D98Yf70QgF4bLmnU4jb6GtpuO82LZAyHyDmS1ASIQ\nwUBKpdL3iT8k7NVsqkF9+E0V0ajQ/pRCFDSqhSkCgYBcqi9Ow0QtgMna+ZtNchqE\nxqCi9hKKKnROL7lQfIpDzYImpsjrzdCRbJr8IMFQJWrlYFIqugmGXK2sHhP6x6tp\ngBMOYGMhpZmF50YfpyleyWVZvKA6BB59F4kI4FTsDoSmG8sP0PY3qIanTXFoZsud\ngG/yQFuEtAjJ2CI06sKF3A==\n-----END PRIVATE KEY-----\n",
        "client_email":
        "firebase-adminsdk-qs02z@notesharingapp-6ff5c.iam.gserviceaccount.com",
        "client_id": "112186893480866140367",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
        "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-qs02z%40notesharingapp-6ff5c.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }),
      [fireBaseEndPoint],
    );
    final accessToken = client.credentials.accessToken.data;
    print('Access Token : $accessToken');
    return accessToken;
  }

  Future<void> _sendNotification(
      String token, String title, String body, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/notesharingapp-6ff5c/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully to $token');
      } else {
        print(
            'Failed to send notification to $token. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}
