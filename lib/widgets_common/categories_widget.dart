import 'package:flutter/material.dart';
import 'package:notes_sharing_application/const/colors.dart';
import 'package:notes_sharing_application/widgets_common/our_button.dart';

Widget categorywidget(
    VoidCallback ontap,
    IconData icons,
    String text,
    String interested,
    String going,
    String description,
    String date,
    Color colors,
    Color containerColor,
    String imageUrl,
    BuildContext context,
    String location,
    VoidCallback notificationbuttonONTAP,
    VoidCallback interestedbuttonONTAP,
    IconData iconData,
    String interestedbuttontext,
    ) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: InkWell(
      onTap: ontap,
      child: Card(
        elevation: 5.0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: containerColor,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.2,
                )
                    : Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.grey,
                  child: Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date.toUpperCase(),
                      style: TextStyle(
                        color: fontGrey,
                        fontSize: 11.0,
                      ),
                    ),
                    Text(
                      text,
                      style: TextStyle(
                          color: darkFontGrey,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        color: darkFontGrey.withOpacity(0.4),
                        fontSize: 12.0,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${interested} interested * ',
                          style: TextStyle(
                            color: darkFontGrey.withOpacity(0.6),
                            fontSize: 11.0,
                          ),
                        ),
                        Text(
                          '${going} going',
                          style: TextStyle(
                            color: darkFontGrey.withOpacity(0.6),
                            fontSize: 11.0,
                          ),
                        ),

                      ],
                    ),
                    customButton(
                      buttonColors: Colors.grey.withOpacity(0.4),
                      isfavorite: true,
                      widths: 0.7,
                      intrestedbuttonontap: interestedbuttonONTAP,
                      text: interestedbuttontext,
                      icondata: iconData,
                      favoritebuttonontap: notificationbuttonONTAP,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
