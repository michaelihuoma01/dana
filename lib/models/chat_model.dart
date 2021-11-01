import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/models/user_model.dart';

class Chat {
  final String? id, admin;
  final String? groupName, groupUrl;
  final String? recentMessage;
  final String? recentSender;
  final Timestamp? recentTimestamp;
  final List<dynamic>? memberIds;
  final List<AppUser?>? memberInfo;
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
      this.groupUrl,
      this.groupName});

  factory Chat.fromDoc(DocumentSnapshot doc) {
    return Chat(
      id: doc.id,
      admin: doc['admin'] ?? '',
      recentMessage: doc['recentMessage'],
      recentSender: doc['recentSender'],
      recentTimestamp: doc['recentTimestamp'],
      memberIds: doc['memberIds'],
      readStatus: doc['readStatus'],
      groupName: doc['groupName'] ?? 'null',
      groupUrl: doc['groupUrl'] ?? '',
    );
  }
}
