import 'package:cloud_firestore/cloud_firestore.dart';

class UserPost {
  final String userId;
  final String message;
  final String? imageUrl;
  final String? videoUrl;
  final Timestamp timestamp;
  final Timestamp? editedTime;
  final List<String> likes;
  final bool isPublic;

  UserPost({
    required this.userId,
    required this.message,
    this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.editedTime,
    required this.likes,
    required this.isPublic,
  });

  factory UserPost.fromDocument(DocumentSnapshot doc) {
    return UserPost(
      userId: doc['UserId'],
      message: doc['Message'],
      imageUrl: doc['Image'],
      videoUrl: doc['Video'],
      timestamp: doc['TimeStamp'],
      editedTime: doc['EditedTime'],
      likes: List<String>.from(doc['Likes']),
      isPublic: doc['IsPublic'],
    );
  }
}