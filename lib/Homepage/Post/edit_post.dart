
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper_methods.dart';


class EditPostPage extends StatefulWidget {
  final String postId;

  const EditPostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _postTextController;
  final currentUser = FirebaseAuth.instance.currentUser!;
  String originalTime = '';
  String editedTime = '';


  @override
  void initState() {
    super.initState();
    _postTextController = TextEditingController();
    fetchPostContent();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  Future<void> fetchPostContent() async {
    try {
      final DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .get();

      if (postSnapshot.exists) {
        setState(() {
          _postTextController.text = postSnapshot['Message'];
          originalTime = formatDate(postSnapshot['TimeStamp']);
          editedTime = postSnapshot['EditedTime'] != null
              ? formatDateTime(postSnapshot['EditedTime'])
              : 'not edited yet'; // If edited time is null, assign an empty string
        });
      }
    } catch (error) {
      print('Error fetching post content: $error');
    }
  }

  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}/${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  Future<void> updatePost(String newPostText) async {
    try {
      await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .update({'Message': newPostText, 'EditedTime': Timestamp.now()});
      Navigator.pop(context);
    } catch (error) {
      print('Error updating post: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50,),
          Text(
            'Original Post Time: $originalTime',
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Edited Time: $editedTime',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _postTextController,
            maxLines: null,
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.edit),
              hintText: 'Enter your updated text...',
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.white),
              ),
            ),
          ),
          ElevatedButton(onPressed: (){
            final newPostText = _postTextController.text.trim();
            if (newPostText.isNotEmpty) {
              updatePost(newPostText);
            } else {
              // Show an error message if the post text is empty
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Post text cannot be empty.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }, child: Text('update'))
        ],
      ),
    );
  }
}