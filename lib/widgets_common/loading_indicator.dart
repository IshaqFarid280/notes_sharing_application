
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sharing_application/const/colors.dart';

Widget loadingIndicator(){
  return const CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation(redColor),
  );
}