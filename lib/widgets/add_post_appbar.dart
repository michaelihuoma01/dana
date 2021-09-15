import 'package:dana/screens/home.dart';
import 'package:dana/screens/pages/camera_screen/camera_screen.dart';
import 'package:dana/screens/pages/notifications_screen.dart';
import 'package:dana/screens/pages/post_audience.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddPostAppbar extends StatelessWidget {
  final String? title, subtitle;
  Widget? icon;
  final bool? leading, isTab, isPost;
  Function? onTap;
  final Color? bgColor;

  var cameras, backToHomeScreenFromCameraScreen, cameraConsumer;

  AddPostAppbar(
      {this.title,
      this.subtitle,
      this.isPost,
      this.icon,
      this.isTab,
      this.bgColor,
      this.onTap,
      this.backToHomeScreenFromCameraScreen,
      this.cameraConsumer,
      this.cameras,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return isPost!
        ? AppBar(
            leading: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 15),
                  child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.white, size: 30)),
                ),
              ],
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraScreen(cameras,
                            backToHomeScreenFromCameraScreen, cameraConsumer)));
              },
              child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(FontAwesomeIcons.globeAsia,
                    //     size: 18, color: Colors.white),
                    // SizedBox(width: 10),
                    // Text(title,
                    //     style: TextStyle(
                    //         fontFamily: 'Poppins-Regular',
                    //         color: Colors.white,
                    //         fontSize: 18)),
                    // SizedBox(width: 10),
                    // Icon(Icons.arrow_drop_down, color: Colors.white),
                    Icon(Icons.camera_alt_outlined,
                        size: 25, color: Colors.white),
                    SizedBox(width: 10),
                    Text(title!,
                        style: TextStyle(
                            fontFamily: 'Poppins-Regular',
                            color: Colors.white,
                            fontSize: 18)),
                    SizedBox(width: 30),
                    // Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
           
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 17,   top: 15),
                  child: GestureDetector( 
                    onTap: onTap as void Function()?,
                     
                      child: Text(
                        'Post',
                        style: TextStyle(
                            fontSize: 17,
                            color: lightColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins-Regular'),
                       
                    ),
                  )),
            ],
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: darkColor,
            brightness: Brightness.dark,
            elevation: 5,
          )
        : AppBar(
            title: Text('Settings',
                style: TextStyle(fontSize: 22, color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: darkColor,
            brightness: Brightness.dark,
            elevation: 5,
          );
  }
}
