import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';  // Add this import
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/firebase_const.dart';
import 'package:notes_sharing_application/const/strings.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/auth_controller.dart';
import 'package:notes_sharing_application/widgets_common/app_logo_Widget.dart';
import 'package:notes_sharing_application/widgets_common/bg_widgets.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:io'; // Add this import

class ProfileScreen extends StatefulWidget {
  final String currentUserUid;

  ProfileScreen({required this.currentUserUid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  File? _imageFile;  // Variable to store the selected image
  String? _imageUrl; // Variable to store the image URL

  Stream<DocumentSnapshot<Map<String, dynamic>>> _fetchUserDataStream(String userId) {
    return FirebaseFirestore.instance.collection(usersCollection).doc(userId).snapshots();
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}';
      } else {
        return 'Address not found';
      }
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Show a dialog to confirm and upload the image
      _showConfirmUploadDialog();
    }
  }

  Future<void> _showConfirmUploadDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Profile Image'),
        content: _imageFile != null
            ? Image.file(_imageFile!)
            : Text('No image selected'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              if (_imageFile != null) {
                await _uploadImage();
              }
            },
            child: Text('Update Image'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${widget.currentUserUid}.jpg');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user's profile in Firestore
      await FirebaseFirestore.instance.collection(usersCollection).doc(widget.currentUserUid).update({
        'image': downloadUrl,
      });

      setState(() {
        _imageUrl = downloadUrl;
      });

      Get.snackbar("Success", "Profile image updated successfully", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile image: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _handleLogout() async {
    await authController.signOut();
    Get.offAllNamed('/login'); // Redirect to the login screen and clear the navigation stack
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: redColor,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: whiteColor),
                ),
                onPressed: _handleLogout,
                child: logout.text.fontFamily(semibold).white.make(),
              ),
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _fetchUserDataStream(widget.currentUserUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data()!;
              final latitude = userData['latitude'] is double ? userData['latitude'] as double : 0.0;
              final longitude = userData['longitude'] is double ? userData['longitude'] as double : 0.0;

              return FutureBuilder<String>(
                future: _getAddressFromCoordinates(latitude, longitude),
                builder: (context, addressSnapshot) {
                  if (addressSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (addressSnapshot.hasError) {
                    return Center(child: Text('Error: ${addressSnapshot.error}'));
                  } else if (addressSnapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : userData['image'] != ''
                                    ? NetworkImage(userData['image'])
                                    : null,
                                child: _imageFile == null && userData['image'] == ''
                                    ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ),
                          ),
                          // SizedBox(height: 16.0),
                          // if (_imageFile != null)
                          //   ElevatedButton(
                          //     onPressed: _uploadImage,
                          //     child: Text('Update Image'),
                          //   ),
                          SizedBox(height: 16.0),
                          normalText(text: 'Name:', size: 22.0, color: darkFontGrey, weight: FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: normalText(text: '${userData['name'] ?? 'N/A'}', size: 16.0, color: darkFontGrey.withOpacity(0.8), weight: FontWeight.w700),
                          ),
                          SizedBox(height: 16.0),
                          normalText(text: 'Email:', size: 22.0, color: darkFontGrey, weight: FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: normalText(text: '${userData['email'] ?? 'N/A'}', size: 16.0, color: darkFontGrey.withOpacity(0.8), weight: FontWeight.w700),
                          ),
                          SizedBox(height: 16.0),
                          normalText(text: 'Location:', size: 22.0, color: darkFontGrey, weight: FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: normalText(text: '${addressSnapshot.data ?? 'N/A'}', size: 14.0, color: darkFontGrey.withOpacity(0.8), weight: FontWeight.w700),
                          ),
                          // Password should not be displayed
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
