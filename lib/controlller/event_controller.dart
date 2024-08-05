import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EventController extends GetxController {
  var events = <DocumentSnapshot>[];
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final RxBool isLoadingindicaator = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      events = snapshot.docs;
    } catch (e) {
      errorMessage('Error fetching events: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> postEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String visibility,
    required String userId,
    required String location,
    required double latitude,
    required double longitude,
    required List<XFile> images,
  }) async {
    try {
      isLoadingindicaator.value = true;

      final eventRef = FirebaseFirestore.instance.collection('events').doc(); // Auto-generated ID

      // Upload images
      List<String> imageUrls = [];
      for (var image in images) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child('${DateTime.now().millisecondsSinceEpoch}_${image.name}');
        final uploadTask = storageRef.putFile(File(image.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Define eventId as the document ID
      String eventId = eventRef.id;

      // Add event to Firestore
      await eventRef.set({
        'eventId': eventId,
        'title': title,
        'description': description,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdBy': userId,
        'privacy': visibility,
        'latitude': latitude,
        'longitude': longitude,
        'locationevent': location,
        'images': imageUrls.isEmpty ? ['https://via.placeholder.com/150'] : imageUrls,
        'invitedUsers': [],
        'notifications': [],
        'posts': [],
        'eventDetails': description,
        'eventName': title,
      });
    } catch (e) {
      print('Error posting event: $e');
    } finally {
      isLoadingindicaator.value = false;
    }
  }

}
