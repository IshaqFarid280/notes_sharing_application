import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/const/firebase_const.dart';
import 'package:notes_sharing_application/const/styles.dart';
import 'package:notes_sharing_application/controlller/event_controller.dart';
import 'package:notes_sharing_application/views/home_Screen/view_subject_screen.dart';
import 'package:notes_sharing_application/widgets_common/categories_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class FavoriteScreen extends StatelessWidget {
  final String currentUserUid;
  final EventController _eventController = Get.put(EventController());

  FavoriteScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: "Favorites".text.fontFamily(semibold).color(darkFontGrey).make(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Image.asset(
              'assets/slowconnections.jpeg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            );
          }
          if (!snapshot.hasData) {
            return Image.asset(
              'assets/myeventEMPTY.jpeg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            );
          }

          // Filter events based on isInterested condition
          var favoriteEvents = snapshot.data!.docs.where((document) {
            final data = document.data() as Map<String, dynamic>;
            return (data['isfavorite'] as List).contains(currentUserUid);
          }).toList();

          if (favoriteEvents.isEmpty) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: favoriteEvents.map((document) {
                  final data = document.data() as Map<String, dynamic>;
                  final dateTime = (data['dateTime'] as Timestamp).toDate();
                  final formattedDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

                  final bool isInterested = (data['isfavorite'] as List).contains(currentUserUid);
                  final bool isGoing = (data['goingusers'] as List).contains(currentUserUid);

                  final int invitedUserLength = (data['isfavorite'] as List).length;
                  final int isGoingLength = (data['goingusers'] as List).length;

                  return categorywidget(
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
                      _eventController.toggleInterest(document.id, currentUserUid);
                    },
                        () {
                      _eventController.toggleGoing(document.id, currentUserUid);
                    },
                    isInterested ? Icons.favorite : Icons.favorite_border,
                    isGoing ? 'You are Going' : 'Going',
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
