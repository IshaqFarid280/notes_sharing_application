
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:velocity_x/velocity_x.dart';

Widget customTextField({required String title, required String hint, controller, isPass}){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title.text.color(redColor).fontFamily(semibold).size(16).make(),
      5.heightBox,
      TextFormField(
        obscureText: isPass,
        controller: controller,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontFamily: semibold,
            color: textfieldGrey,
          ),
          hintText: hint,
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
  );
}