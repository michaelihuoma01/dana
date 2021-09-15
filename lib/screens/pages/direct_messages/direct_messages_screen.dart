import 'package:dana/screens/pages/direct_messages/widgets/direct_messages_widget.dart';
import 'package:dana/utilities/constants.dart';
import 'package:flutter/material.dart'; 
class DirectMessagesScreen extends StatefulWidget {
  final Function backToHomeScreen;
  DirectMessagesScreen(this.backToHomeScreen);
  @override
  _DirectMessagesScreenState createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.backToHomeScreen as void Function()?,
        ),
        title: Text('Direct'),
      ),
      body: DirectMessagesWidget(
        searchFrom: SearchFrom.messagesScreen,
      ),
    );
  }
}
