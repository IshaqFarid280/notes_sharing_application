import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:velocity_x/velocity_x.dart';

Widget ourButton({onpressed, color, textColor, String? title}) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color, padding: EdgeInsets.all(12)),
      onPressed: onpressed,
      child: title!.text.color(textColor).white.fontFamily(bold).make());
}

Widget normalText(
    {text,
    color = Colors.white,
    size = 14.0,
    font = semibold,
    weight = FontWeight.w700}) {
  return "$text"
      .text
      .color(color)
      .fontWeight(weight)
      .center
      .size(size)
      .fontFamily(font)
      .make();
}

Widget normalTextwithoutcenter(
    {text,
    color = Colors.white,
    size = 14.0,
    font = semibold,
    weight = FontWeight.w700}) {
  return "$text"
      .text
      .color(color)
      .fontWeight(weight)
      .size(size)
      .fontFamily(font)
      .make();
}

Widget boldText({text, color = Colors.white, size = 14.0, font = semibold}) {
  return "$text".text.size(size).color(color).fontFamily(font).make();
}

class customButton extends StatelessWidget {
  final String text;
  final double widths;
  final double height;
  final Color buttonColors;
  final Color iconColor;
  final Color textcolor;
  final double borderradius;
  final IconData icons;
  final IconData icondata;
  final bool isfavorite;
  final bool isicon;
  final VoidCallback intrestedbuttonontap;
  final VoidCallback favoritebuttonontap;
  const customButton(
      {super.key,
      required this.favoritebuttonontap,
      required this.intrestedbuttonontap,
      required this.text,
      this.height = 0.04,
      this.buttonColors = Colors.grey,
      this.icons = Icons.add,
      this.icondata = Icons.star,
      this.iconColor = Colors.black,
      this.isfavorite = false,
      this.textcolor = Colors.black,
      this.isicon = false,
      this.widths = 0.75,
      this.borderradius = 4.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: intrestedbuttonontap,
            child: Container(
              width: MediaQuery.of(context).size.width * widths,
              height: MediaQuery.of(context).size.height * height,
              decoration: BoxDecoration(
                color: buttonColors,
                borderRadius: BorderRadius.circular(borderradius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isfavorite == true
                      ? Container(
                          height: 0,
                          width: 0,
                        )
                      : Icon(
                          icons,
                          color: iconColor,
                        ),
                  isfavorite == true
                      ? Container(
                          height: 0,
                          width: 0,
                        )
                      : Container(
                          height: 0,
                          width: 4,
                        ),
                  Text(
                    text,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                        color: textcolor),
                  ),
                ],
              ),
            ),
          ),
          isfavorite == true
              ? InkWell(
                  onTap: favoritebuttonontap,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    child: Center(child: Icon(icondata)),
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                )
        ],
      ),
    );
  }
}
