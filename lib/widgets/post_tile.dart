import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset('assets/images/me.jpeg'),
              ),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Katherine changed her profile picture',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('7 hours ago', style: TextStyle(color: Colors.grey)),
            ]),
          ),
        ]),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/me.jpeg'),
            ),
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 10),
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(width: 10),
            Icon(Icons.reply_outlined, color: Colors.white),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset('assets/images/me.jpeg'),
                ),
              ),
            ),
            SizedBox(width: 5),
            Text('Liked by Katrina and 105 others',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(height: 7),
        Text('View 67 comments', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 5),
        Row(
          children: [
            Text('Melinda',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins-Bold')),
            SizedBox(width: 10),
            Text('Wow 😍', style: TextStyle(color: Colors.white)),
          ],
        ),
         SizedBox(height: 5),
        Row(
          children: [
            Text('Johnny',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins-Bold')),
            SizedBox(width: 10),
            Text('Nice 💪🏼', style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(height: 20),
        BrandDivider(),
        SizedBox(height: 20),
      ],
    );
  }
}
