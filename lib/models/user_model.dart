import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String pin;
  final String profileImageUrl;
  final String email;
  final String bio;
  final String token;
  final String dob;
  final String gender;
  final bool isPublic;
  final bool isBanned;
  // final List<String> favoritePosts;
  // final List<String> blockedUsers;
  // final List<String> hideStoryFromUsers;
  // final List<String> closeFriends;
  // final bool allowStoryMessageReplies;
  final Timestamp lastSeenOffline;
  final Timestamp lastSeenOnline;
  final String status;

  final String role;
  final bool isVerified;
  final Timestamp timeCreated;

  AppUser(
      {this.id,
      this.pin,
      this.name,
      this.profileImageUrl,
      this.email,
      this.bio,
      this.token,
      this.isBanned,
      this.status,
      this.isVerified,
      this.role,
      this.dob,
      this.isPublic,
      this.gender,
      this.timeCreated,
      this.lastSeenOffline,
      this.lastSeenOnline});

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    return AppUser(
      id: doc.id ?? '',
      name: doc['name'] ?? '',
      profileImageUrl: doc['profileImageUrl'] ?? '',
      email: doc['email'],
      pin: doc['pin'] ?? '',
      bio: doc['bio'] ?? '',
      status: doc['status'] ?? '',
      token: doc['token'] ?? '',
      dob: doc['dob'] ?? '',
      gender: doc['gender'] ?? '',
      lastSeenOffline: doc['lastSeenOffline'] ?? null,
      lastSeenOnline: doc['lastSeenOnline'] ?? null,
      isVerified: doc['isVerified'] ?? false,
      isBanned: doc['isBanned'] ?? false,
      isPublic: doc['isPublic'] ?? false,
      role: doc['role'] ?? 'user',
      timeCreated: doc['timeCreated'] ?? null,
    );
  }
}
