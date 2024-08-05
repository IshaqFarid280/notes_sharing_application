import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_sharing_application/const/firebase_const.dart';
import 'package:notes_sharing_application/views/auth_screen/getlocation_screen.dart';

class AuthController extends GetxController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userData = {}.obs;


  Future<void> _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed("/login");
    } else {
      bool userExists = await _checkUserExists(user.uid);
      if (userExists) {
        await _loadUserData(user.uid);
        Get.offAllNamed("/main");
      } else {
        Get.offAllNamed("/login");
        Get.snackbar("Error", "User does not exist or has been deleted", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> signup(String name, String email, String password, String token) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((v){
         _firestore.collection('users').doc(currentUser!.uid).set({
          'name': name,
          'email': email,
          'password': password,
          'uid': currentUser!.uid,
          'image': '',
          'location': 'location_here',
          'latitude': 'latitifude',
          'longitude': 'longitiude',
          'token': token,
          // 'token':
        });
         return v ;
      });
      // Navigate to the MapScreen only after successful signup
      Get.to(() => MapScreen(userid: userCredential.user!.uid,));
    } catch (e) {
      print('Signup failed: $e');
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> _checkUserExists(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists;
  }

  Future<void> _loadUserData(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    userData.value = userDoc.data() as Map<String, dynamic>;
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      bool userExists = await _checkUserExists(userCredential.user!.uid);
      if (userExists) {
        await _loadUserData(userCredential.user!.uid);
        Get.offAllNamed("/main");
      } else {
        Get.snackbar("Error", "User does not exist or has been deleted", snackPosition: SnackPosition.BOTTOM);
        await signOut();
      }
    } catch (e) {
      print('Login failed: $e');
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // In auth_controller.dart
  Future<void> updateLocation(String userId, double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
