import 'package:Dana/screens/pages/notifications_screen.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBarWidget extends StatelessWidget {
  final String? title, subtitle;
  Widget? icon;
  final bool? leading, isTab;

  AppBarWidget(
      {this.title, this.subtitle, this.icon, this.isTab, this.leading});

  @override
  Widget build(BuildContext context) {
    return isTab!
        ? AppBar(
            toolbarHeight: 100,
            actions: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    icon!,
                    SizedBox(width: 20),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationsScreen()));
                        },
                        child: Icon(Icons.notifications,
                            color: lightColor, size: 30)),
                  ],
                ),
              )
            ],
            title: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset('assets/images/me.jpeg'),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!,
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.w600)),
                      Text(subtitle!,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            automaticallyImplyLeading: false,
            centerTitle: false,
            backgroundColor: darkColor,
            brightness: Brightness.dark,
            elevation: 5,
          )
        : AppBar(
            toolbarHeight: 100,
            title: Text(title!,
                style: TextStyle( 
                    color: Colors.white,
                    fontSize: 20)),
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: darkColor,
            brightness: Brightness.dark,
            elevation: 5,
          );
  }
}
