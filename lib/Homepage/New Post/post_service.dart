import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PostService {
  final User currentUser;

  PostService(this.currentUser);

  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Uploading..."),
          ],
        ),
      ),
    );
  }

  void hideProgressDialog(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> postToFirestore(String? imageUrl, String? videoUrl, String message, bool isPublic) async {
    await FirebaseFirestore.instance.collection("UserPosts").add({
      'UserId': currentUser.uid,
      'Message': message,
      'Image': imageUrl,
      'Video': videoUrl,
      'TimeStamp': Timestamp.now(),
      'EditedTime': null,
      'Likes': [],
      'IsPublic': isPublic,
    });
  }

  Future<String> uploadFileToStorage(File file) async {
    try {
      final fileName = path.basename(file.path);
      final destination = 'users/${currentUser.email}/$fileName';
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ('Error uploading file to storage: $e');
    }
  }
}
