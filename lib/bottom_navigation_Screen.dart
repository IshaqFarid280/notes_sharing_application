

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/images.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/home_controller.dart';
import 'package:notes_sharing_application/views/cart_screen/cart_screen.dart';
import 'package:notes_sharing_application/views/categoryScrenn/category_screen.dart';
import 'package:notes_sharing_application/views/home_Screen/home_screen.dart';
import 'package:notes_sharing_application/views/profile_screen/profile_Screen.dart';
import 'package:notes_sharing_application/widgets_common/exit_dialog.dart';

class bottomnavigationscreen extends StatefulWidget {
  const bottomnavigationscreen({Key? key}) : super(key: key);

  @override
  State<bottomnavigationscreen> createState() => _bottomnavigationscreenState();
}

class _bottomnavigationscreenState extends State<bottomnavigationscreen> {
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    print('the current id in Bottom navigation bar: ${controller.currentUserUid.value}');
    // init home controller
    var navBarItem = [
      BottomNavigationBarItem(icon: Image.asset(icHome, width: 26), label: home ),
      BottomNavigationBarItem(icon: Image.asset(icCategories, width: 26), label: myevent ),
      BottomNavigationBarItem(icon: Image.asset(icCart, width: 26), label: cart),
      BottomNavigationBarItem(icon: Image.asset(icProfile, width: 26), label: account ),
    ];
    var navBody = [
      HomeScreen(currentUserUid: controller.currentUserUid.value,),
      CategoryScreen(currentUserUid: controller.currentUserUid.value,),
      CartScreen(currentUserUid: controller.currentUserUid.value),
      ProfileScreen(currentUserUid: controller.currentUserUid.value,)
    ];
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            barrierDismissible: false,
            context: context, builder: (context)=> exitDialog(context));
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            Obx(()=> Expanded(child: navBody.elementAt(controller.currentNavIndex.value))),
          ],
        ),
        bottomNavigationBar: Obx(() =>
            BottomNavigationBar(
              currentIndex: controller.currentNavIndex.value,
              selectedItemColor: redColor,
              selectedLabelStyle: TextStyle(
                  fontFamily: semibold
              ),
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: navBarItem,
              onTap: (value){
                controller.currentNavIndex.value = value;
              },
            ),
        ),

      ),
    );
  }
}
