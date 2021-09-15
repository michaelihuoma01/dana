import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';

class AddStory extends StatelessWidget {
  Widget? icon;
  bool? isAdded, hasName;
  Color? color;

  AddStory({this.icon, this.color, this.hasName, this.isAdded});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 70,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  width: 2, color: isAdded! ? color! : Colors.transparent),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: icon,
              ),
            ),
          ),
          if (isAdded == false)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Container(
                    margin: EdgeInsets.only(left: 0),
                    decoration: BoxDecoration(
                        color: darkColor,
                        borderRadius: BorderRadius.all(Radius.circular(250))),
                    child: InkWell(
                        onTap: () {
                          print('tapped');
                        },
                        child: Icon(Icons.add_circle,
                            color: lightColor, size: 25)),
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          if (hasName == true)
            Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('Savanah',
                        style: TextStyle(color: Colors.white)))),
        ],
      ),
    );
  }
}
