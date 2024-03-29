import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:Dana/screens/tabs/contacts_screen.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class DirectMessagesWidget extends StatefulWidget {
  final SearchFrom searchFrom;
  final File? imageFile;
  DirectMessagesWidget({required this.searchFrom, this.imageFile});
  @override
  _DirectMessagesWidgetState createState() => _DirectMessagesWidgetState();
}

class _DirectMessagesWidgetState extends State<DirectMessagesWidget> {
  Stream<List<Chat>>? chatsStream;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    final AppUser currentUser =
        Provider.of<UserData>(context, listen: false).currentUser!;
    setState(() => _currentUser = currentUser);
    AuthService.updateTokenWithUser(currentUser);
  }

  Stream<List<Chat>> getChats() async* {
    List<Chat> dataToReturn =[];

    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('chats')
        .where('memberIds', arrayContains: _currentUser!.id)
        .orderBy('recentTimestamp', descending: true)
        .snapshots();

    await for (QuerySnapshot q in stream) {
      for (var doc in q.docs) {
        Chat chatFromDoc = Chat.fromDoc(doc);
        List<dynamic> memberIds = chatFromDoc.memberIds!;
        late int receiverIndex;

        // Getting receiver index
        memberIds.forEach((userId) {
          if (userId != _currentUser!.id) {
            receiverIndex = memberIds.indexOf(userId);
          }
        });

        List<AppUser?> membersInfo = [];

        AppUser receiverUser =
            await DatabaseService.getUserWithId(memberIds[receiverIndex]);
        membersInfo.add(_currentUser);
        membersInfo.add(receiverUser);

        Chat chatWithUserInfo = Chat(
          id: chatFromDoc.id,
          memberIds: chatFromDoc.memberIds,
          memberInfo: membersInfo,
          readStatus: chatFromDoc.readStatus,
          recentMessage: chatFromDoc.recentMessage,
          recentSender: chatFromDoc.recentSender,
          recentTimestamp: chatFromDoc.recentTimestamp,
        );

        dataToReturn.removeWhere((chat) => chat.id == chatWithUserInfo.id);

        dataToReturn.add(chatWithUserInfo);
      }
      yield dataToReturn;
    }
  }

  _buildChat(Chat chat, String? currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];
    final TextStyle readStyle =
        TextStyle(fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    List<AppUser?> users = chat.memberInfo!;
    int receiverIndex = users.indexWhere((user) => user!.id != _currentUser!.id);
    int senderIndex = users.indexWhere((user) => user!.id == chat.recentSender);

    if (widget.searchFrom == SearchFrom.createStoryScreen) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          backgroundImage: (users[receiverIndex]!.profileImageUrl!.isEmpty
              ? AssetImage(placeHolderImageRef)
              : CachedNetworkImageProvider(
                  users[receiverIndex]!.profileImageUrl!)) as ImageProvider<Object>?,
        ),
        title: Row(
          children: [
            Text(
              users[receiverIndex]!.name!,
            ),
            // UserBadges(user: users[receiverIndex], size: 15),
          ],
        ),
        trailing: FlatButton(
          child: Text(
            'Send',
            style: kFontSize18TextStyle.copyWith(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  receiverUser: users[receiverIndex],
                  imageFile: widget.imageFile,
                ),
              ),
            ),
          },
        ),
        // onTap: () =>
      );
    }
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 28.0,
        backgroundImage: (users[receiverIndex]!.profileImageUrl!.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(users[receiverIndex]!.profileImageUrl!)) as ImageProvider<Object>?,
      ),
      title: Row(
        children: [
          Text(
            users[receiverIndex]!.name!,
          ),
          // UserBadges(user: users[receiverIndex], size: 15),
        ],
      ),
      subtitle: Container(
        height: 35,
        child: chat.recentSender!.isEmpty
            ? Text(
                'Chat Created',
                overflow: TextOverflow.ellipsis,
                style: readStyle,
              )
            : chat.recentMessage != null
                ?
                // Text(
                //     '${chat.memberInfo[senderIndex].name} : ${chat.recentMessage}',
                //     overflow: TextOverflow.ellipsis,
                //     style: readStyle,
                //   )
                Text(
                    '${chat.recentMessage}',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  )
                : Text(
                    // '${chat.memberInfo[senderIndex].name} : \nSent an attachment',
                    'Attachment',

                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  ),
      ),
      trailing: Text(
        timeago.format(chat.recentTimestamp!.toDate()),
        // timeFormat.format(
        //   chat.recentTimestamp.toDate(),
        // ),
        style: readStyle,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            receiverUser: users[receiverIndex],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getChats(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: lightColor
            ),
          );
        }
        return Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ContactScreen(
                            searchFrom: widget.searchFrom,
                            imageFile: widget.imageFile,
                          ))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 5),
                      Text('Search'),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Text(
                    'Messages',
                    style: kFontSize18TextStyle,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  Chat chat = snapshot.data[index];
                  return _buildChat(chat, _currentUser!.id);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(thickness: 1.0);
                },
                itemCount: snapshot.data.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
