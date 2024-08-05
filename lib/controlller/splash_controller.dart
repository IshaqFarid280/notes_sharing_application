import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/bottom_navigation_Screen.dart';
import 'package:notes_sharing_application/services/notification_sevices.dart';
import 'package:notes_sharing_application/views/auth_screen/login.dart';

class SplashController extends GetxController {
  final NotificationServices notificationServices = NotificationServices();
  FirebaseAuth? auth = FirebaseAuth.instance;
  Future<void> initialize(context) async {
    await notificationServices.requestNotificationPermission();
    await notificationServices.firebaseInit(context);
    String? token = await notificationServices.getDeviceToken();
    if (token != null && auth?.currentUser?.uid != null) {
      print('Firebase Token : $token');
      await notificationServices.saveTokenToFirestore(token);
      print('token successfuly gett');
      Get.to(() => bottomnavigationscreen(), transition: Transition.cupertino);
    } else {
      print('token not getted');
      Get.to(() => LoginPage(), transition: Transition.cupertino);
    }
  }
}
