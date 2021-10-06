import 'package:Dana/notifications/helperMethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/models/chat_model.dart';
import 'package:Dana/models/message_model.dart';
import 'package:Dana/models/post_model.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChatService {
  static Future<Chat> createChat(
      List<AppUser?> users, List<dynamic>? userIds, context) async {
    Map<String?, dynamic> readStatus = {};

    for (AppUser? user in users) {
      readStatus[user!.id] = false;
    }

    Timestamp timestamp = Timestamp.now();

    DocumentReference res = await chatsRef.add({
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'admin': '',
      'groupName': '',
      'recentTimestamp': timestamp,
      'memberIds': userIds,
      'readStatus': readStatus,
    });

    return Chat(
      id: res.id,
      admin: '',
      groupName: '',
      recentMessage: 'Chat Created',
      recentSender: '',
      recentTimestamp: timestamp,
      memberIds: userIds,
      readStatus: readStatus,
      memberInfo: users,
    );
  }

  static void sendChatMessage(
      Chat chat, Message message, AppUser receiverUser, context) async {
    chatsRef.doc(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'audioUrl': message.audioUrl,
      'videoUrl': message.videoUrl,
      'fileUrl': message.fileUrl,
      'fileName': message.fileName,
      'timestamp': message.timestamp,
      'isLiked': message.isLiked ?? false,
      'giphyUrl': message.giphyUrl,
    });

    chatsRef.doc(chat.id).update({
      'recentMessage': message.text,
      'recentSender': message.senderId,
      'recentTimestamp': message.timestamp,
    });

    Post post = Post(
      authorId: receiverUser.id,
    );

    DatabaseService.addActivityItem(
      comment: message.text,
      currentUserId: message.senderId,
      isCommentEvent: false,
      isFollowEvent: false,
      isLikeEvent: false,
      isMessageEvent: true,
      post: post,
      recieverToken: receiverUser.token,
    );
    AppUser user = await DatabaseService.getUserWithId(message.senderId);
    HelperMethods.sendNotification(receiverUser.token, context, receiverUser.id,
        '${user.name} sent you a message');
  }

  static void setChatRead(BuildContext context, Chat chat, bool read) async {
    String? currentUserId =
        Provider.of<UserData>(context, listen: false).currentUser!.id;
    chatsRef.doc(chat.id).update({'readStatus.$currentUserId': read});
  }

  // static Future<bool> checkIfChatExist(List<String> users) async {
  //   print(users);
  //   QuerySnapshot snapshot = await chatsRef
  //       .where('memberIds', arrayContainsAny: users)
  //       .get();

  //   return snapshot.docs.isNotEmpty;
  // }

  static Future<Chat> getChatById(String chatId) async {
    DocumentSnapshot chatDocSnapshot = await chatsRef.doc(chatId).get();
    if (chatDocSnapshot.exists) {
      return Chat.fromDoc(chatDocSnapshot);
    }
    return Chat();
  }

  static Future<Chat?> getChatByUsers(List<dynamic> users) async {
    QuerySnapshot snapshot = await chatsRef.where('memberIds', whereIn: [
      [users[1], users[0]]
    ]).get();

    if (snapshot.docs.isEmpty) {
      snapshot = await chatsRef.where('memberIds', whereIn: [
        [users[0], users[1]]
      ]).get();
    }

    if (snapshot.docs.isNotEmpty) {
      return Chat.fromDoc(snapshot.docs[0]);
    }
    return null;
  }

  static Future<Null>? likeUnlikeMessage(Message message, String? chatId,
      bool isLiked, AppUser receiverUser, String? currentUserId) {
    chatsRef
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .update({'isLiked': isLiked});

    Post post = Post(
      authorId: receiverUser.id,
    );

    if (isLiked == true) {
      DatabaseService.addActivityItem(
        comment: message.text ?? null,
        currentUserId: currentUserId,
        isCommentEvent: false,
        isFollowEvent: false,
        isLikeEvent: false,
        isMessageEvent: false,
        isLikeMessageEvent: true,
        post: post,
        recieverToken: receiverUser.token,
      );
    } else {
      DatabaseService.deleteActivityItem(
        comment: message.text ?? null,
        currentUserId: currentUserId,
        isFollowEvent: false,
        post: post,
        isCommentEvent: false,
        isLikeEvent: false,
        isLikeMessageEvent: true,
        isMessageEvent: false,
      );
    }
    return null;
  }
}
