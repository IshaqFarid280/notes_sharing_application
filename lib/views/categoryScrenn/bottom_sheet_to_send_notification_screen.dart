import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

import '../../services/notification_sevices.dart';

class BottomSheetToSendNotificationScreen extends StatefulWidget {
  const BottomSheetToSendNotificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  _BottomSheetToSendNotificationScreenState createState() =>
      _BottomSheetToSendNotificationScreenState();
}

class _BottomSheetToSendNotificationScreenState
    extends State<BottomSheetToSendNotificationScreen> {
  Map<int, String> _addresses = {};
  NotificationServices _notificationServices = NotificationServices(); // Instantiate NotificationServices

  Future<void> _getPlacemark(int index, LatLng location) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        setState(() {
          _addresses[index] = address;
        });
      }
    } catch (e) {
      print('Error getting placemark: $e');
      setState(() {
        _addresses[index] = 'Unknown address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  // Call the sendNotificationToAllUsers method
                  await _notificationServices.sendNotificationToAllUsers(
                    'Notification Title', // Replace with your title
                    'Notification Body', // Replace with your body
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: normalText(
                        text: 'Send Notification',
                        color: Colors.white,
                        size: 18.0,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No users available'));
              }

              final users = snapshot.data!.docs;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final double latitude = double.parse(user['latitude'].toString());
                  final double longitude = double.parse(user['longitude'].toString());
                  final String name = user['name'] ?? 'Unknown';
                  final LatLng location = LatLng(latitude, longitude);

                  if (!_addresses.containsKey(index)) {
                    _getPlacemark(index, location);
                  }
                  print('the user name: ${user['name']}');
                  print('the user token: ${user['token']}');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(name),
                    subtitle: Text(_addresses[index] ?? 'Fetching address...'),
                    onTap: () {
                      // Handle user selection
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
