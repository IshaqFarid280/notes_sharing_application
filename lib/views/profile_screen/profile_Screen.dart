import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';
import 'package:notes_sharing_application/views/auth_screen/signup.dart';
import 'package:notes_sharing_application/widgets_common/app_logo_Widget.dart';
import 'package:notes_sharing_application/widgets_common/bg_widgets.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatelessWidget {
  final String currentUserUid;

  ProfileScreen({required this.currentUserUid});
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    // var controller = Get.put(ProfileController());
    print('the get user id: ${currentUserUid}');

    return bgWidget(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: redColor,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: whiteColor),
                  ),
                  onPressed: () { authController.signOut();},
                  child: logout.text.fontFamily(semibold).white.make(),
                ),
              ),
            ],
          ),


      ),
    );
  }
}
