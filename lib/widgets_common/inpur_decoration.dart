import 'package:flutter/material.dart';

const textinputDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w300,
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFee7b64),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFee7b64),
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFee7b64),
    ),
  ),
);
void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnakBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
      backgroundColor: color,
    ),
  );
}
