import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/add_post_appbar.dart';
import 'package:flutter/material.dart';

class PostAudience extends StatefulWidget {
  @override
  PostAudienceState createState() => PostAudienceState();
}

class PostAudienceState extends State<PostAudience> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child:
              AddPostAppbar(isTab: false, title: 'Mokolosos', isPost: false)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Who can see your post?',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Public',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text('Anyone on Dana',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  Icon(Icons.circle_outlined, color: Colors.white)
                ],
              ),
              SizedBox(height: 10),
              BrandDivider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Friends',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text('Only your friends on Dana',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  Icon(Icons.circle_outlined, color: Colors.white)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
