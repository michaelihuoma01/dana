import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? id;
  final String? senderId;
  final String? text;
  final String? imageUrl;
  final String? giphyUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? fileUrl;
  final String? fileName;
  final Timestamp? timestamp;
  final bool? isLiked;

  Message(
      {this.id,
      this.senderId,
      this.text,
      this.imageUrl,
      this.timestamp,
      this.audioUrl,
      this.giphyUrl,
      this.fileUrl,
      this.videoUrl,
      this.fileName,
      this.isLiked});

  factory Message.fromDoc(DocumentSnapshot doc) {
    return Message(
      id: doc.id,
      senderId: doc['senderId'],
      text: doc['text'],
      imageUrl: doc['imageUrl'],
      audioUrl: doc['audioUrl'],
      videoUrl: doc['videoUrl'],
      fileUrl: doc['fileUrl'],
      fileName: doc['fileName'],
      timestamp: doc['timestamp'],
      isLiked: doc['isLiked'],
      giphyUrl: doc['giphyUrl'] ?? "",
    );
  }
}
