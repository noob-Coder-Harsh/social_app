import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model.dart';

class PostsService {
  final User currentUser;

  PostsService(this.currentUser);

  Future<List<UserPost>> fetchUserPosts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('UserPosts')
        .orderBy('TimeStamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => UserPost.fromDocument(doc)).toList();
  }
}