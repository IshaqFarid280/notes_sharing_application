import 'package:flutter/material.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

class ViewSubjectScreen extends StatelessWidget {
  final String title;
  final String interested;
  final String going;
  final String description;
  final String dateTime;
  final String imageUrl;
  final String location;
  final String organizer;

  const ViewSubjectScreen({
    super.key,
    required this.title,
    required this.interested,
    required this.going,
    required this.description,
    required this.dateTime,
    required this.imageUrl,
    required this.location,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
            ),
            normalText(
              text: dateTime,
              size: 11.0,
              color: Colors.grey.withOpacity(0.8),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: normalText(
                text: title,
                size: 19.0,
                color: darkFontGrey,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                normalText(
                  text: 'Public',
                  size: 11.0,
                  color: Colors.grey.withOpacity(0.8),
                ),
                normalText(
                  text: ' - Event by ',
                  size: 11.0,
                  color: Colors.grey.withOpacity(0.8),
                ),
                normalText(
                  text: organizer,
                  size: 11.0,
                  color: darkFontGrey,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  widths: 0.4,
                  favoritebuttonontap: () {},
                  intrestedbuttonontap: () {},
                  text: 'Interested',
                  buttonColors: Colors.blueAccent.withOpacity(0.99),
                  isfavorite: false,
                  textcolor: whiteColor,
                  isicon: true,
                  icons: Icons.star,
                  iconColor: whiteColor,
                ),
                customButton(
                  widths: 0.4,
                  buttonColors: Colors.grey.withOpacity(0.2),
                  favoritebuttonontap: () {},
                  intrestedbuttonontap: () {},
                  text: 'Going',
                  isfavorite: false,
                  textcolor: Colors.black,
                  isicon: false,
                  icons: Icons.outgoing_mail,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.location_pin),

                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: normalText(
                        text: location,

                        color: darkFontGrey.withOpacity(0.9),
                        weight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_box),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: normalText(
                        text: 'N/A going',
                        color: darkFontGrey.withOpacity(0.9),
                      weight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                thickness: 2.0,
                color: darkFontGrey.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      normalTextwithoutcenter(
                        text: 'What to expect',
                        size: 18.0,
                        color: darkFontGrey
                      ),
                    ],
                  ),  normalTextwithoutcenter(
                    text: description,
                    size: 12.0,
                    color: darkFontGrey.withOpacity(0.7),
                    weight: FontWeight.w400
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
