import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/user_model.dart';

class Chat {
  final String id, admin;
  final String groupName;
  final String recentMessage;
  final String recentSender;
  final Timestamp recentTimestamp;
  final List<dynamic> memberIds;
  final List<AppUser> memberInfo;
  final dynamic readStatus;

  Chat(
      {this.id,
      this.admin,
      this.recentMessage,
      this.recentSender,
      this.recentTimestamp,
      this.memberIds,
      this.memberInfo,
      this.readStatus,
      this.groupName});

  factory Chat.fromDoc(DocumentSnapshot doc) {
    return Chat(
      id: doc.id,
      admin: doc['admin'] ?? null,
      recentMessage: doc['recentMessage'],
      recentSender: doc['recentSender'],
      recentTimestamp: doc['recentTimestamp'],
      memberIds: doc['memberIds'],
      readStatus: doc['readStatus'],
      groupName: doc['groupName'] ?? null,
    );
  }
}
