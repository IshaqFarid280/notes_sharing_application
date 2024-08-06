import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_sharing_application/const/firebase_const.dart';
import 'package:notes_sharing_application/views/categoryScrenn/notify_all_users_Screen.dart';
import 'package:notes_sharing_application/views/home_Screen/view_subject_screen.dart';
import 'package:notes_sharing_application/widgets_common/categories_widget.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../widgets_common/bg_widgets.dart';

class CategoryScreen extends StatelessWidget {
  final String currentUserUid;

  CategoryScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                left: 4.0, right: 8.0, top: 4.0, bottom: 4.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('events').snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Image.asset(
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
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain,
              ),
            );
          }

          var userCreatedEvents = snapshot.data!.docs.where((document) {
            final data = document.data() as Map<String, dynamic>;
            return data['createdBy'] == currentUserUid;
          }).toList();

          if (userCreatedEvents.isEmpty) {
            return Center(
              child: Image.asset(
                'assets/myeventEMPTY.jpeg',
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain,
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: userCreatedEvents.map((document) {
                  final data = document.data() as Map<String, dynamic>;
                  final dateTime = (data['dateTime'] as Timestamp).toDate();
                  final formattedDateTime =
                  DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

                  final int invitedUserLength = (data['isfavorite'] as List).length;
                  final int isGoingLength = (data['goingusers'] as List).length;
                  final bool isGoing =
                  (data['goingusers'] as List).contains(currentUserUid);

                  return GestureDetector(
                    onLongPress: () async {
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Event"),
                            content: Text("Are you sure you want to delete this event?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text("Delete"),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await firestore.collection('events').doc(document.id).delete();
                        Get.snackbar("Event Deleted", "Your event has been deleted successfully.");
                      }
                    },
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
                      invitedUserLength.toString(),
                      isGoingLength.toString(),
                      data['description'] ?? 'No Description',
                      formattedDateTime,
                      Colors.black,
                      Colors.white,
                      data['images'][0] ?? '',
                      context,
                      data['locationevent'] ?? 'N/A',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotifyAllUsersScreen(
                              data: data,
                            ),
                          ),
                        );
                      },
                          () {},
                      Icons.notifications,
                      isGoing ? 'You are Going' : 'Going',
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
