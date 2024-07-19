import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Users').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Fetch a single user by user_id
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Fetch all posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Posts').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Fetch posts by user_id
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('UserPosts').where('user_id', isEqualTo: userId).get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['post_id'] = doc.id;  // Adding post ID to the map
        return data;
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Fetch a single post by post_id
  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Posts').doc(postId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Fetch comments for a specific post
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Posts').doc(postId).collection('Comments').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Fetch a single comment by comment_id
  Future<Map<String, dynamic>?> getComment(String postId, String commentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Posts').doc(postId).collection('Comments').doc(commentId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
