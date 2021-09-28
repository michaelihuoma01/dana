import 'dart:convert';

import 'package:Dana/utils/constants.dart';
import 'package:http/http.dart' as http;

class HelperMethods {
  static sendNotification(
      String? token, context, String? userID, title, body) async {
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map notificationMap = {
      'title': title,
      'body': body,
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'userID': userID,
      'body': body
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token,
    };

    var response = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerMap,
      body: jsonEncode(bodyMap),
    );

    print(response.body);
  }
}
