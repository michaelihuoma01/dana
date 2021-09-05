import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/contact_tile.dart';
import 'package:dana/widgets/story_appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: darkColor,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
          child: Row(children: [
            Expanded(
              child: Container(
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Reply',
                      fillColor: Colors.white,
                      hintStyle: TextStyle(color: Colors.grey)),
                  cursorColor: lightColor,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.send, color: Colors.white),
          ]),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            color: darkColor,
            child: GestureDetector(
              onVerticalDragDown: (details) {
                print(details);
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/images/me.jpeg',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: StoryAppbar(online: true),
          ))
        ],
      ),
    );
  }
}
