import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;


class NewPostsUI extends StatefulWidget {
  const NewPostsUI({super.key});

  @override
  State<NewPostsUI> createState() => _NewPostsUIState();
}

class _NewPostsUIState extends State<NewPostsUI> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _imageFile;
  File? _videoFile;
  bool _isPublic = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },icon: Icon(Icons.arrow_back),),
        title: const Text('Add New Post'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                      color: Colors.grey.shade700, offset: Offset(0,5),
                      blurRadius: 10
                  )]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: textController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'write something to post',
                          labelStyle: TextStyle(color: Colors.grey.shade500)
                        // hintText: 'write something to post'
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(onPressed: (){postMessage();}, icon: Icon(Icons.publish_sharp))
                ],
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {pickImage();},
                  child: Text(
                    'pick image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {pickVideo();},
                  child: const Text(
                    'upload video',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {postMessage();},
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void postMessage() async {
    if (textController.text.isEmpty && _imageFile == null && _videoFile == null) {
      // Show error dialog if no message, image, or video is provided
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please write something, add an image, or add a video.'),
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
      return; // Stop further processing.
    }

    try {
      String? imageUrl;
      String? videoUrl;

      // Show progress dialog while uploading media
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
        builder: (context) => AlertDialog(
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

      if (_imageFile != null) {
        imageUrl = await uploadFileToStorage(_imageFile!, currentUser.email!);
      }
      if (_videoFile != null) {
        videoUrl = await uploadFileToStorage(_videoFile!, currentUser.email!);
      }
      Navigator.pop(context); // Dismiss the progress dialog

      await FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'Image': imageUrl,
        'Video': videoUrl,
        'TimeStamp': Timestamp.now(),
        'EditedTime' : null,
        'Likes': [],
        'IsPublic': _isPublic, // Save the privacy status
      });
      setState(() {
        textController.clear();
        _imageFile = null;
        _videoFile = null;
        _isPublic = true;
      });

    } catch (e) {
      print('Error uploading file: $e');
      // Handle error while uploading files
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while uploading file. Please try again later.'),
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
  }

  Future<String> uploadFileToStorage(File file, String userEmail) async {
    try {
      final fileName = path.basename(file.path);
      final destination = 'users/$userEmail/$fileName';
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file to storage: $e');
      throw e; // Rethrow the error to handle it in the calling function
    }
  }

  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _videoFile = null; // Clear video if an image is picked.
      });
    }else {
      setState(() {
        _imageFile = null; // Clear image if no image is picked.
      });
    }
  }

  void pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _imageFile = null; // Clear image if a video is picked.
      });
    }
  }

}