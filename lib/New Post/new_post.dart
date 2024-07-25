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
  bool _isPublic = true; // Add this line to represent the privacy status
  late PostService _postService;

  @override
  void initState() {
    super.initState();
    _postService = PostService(currentUser);
  }

  @override
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
                ? Container(
                    constraints: const BoxConstraints(
                      maxHeight: 500, // Adjust as needed
                    ),
                    child: Image.file(_imageFile!),
                  )
                : _videoFile != null
                    ? Container(
                        constraints: const BoxConstraints(
                          maxHeight: 500, // Adjust as needed
                        ),
                        child: VideoPlayerWidget(videoFile: _videoFile!),
                      )
                    : Container(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _imageFile = await Utils.pickImage();
                    setState(() {
                      _videoFile = null; // Clear video if an image is picked.
                    });
                  },
                  child: const Text('Add Image'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _videoFile = await Utils.pickVideo();
                    setState(() {
                      _imageFile = null; // Clear image if a video is picked.
                    });
                  },
                  child: const Text('Add Video'),
                ),
                Column(
                  children: [
                    const Text(
                      'Public',
                      style: TextStyle(color: Colors.white),
                    ),
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
      _postService.showErrorDialog(context, 'Error', 'Please write something, add an image, or add a video.');
      return;
    }

    try {
      _postService.showProgressDialog(context);

      String? imageUrl;
      String? videoUrl;

      if (_imageFile != null) {
        imageUrl = await _postService.uploadFileToStorage(_imageFile!);
      }
      if (_videoFile != null) {
        videoUrl = await _postService.uploadFileToStorage(_videoFile!);
      }

      if (!mounted) return;
      _postService.hideProgressDialog(context);

      await _postService.postToFirestore(imageUrl, videoUrl, textController.text, _isPublic);

      if (!mounted) return;
      setState(() {
        textController.clear();
        _imageFile = null;
        _videoFile = null;
        _isPublic = true;
      });
    } catch (e) {
      if (mounted) {
        _postService.hideProgressDialog(context);
        _postService.showErrorDialog(context, 'Error', 'An error occurred while uploading file. Please try again later.');
      }
    }
  }
}
