import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import 'package:social_app/New%20Post/video_player.dart';

import '../../Utility/utils.dart';
import 'post_service.dart';

class NewPostsBottom extends StatefulWidget {
  const NewPostsBottom({super.key});

  @override
  State<NewPostsBottom> createState() => _NewPostsBottomState();
}

class _NewPostsBottomState extends State<NewPostsBottom> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _imageFile;
  File? _videoFile;
  bool _isPublic = true;
  late PostService _postService;

  @override
  void initState() {
    super.initState();
    _postService = PostService(currentUser);
  }

  void _pickImage() async {
    final pickedImage = await Utils.pickImage();
    setState(() {
      _imageFile = pickedImage;
      _videoFile = null;
    });
  }

  void _pickVideo() async {
    final pickedVideo = await Utils.pickVideo();
    setState(() {
      _videoFile = pickedVideo;
      _imageFile = null;
    });
  }

  void _discardMedia() {
    setState(() {
      _imageFile = null;
      _videoFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text('New Post'),
        actions: [
          TextButton.icon(
            onPressed: postMessage,
            label: Text("Post",style: TextStyle(color: Colors.grey.shade900),),
            icon: Icon(Icons.publish_sharp,color: Colors.grey.shade900,),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(width: 1)),
          color: Colors.grey[900],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Write something to post...',
                      obscureText: false,
                      type: TextInputType.text,
                    ),
                  ),
                ),
                // Column(
                //   children: [
                //     const Text(
                //       'Public',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //     Switch(
                //       value: _isPublic,
                //       onChanged: (value) {
                //         setState(() {
                //           _isPublic = value;
                //         });
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
            const SizedBox(height: 10),
            _imageFile != null || _videoFile != null
                ? Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!)
                      : VideoPlayerWidget(videoFile: _videoFile!),
                ),
                TextButton.icon(
                  onPressed: _discardMedia,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    'Remove Media',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
                : Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    onPressed: _pickVideo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void postMessage() async {
    if (textController.text.isEmpty && _imageFile == null && _videoFile == null) {
      _postService.showErrorDialog(context, 'Error', 'Please write something, add an image, or add a video.');
      return;
    }

    try {
      _postService.showProgressDialog(context);
      print('ProgressDialog shown');

      String? imageUrl;
      String? videoUrl;

      if (_imageFile != null) {
        print('Uploading image...');
        imageUrl = await _postService.uploadFileToStorage(_imageFile!);
        print('Image uploaded: $imageUrl');
      }
      if (_videoFile != null) {
        print('Uploading video...');
        videoUrl = await _postService.uploadFileToStorage(_videoFile!);
        print('Video uploaded: $videoUrl');
      }

      if (!mounted) return;
      _postService.hideProgressDialog(context);
      print('ProgressDialog hidden');

      await _postService.postToFirestore(imageUrl, videoUrl, textController.text, _isPublic);
      print('Post submitted to Firestore');

      if (!mounted) return;
      setState(() {
        textController.clear();
        _imageFile = null;
        _videoFile = null;
        _isPublic = true;
      });
      print('State reset');
    } catch (e) {
      print('Error in postMessage: $e');
      if (mounted) {
        _postService.hideProgressDialog(context);
        print('ProgressDialog hidden after error');
        _postService.showErrorDialog(context, 'Error', 'An error occurred while uploading file. Please try again later.');
      }
    }
  }
}
