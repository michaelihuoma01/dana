import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/utils/utility.dart';

class Post {
  final String? id;
  final String? imageUrl, videoUrl;
  final String? caption;
  final int? likeCount;
  final int? commentCount;
  final String? authorId;
  final String? location;
  final Timestamp? timestamp;
  final bool? commentsAllowed;

  Post(
      {this.id,
      this.imageUrl,
      this.caption,
      this.likeCount,
      this.videoUrl,
      this.authorId,
      this.commentCount,
      this.location,
      this.timestamp,
      this.commentsAllowed});

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      imageUrl: doc['imageUrl'],
      videoUrl: doc['videoUrl'],
      caption: doc['caption'],
      likeCount: doc['likeCount'],
      commentCount: doc['commentCount'],
      authorId: doc['authorId'],
      location: doc['location'] ?? "",
      timestamp: doc['timestamp'],
      commentsAllowed: doc['commentsAllowed'] ?? true,
    );
  }
}
