import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/bottom_navigation_Screen.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';
import 'package:notes_sharing_application/controlller/splash_controller.dart';
import 'package:notes_sharing_application/views/auth_screen/login.dart';
import 'package:notes_sharing_application/views/auth_screen/signup.dart';
import 'package:notes_sharing_application/widgets_common/app_logo_Widget.dart';
import 'package:velocity_x/velocity_x.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessageBackgroundHandler);
  Get.put(AuthController());
  runApp(MyApp());
}



@pragma('vm:entry-point')
Future<void> _firebaseMessageBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appname,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: darkFontGrey),
        ),
      ),
      initialRoute: '/splash', // Set the initial route to splash screen
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()), // Splash screen route
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/signup', page: () => SignupPage()),
        GetPage(name: '/main', page: () => bottomnavigationscreen()),
      ],
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.initialize(context);
  }
  var controller = Get.put(SplashController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: redColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (context.screenHeight * 0.1).heightBox,
          applogoWidget(),
          10.heightBox,
          "Join the $appname".text.fontFamily(bold).white.size(18).make(),
          15.heightBox,
          Text(
            'Welcome to $appname',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
