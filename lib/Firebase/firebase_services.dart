import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Homepage/refactored/post_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;


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

  Future<List<UserPost>> fetchUserPosts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('UserPosts')
        .orderBy('TimeStamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => UserPost.fromDocument(doc)).toList();
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

  Future<void> updatePostLikes(String postId, bool isLiked) async {
    try {
      DocumentReference postRef =
      FirebaseFirestore.instance.collection('UserPosts').doc(postId);

      if (isLiked) {
        await postRef.update({
          'Likes': FieldValue.arrayUnion([currentUser!.uid])
        });
      } else {
        await postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser!.uid])
        });
      }
    } catch (e) {
      print(e);
      // Handle the error appropriately in your app
    }
  }

  Future<List<Map<String, dynamic>>> getPostLikes(String postId) async {
    try {
      DocumentReference postRef =
      FirebaseFirestore.instance.collection('UserPosts').doc(postId);
      DocumentSnapshot postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        Map<String, dynamic> data = postSnapshot.data() as Map<String, dynamic>;
        List<dynamic> likes = data['Likes'] ?? [];
        return likes.map((like) => {'uid': like}).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> addComment(String postId, String commentText, String username) async {
    if (commentText.isNotEmpty) {
      await _firestore.collection("UserPosts")
          .doc(postId)
          .collection("Comments")
          .add({
        "CommentText": commentText,
        "CommentedBy": username,
        "CommentTime": FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore.collection("UserPosts")
        .doc(postId)
        .collection("Comments")
        .orderBy("CommentTime", descending: true)
        .snapshots();
  }

  Future<int> getCommentCount(String postId) async {
    final snapshot = await _firestore.collection("UserPosts")
        .doc(postId)
        .collection("Comments")
        .get();
    return snapshot.docs.length;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

}
