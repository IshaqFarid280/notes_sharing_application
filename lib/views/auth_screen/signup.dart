import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';
import 'package:notes_sharing_application/services/notification_sevices.dart';
import 'package:notes_sharing_application/widgets_common/app_logo_widget.dart';
import 'package:notes_sharing_application/widgets_common/bg_widgets.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:velocity_x/velocity_x.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthController authController = Get.find();
  final NotificationServices notificationServices = NotificationServices();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool? isCheck = false;
  String? token;

  Future<void> initializeSignupForToken(context) async {
    await notificationServices.requestNotificationPermission();
    await notificationServices.firebaseInit(context);
    token = await notificationServices.getDeviceToken();
    if (token != null) {
      print('Firebase Token : $token in signup screen');
      await notificationServices.saveTokenToFirestore(token!);
    } else {
      print('Token successfully obtained in signup screen');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeSignupForToken(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: bgWidget(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: redColor,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                children: [
                  (context.screenHeight * 0.1).heightBox,
                  applogoWidget(),
                  10.heightBox,
                  "Join the $appname".text.fontFamily(bold).white.size(18).make(),
                  15.heightBox,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      'Name'.text.color(redColor).fontFamily(semibold).size(16).make(),
                      5.heightBox,
                      TextFormField(
                        obscureText: false,
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontFamily: semibold,
                            color: textfieldGrey,
                          ),
                          hintText: "Enter Name",
                          isDense: true,
                          fillColor: lightGrey,
                          filled: true,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: redColor,
                            ),
                          ),
                        ),
                      ),
                      5.heightBox,
                      'Email'.text.color(redColor).fontFamily(semibold).size(16).make(),
                      5.heightBox,
                      TextFormField(
                        obscureText: false,
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontFamily: semibold,
                            color: textfieldGrey,
                          ),
                          hintText: "Enter Email",
                          isDense: true,
                          fillColor: lightGrey,
                          filled: true,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: redColor,
                            ),
                          ),
                        ),
                      ),
                      5.heightBox,
                      'Password'.text.color(redColor).fontFamily(semibold).size(16).make(),
                      5.heightBox,
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontFamily: semibold,
                            color: textfieldGrey,
                          ),
                          hintText: "Enter Password",
                          isDense: true,
                          fillColor: lightGrey,
                          filled: true,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: redColor,
                            ),
                          ),
                        ),
                      ),
                      5.heightBox,
                      Row(
                        children: [
                          Checkbox(
                            activeColor: redColor,
                            checkColor: redColor,
                            value: isCheck,
                            onChanged: (newValue) {
                              setState(() {
                                isCheck = newValue;
                              });
                            },
                          ),
                          10.widthBox,
                          Expanded(
                            child: RichText(
                              text: const TextSpan(children: [
                                TextSpan(
                                  text: "I agree to the ",
                                  style: TextStyle(
                                    fontFamily: regular,
                                    fontSize: 12,
                                    color: fontGrey,
                                  ),
                                ),
                                TextSpan(
                                  text: termAndConditions,
                                  style: TextStyle(
                                    fontFamily: regular,
                                    fontSize: 12,
                                    color: redColor,
                                  ),
                                ),
                                TextSpan(
                                  text: " & ",
                                  style: TextStyle(
                                    fontFamily: regular,
                                    fontSize: 12,
                                    color: redColor,
                                  ),
                                ),
                                TextSpan(
                                  text: privacyPolicy,
                                  style: TextStyle(
                                    fontFamily: regular,
                                    fontSize: 12,
                                    color: redColor,
                                  ),
                                ),
                              ]),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ourButton(
                    onpressed: () => authController.signup(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      token!,
                    ),
                    color: redColor,
                    textColor: whiteColor,
                    title: 'Sign Up',
                  ).box.width(context.screenWidth - 50).make(),
                  10.heightBox,
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                          text: alreadyhaveaccount,
                          style: TextStyle(
                            fontFamily: bold,
                            fontSize: 12,
                            color: fontGrey,
                          ),
                        ),
                        TextSpan(
                          text: login,
                          style: TextStyle(
                            fontFamily: bold,
                            color: redColor,
                            fontSize: 12,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ).box.white.rounded.padding(const EdgeInsets.all(16)).width(context.screenWidth - 70).height(context.screenHeight - 150).shadowSm.make(),
            ),
          ),
        ),
      ),
    );
  }
}
