import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

enum MessageTypes { info, error }

class Utility {
  BuildContext context;
  Utility.of(BuildContext _context) {
    this.context = _context;
  }
  static showMessage(
    BuildContext context, {
    String message,
    IconData iconData,
    Icon icon,
    MessageTypes type,
    Duration duration,
    bool pulsate,
    Color bgColor,
  }) {
    Flushbar(
      margin: EdgeInsets.all(10),
      backgroundColor: bgColor,
      borderRadius: BorderRadius.circular(10),
      icon: Icon(
        iconData ?? type == MessageTypes.error ? Icons.warning : Icons.done,
        color: Colors.white,
      ),
      shouldIconPulse: pulsate,
      message: message ??
          (type == MessageTypes.error ? 'An Error occurred.' : 'Loading...'),
      duration: duration ?? Duration(seconds: 2),
    )..show(context);
  }
}
