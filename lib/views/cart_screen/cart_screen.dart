import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../widgets_common/our_button.dart';

class CartScreen extends StatelessWidget {
  final String currentUserUid;

  CartScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    print('the current id in cart screen: ${currentUserUid}');

    return Scaffold(
        backgroundColor: whiteColor,
        // bottomNavigationBar: SizedBox(
        //   height: 60,
        //     child: ourButton(
        //         color: redColor,
        //         onpressed: () {
        //           Get.to(()=> ShippingDetail());
        //         },
        //         textColor: whiteColor,
        //         title: 'Proceed to Shipping')),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: "My Bookings"
              .text
              .fontFamily(semibold)
              .color(darkFontGrey)
              .make(),
        ),
    );
  }
}
