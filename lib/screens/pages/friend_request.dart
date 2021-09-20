import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/friend_request_tile.dart';
import 'package:flutter/material.dart';

class FriendRequest extends StatefulWidget {
  @override
  _FriendRequestState createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: double.infinity,
        color: darkColor,
        child: Image.asset(
          'assets/images/background.png',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: AppBarWidget(isTab: false, title: 'Friend Requests')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FriendRequestTile(),
                FriendRequestTile(),
                FriendRequestTile(),
                FriendRequestTile(),
                FriendRequestTile(),
                FriendRequestTile(),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
