import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_sharing_application/const/firebase_const.dart';
import 'package:notes_sharing_application/controlller/event_controller.dart';
import 'package:notes_sharing_application/views/home_Screen/add_new_subject_screen.dart';
import 'package:notes_sharing_application/views/home_Screen/view_subject_screen.dart';
import 'package:notes_sharing_application/widgets_common/categories_widget.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserUid;
  final EventController _eventController = Get.put(EventController());

  HomeScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Event Organiser'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewSubjectScreen(currentUserUid: currentUserUid),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.add),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.calendar_month),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 4.0, bottom: 4.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: snapshot.data!.docs.map((document) {
                final data = document.data() as Map<String, dynamic>;
                final dateTime = (data['dateTime'] as Timestamp).toDate();
                final formattedDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

                return Center(
                  child: categorywidget(
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewSubjectScreen(
                            title: data['title'] ?? 'No Title',
                            interested: data['interested'] ?? 'N/A',
                            going: data['going'] ?? 'N/A',
                            description: data['description'] ?? 'No Description',
                            dateTime: formattedDateTime,
                            imageUrl: data['images'][0] ?? '',
                            location: data['locationevent'] ?? 'No Location',
                            organizer: data['organizer'] ?? 'Unknown',
                          ),
                        ),
                      );
                    },
                    Icons.add,
                    data['title'] ?? 'No Title',
                    data['interested'] ?? 'N/A',
                    data['going'] ?? 'N/A',
                    data['description'] ?? 'No Description',
                    formattedDateTime,
                    Colors.black,
                    Colors.white,
                    data['images'][0] ?? '', // Pass the imageUrl here
                    context,
                    data['locationevent'] ?? 'N/A',
                        (){},
                    Icons.star,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
