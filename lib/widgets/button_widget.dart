import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final Function? onPressed;
  final Color? textColor, bgColor;
  bool? iconText = false;

  ButtonWidget(
      {this.title,
      this.onPressed,
      this.icon,
      this.iconText,
      this.textColor,
      this.bgColor});
  @override
  Widget build(BuildContext context) {
    return iconText!
        ? TextButton.icon(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10))),
                backgroundColor: MaterialStateProperty.all(bgColor),
                foregroundColor: MaterialStateProperty.all(textColor)),
            onPressed: onPressed as void Function()?,
            icon: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: icon,
            ),
            label: Container(
              height: 40,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                  child: Text(
                    title!,
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins-Regular'),
                  ),
                ),
              ),
            ),
          )
        : TextButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10))),
                backgroundColor: MaterialStateProperty.all(lightColor),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: onPressed as void Function()?,
            child: Container(
              height: 40,
              child: Center(
                child: Text(
                  title!,
                  style: TextStyle(fontSize: 16, fontFamily: 'Poppins-Regular'),
                ),
              ),
            ),
          );
  }
}
