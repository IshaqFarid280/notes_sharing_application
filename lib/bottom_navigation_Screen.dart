

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/images.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/home_controller.dart';
import 'package:notes_sharing_application/views/categoryScrenn/category_screen.dart';
import 'package:notes_sharing_application/views/favortite_Screens/favorite_screen.dart';
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
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 24,), label: 'Dashboard' ),
      BottomNavigationBarItem(icon:Icon(Icons.space_dashboard_outlined, size: 24,), label: 'My Events' ),
      BottomNavigationBarItem(icon: Icon(Icons.favorite_border, size: 24,), label: 'Favorites'),
      BottomNavigationBarItem(icon:Icon(Icons.account_circle_outlined, size: 24,), label: 'Profile' ),
    ];
    var navBody = [
      HomeScreen(currentUserUid: controller.currentUserUid.value,),
      CategoryScreen(currentUserUid: controller.currentUserUid.value,),
      FavoriteScreen(currentUserUid: controller.currentUserUid.value),
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
