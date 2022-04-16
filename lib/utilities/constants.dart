import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = _firestore.collection('users');
final callsRef = _firestore.collection('calls');
final postsRef = _firestore.collection('posts');
final publicPostsRef = _firestore.collection('publicPosts');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final feedsRef = _firestore.collection('feeds');
final likesRef = _firestore.collection('likes');
final commentsRef = _firestore.collection('comments');
final activitiesRef = _firestore.collection('activities');
final archivedPostsRef = _firestore.collection('archivedPosts');
final deletedPostsRef = _firestore.collection('deletedPosts');
final chatsRef = _firestore.collection('chats');
final storiesRef = _firestore.collection('stories');
final String user = 'userFeed';
final String usersFollowers = 'userFollowers';
final String userFollowing = 'userFollowing';
final String placeHolderImageRef = 'assets/images/user_placeholder.jpg';
bool isRead = true;
bool isHomeRequest = false;

final DateFormat timeFormat = DateFormat('E, h:mm a');

enum PostStatus {
  feedPost,
  deletedPost,
  archivedPost,
}

enum SearchFrom {
  messagesScreen,
  homeScreen,
  createStoryScreen,
}

enum CameraConsumer {
  post,
  story,
}
