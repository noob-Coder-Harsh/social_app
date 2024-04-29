import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:social_app/Homepage/New%20Post/video_player.dart';
import 'package:social_app/Login/widgets/text_feild.dart';


class NewPostsBottom extends StatefulWidget{
  const NewPostsBottom({super.key});

  @override
  State<NewPostsBottom> createState() => _NewPostsBottomState();
}

class _NewPostsBottomState extends State<NewPostsBottom> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _imageFile;
  File? _videoFile;
  bool _isPublic = true; // Add this line to represent the privacy status


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(width: 1)),
        color: Colors.grey[900],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyTextField(
                      controller: textController,
                      hintText: 'write something to post',
                      obscureText: false,
                      type: TextInputType.text,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    postMessage();
                  },
                  icon: Icon(
                    Icons.arrow_circle_up,
                    color: Colors.grey.shade300,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            _imageFile != null
                ? Image.file(_imageFile!)
                : _videoFile != null
                ? VideoPlayerWidget(videoFile: _videoFile!)
                : Container(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: const Text('Add Image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    pickVideo();
                  },
                  child: const Text('Add Video'),
                ),
                Column(
                  children: [
                    const Text('Public',style: TextStyle(color: Colors.white),),
                    Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

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
