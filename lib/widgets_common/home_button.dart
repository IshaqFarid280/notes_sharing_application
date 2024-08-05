import 'package:flutter/cupertino.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:velocity_x/velocity_x.dart';

Widget homeButton({required width, required height, required icon, required String title,  onPress}){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(icon, width: 26),
      5.heightBox,
      title.text.fontFamily(semibold).color(darkFontGrey).make(),

    ],
  ).box.rounded.white.size(width, height).make();
}