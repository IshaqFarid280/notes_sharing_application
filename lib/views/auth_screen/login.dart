import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';
import 'package:notes_sharing_application/views/auth_screen/signup.dart';
import 'package:notes_sharing_application/widgets_common/app_logo_Widget.dart';
import 'package:notes_sharing_application/widgets_common/bg_widgets.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../const/strings.dart';

class LoginPage extends StatelessWidget {
  var controlleer = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              applogoWidget(),
              10.heightBox,
              "Join the $appname".text.fontFamily(bold).white.size(18).make(),
              15.heightBox,
              Column(
                children: [
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
                                color: redColor
                            )
                        )
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
                                color: redColor
                            )
                        )
                    ),
                  ),
                  5.heightBox

                ],
              ),

              SizedBox(height: 20),
              ourButton(
                onpressed: () => controlleer.login(
                  _emailController.text,
                  _passwordController.text,
                ),
                color: redColor,
                title: login,
                textColor: whiteColor,
              ).box
                  .width(context.screenWidth - 50)
                  .make(),
              5.heightBox,
              createaNewAccount.text.color(fontGrey).make(),
              5.heightBox,
              ourButton(
                  color: lightgolden,
                  title: signup,
                  textColor: redColor,
                  onpressed: () {
                    Get.to(()=>SignupPage());
                  })
                  .box
                  .width(context.screenWidth - 50)
                  .make(),
              10.heightBox,
              loginwith.text.color(fontGrey).make(),
              5.heightBox,
            ],
          )  .box
              .white
              .rounded
              .padding(EdgeInsets.all(16))
              .width(context.screenWidth - 70)
              .height(context.screenHeight -150)
              .shadowSm
              .make(),
        ),
      ),
    );
  }
}
