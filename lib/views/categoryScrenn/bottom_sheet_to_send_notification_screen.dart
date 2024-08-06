import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

import '../../services/notification_sevices.dart';

class BottomSheetToSendNotificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> usersInRange;
  final dynamic eventdata;

  const BottomSheetToSendNotificationScreen({
    Key? key,
    required this.usersInRange,
    required this.eventdata,
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
    print(widget.usersInRange);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {

                  await _notificationServices.sendNotificationToAllUsers(

                    widget.usersInRange,
                    '${widget.eventdata['title']} event',
                    'A new Event is happening is Happening. Come Join us',
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
          child: ListView.builder(
            itemCount: widget.usersInRange.length,
            itemBuilder: (context, index) {
              final user = widget.usersInRange[index];
              final LatLng location = LatLng(user['latitude'], user['longitude']);

              if (!_addresses.containsKey(index)) {
                _getPlacemark(index, location);
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.2),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['name']),
                subtitle: Text(_addresses[index] ?? 'Fetching address...'),
                onTap: () {
                  // Handle user selection
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
