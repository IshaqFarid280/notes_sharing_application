import 'package:flutter/material.dart';


class mediaHeight extends StatelessWidget {
  final double? height;
  const mediaHeight({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*height!,
    );
  }
}


class mediaWidth extends StatelessWidget {
  final double? width;
  const mediaWidth({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.height*width!,
    );
  }
}

Widget width(context, double width){
  return Container(
    width: MediaQuery.of(context).size.height*width!,
  );
}