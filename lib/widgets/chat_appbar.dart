import 'package:dana/screens/pages/notifications_screen.dart';
import 'package:dana/screens/pages/user_profile.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatAppBar extends StatelessWidget {
  final String title, subtitle;
  Widget icons;

  ChatAppBar({this.title, this.subtitle, this.icons});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      actions: [icons],
      iconTheme: IconThemeData(color: Colors.white),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserProfile()));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset('assets/images/me.jpeg'),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins-Bold',
                            color: Colors.white)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins-Regular',
                            color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      backgroundColor: darkColor,
      brightness: Brightness.dark,
      elevation: 5,
    );
  }
}
