import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/broadcast_message.dart';
import 'package:Dana/screens/pages/create_group.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:Dana/screens/tabs/contacts_screen.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/confirm_delete_dialog.dart';
import 'package:Dana/widgets/slide_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesScreen extends StatefulWidget {
  AppUser? currentUser;
  bool? isReadIcon = false;
  final SearchFrom searchFrom;
  final File? imageFile;
  MessagesScreen(
      {required this.searchFrom,
      this.isReadIcon,
      this.currentUser,
      this.imageFile});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Stream<List<Chat>>? chatsStream;
  AppUser? _currentUser;
  // List<AppUser> users;
  String? deleteUserID, userName;
  List<Chat> dataToReturn = [];

  @override
  void initState() {
    super.initState();
    final AppUser currentUser =
        Provider.of<UserData>(context, listen: false).currentUser!;
    setState(() => _currentUser = currentUser);
    AuthService.updateTokenWithUser(currentUser);
  }

  Stream<List<Chat>> getChats() async* {
    // try {

    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('chats')
        .where('memberIds', arrayContains: _currentUser!.id)
        // .orderBy('recentTimestamp', descending: true)
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

        AppUser? receiverUser =
            await DatabaseService.getUserWithId(memberIds[receiverIndex]);

        if (memberIds.length > 2) {
          for (String? userId in memberIds as Iterable<String?>) {
            AppUser user = await DatabaseService.getUserWithId(userId);
            membersInfo.add(user);
          }
        } else {
          membersInfo.add(_currentUser);
          membersInfo.add(receiverUser);
        }

        Chat chatWithUserInfo = Chat(
            id: chatFromDoc.id,
            memberIds: chatFromDoc.memberIds,
            memberInfo: membersInfo,
            readStatus: chatFromDoc.readStatus,
            recentMessage: chatFromDoc.recentMessage,
            recentSender: chatFromDoc.recentSender,
            recentTimestamp: chatFromDoc.recentTimestamp,
            admin: chatFromDoc.admin,
            groupName: chatFromDoc.groupName);

        dataToReturn.removeWhere((chat) => chat.id == chatWithUserInfo.id);

        dataToReturn.add(chatWithUserInfo);
      }
      dataToReturn
          .sort((a, b) => b.recentTimestamp!.compareTo(a.recentTimestamp!));

      yield dataToReturn;
    }
    // } catch (err) {
    //   print('////$err');
    // }
  }

  deleteChats(String receiverID) {
    try {
      var stream = FirebaseFirestore.instance
          .collection('chats')
          .where('recentSender', isEqualTo: _currentUser!.id)
          .snapshots()
          .forEach((docs) {
        for (QueryDocumentSnapshot snapshot in docs.docs) {
          setState(() {
            snapshot.reference
                .collection('messages')
                .snapshots()
                .forEach((element) {
              for (QueryDocumentSnapshot snap in element.docs) {
                snap.reference.delete();
              }
            });
            snapshot.reference.delete();
          });
        }
      });
    } catch (err) {
      print('////$err');
    }
  }

  _buildChat(Chat chat, String? currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];
    widget.isReadIcon = isRead;
    final TextStyle readStyle = TextStyle(
        color: isRead ? Colors.white : lightColor,
        fontSize: 12,
        fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    // users = chat.memberInfo;
    int receiverIndex =
        chat.memberInfo!.indexWhere((user) => user!.id != _currentUser!.id);
    int senderIndex =
        chat.memberInfo!.indexWhere((user) => user!.id == chat.recentSender);

    userName = chat.memberInfo![receiverIndex]!.name;

    if (widget.searchFrom == SearchFrom.createStoryScreen) {
      return ListTile(
        leading: Container(
          height: 40,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            backgroundImage:
                (chat.memberInfo![receiverIndex]!.profileImageUrl!.isEmpty
                        ? AssetImage(placeHolderImageRef)
                        : CachedNetworkImageProvider(
                            chat.memberInfo![receiverIndex]!.profileImageUrl!))
                    as ImageProvider<Object>?,
          ),
        ),
        title: Text(chat.memberInfo![receiverIndex]!.name!,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
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
                        receiverUser: chat.memberInfo![receiverIndex],
                        imageFile: widget.imageFile))),
          },
        ),
        // onTap: () =>
      );
    }
    return ListTile(
        leading: Container(
          height: 40,
          child: (chat.memberIds!.length > 2)
              ? Icon(Icons.group, color: Colors.white, size: 35)
              : CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 28.0,
                  backgroundImage:
                      (chat.memberInfo![receiverIndex]!.profileImageUrl!.isEmpty
                          ? AssetImage(placeHolderImageRef)
                          : CachedNetworkImageProvider(chat
                              .memberInfo![receiverIndex]!
                              .profileImageUrl!)) as ImageProvider<Object>?,
                ),
        ),
        title: Text(
            (chat.memberIds!.length > 2)
                ? chat.groupName!
                : chat.memberInfo![receiverIndex]!.name!,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        subtitle: chat.recentSender!.isEmpty
            ? Text(
                (chat.memberIds!.length > 2)
                    ? S.of(context)!.youadd
                    : S.of(context)!.chatcreated,
                overflow: TextOverflow.ellipsis,
                style: readStyle,
              )
            : chat.recentMessage != null
                ? Text(
                    '${chat.recentMessage}',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  )
                : Text(
                    S.of(context)!.attach,
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  ),
        trailing: Text(
          timeago.format(chat.recentTimestamp!.toDate()),
          // timeFormat.format(
          //   chat.recentTimestamp.toDate(),
          // ),
          style: readStyle,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                      receiverUser: chat.memberInfo![receiverIndex],
                      userIds: chat.memberIds,
                      groupMembers: chat.memberInfo,
                      admin: chat.admin,
                      chat: chat,
                      isGroup: (chat.memberIds!.length > 2) ? true : false,
                      groupName: chat.groupName)));
        });
  }

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
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              actions: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CreateGroup(
                                    currentUser: _currentUser,
                                    searchFrom: widget.searchFrom,
                                  )));
                    },
                    child: Icon(Icons.group_add, color: lightColor, size: 30)),
                SizedBox(width: 15)
              ],
              title: Text(S.of(context)!.messages,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              brightness: Brightness.dark,
            )),
        body: StreamBuilder(
            stream: getChats(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SpinKitWanderingCubes(color: Colors.white, size: 40),
                );
              }
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ContactScreen(
                                    searchFrom: SearchFrom.messagesScreen,
                                    imageFile: widget.imageFile,
                                    currentUser: _currentUser,
                                  ))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text(S.of(context)!.search,
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        Chat chat = snapshot.data[index];

                        return Dismissible(
                            key: UniqueKey(),
                            confirmDismiss: (direction) async {
                              return showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Container(
                                        height: 60,
                                        decoration:
                                            BoxDecoration(color: darkColor),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.of(context).pop();

                                                await chatsRef
                                                    .doc(chat.id)
                                                    .collection('messages')
                                                    .get()
                                                    .then((docs) {
                                                  docs.docs.forEach((element) {
                                                    element.reference
                                                        .delete()
                                                        .then((value) {
                                                      chatsRef
                                                          .doc(chat.id)
                                                          .delete()
                                                          .then((value) {
                                                        print(
                                                            '======= it is succesful');
                                                        setState(() {
                                                          dataToReturn
                                                              .removeAt(index);
                                                        });
                                                      });
                                                    });
                                                  });
                                                });

                                                setState(() {});
                                              },
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .w600))),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(
                                color: Colors.redAccent,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(Icons.delete,
                                          color: Colors.white),
                                    ))),
                            child: _buildChat(chat, _currentUser!.id));
                      },
                      itemCount: snapshot.data.length,
                    )),
                  ],
                ),
              );
            }),
        floatingActionButton: new FloatingActionButton(
          backgroundColor: lightColor,
          mini: true,
          child: const Icon(Icons.record_voice_over),
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BroadcastMessage(
                          currentUser: _currentUser,
                          searchFrom: widget.searchFrom,
                        )));
          },
          elevation: 5,
          isExtended: true,
        ),
      )
    ]);
  }
}
