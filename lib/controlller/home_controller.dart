
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:notes_sharing_application/const/firebase_const.dart';

class HomeController extends GetxController{

  var navIndex = 0.obs;
  var currentUserUid = ''.obs;

  var products = <Product>[].obs;
  @override
  void onInit() {
    super.onInit();
    // updateUserDetails();
    loadUserData();
    super.onInit();
  }

  void resetController() {
    navIndex.value = 0;
    loadUserData();
  }
  var currentNavIndex = 0.obs;
  var username = '';
  var searchController = TextEditingController();

  getUsername()async{
    var n = await firestore.collection(usersCollection).where('id', isEqualTo: currentUser!.uid).get().then((value){
      if(value.docs.isNotEmpty){
        return value.docs.single['name'];
      }
    });
    username = n;
    // username.value = n ?? ''; // Assign value using .value to trigger UI update

  }
  void loadUserData() {
    currentUserUid.value = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('Loading user data for: ${currentUserUid.value}');
  }
  @override
  void onClose() {
    // Perform cleanup if necessary
    super.onClose();
  }

}
class Product {
  // Define your product properties here
  Product.fromDocument(DocumentSnapshot doc) {
    // Initialize properties from document
  }
}