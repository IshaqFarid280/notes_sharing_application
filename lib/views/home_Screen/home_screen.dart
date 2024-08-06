import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_sharing_application/controlller/event_controller.dart';
import 'package:notes_sharing_application/views/home_Screen/add_new_subject_screen.dart';
import 'package:notes_sharing_application/views/home_Screen/events_map_screen.dart';
import 'package:notes_sharing_application/views/home_Screen/view_subject_screen.dart';
import 'package:notes_sharing_application/widgets_common/categories_widget.dart';
import 'package:velocity_x/velocity_x.dart';

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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsMapScreen()
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.map),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 4.0, bottom: 4.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {

              return  Image.asset(
                'assets/slowconnections.jpeg',
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain,
              );

          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Image.asset(
                'assets/myeventEMPTY.jpeg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: snapshot.data!.docs.map((document) {
                final data = document.data() as Map<String, dynamic>;
                final dateTime = (data['dateTime'] as Timestamp).toDate();
                final formattedDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
                final bool isInterested = (data['isfavorite'] as List).contains(currentUserUid);
                final bool isGoing = (data['goingusers'] as List).contains(currentUserUid);


                final int inviteduserlength =  (data['isfavorite'] as List).length;
                final int iisGoinglength =  (data['goingusers'] as List).length;
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
                    inviteduserlength.toString() ?? 'N/A',
                    iisGoinglength.toString() ?? 'N/A',
                    data['description'] ?? 'No Description',
                    formattedDateTime,
                    Colors.black,
                    Colors.white,
                    data['images'][0] ?? '',
                    context,
                    data['locationevent'] ?? 'N/A',
                        () {
                      _eventController.toggleInterest(document.id, currentUserUid);
                      // favorite button - smaall button to favorite

                    },
                        () {
                          _eventController.toggleGoing(document.id, currentUserUid);
                      // interested buton - the big button
                    },
                    isInterested ? Icons.favorite : Icons.favorite_border,
                    isGoing ? 'You are Going' : 'Going',

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
