import 'dart:async';

import 'package:flutter/material.dart';

class TimerView extends StatefulWidget {
  final Function updateTimerStatus;
  bool start = false;

  TimerView({
    Key key,
    this.start,
    this.updateTimerStatus,
  }) : super(key: key);

  @override
  TimerViewState createState() => TimerViewState();
}

class TimerViewState extends State<TimerView> {
  Timer _timer;
  int _counter = 0 * 60;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    if (widget.start == true) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _counter++;
        });
      });
    }
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  String getFormatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds ";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return _getResendVerificationButton();
  }

  Widget _getResendVerificationButton() =>
      Text('${getFormatDuration(Duration(seconds: _counter))}',
          style: TextStyle(fontSize: 18, color: Colors.white));
}
