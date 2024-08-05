
import 'package:flutter/cupertino.dart';
import 'package:notes_sharing_application/const/images.dart';


Widget bgWidget({required Widget? child}){
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imgBackground), fit: BoxFit.fill,
      )
    ),
    child: child,
  );
}