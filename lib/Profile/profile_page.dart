import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:social_app/Firebase/firebase_services.dart';
import 'package:social_app/Profile/post_grid.dart';
import 'package:social_app/Utility/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService firebaseService = FirebaseService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _fetchUserData() async {
    _userData = await firebaseService.getUserData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Crop the image before uploading
      final croppedFile = await _cropImage(File(pickedFile.path));

      if (croppedFile != null) {
        setState(() {
          _imageFile = croppedFile;
        });

        if(_imageFile != null){
          _uploadProfileImage();
        }
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 100, ratioY: 100),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
        IOSUiSettings(
          title: 'Crop Image',
        )
      ],
      compressQuality: 50,
      compressFormat: ImageCompressFormat.png
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null || currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${currentUser!.uid}.png');

      final uploadTask = await storageRef.putFile(_imageFile!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore with the new profile picture URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profile_picture': downloadUrl});

      // Fetch updated user data
      await _fetchUserData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Utils.displayMessage(context, "Error uploading profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _userData != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _isLoading
                        ? Center(child: Utils.circularProgressIndicator())
                        :  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _userData!['profile_picture'] != null
                          ? Image.network(
                        _userData!['profile_picture'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                          : const Icon(
                        Icons.person,
                        size: 75,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userData!['username'] ?? 'No Username',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        )),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Posts',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['posts'].length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text(
                              'Followers',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['followers'].length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text(
                              'Following',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['following'].length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _userData!['bio'].toString().isNotEmpty ? _userData!['bio'] : "no bio",
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                onPressed: () {
                  // Implement edit profile functionality
                },
                child: const Text(
                  'EDIT PROFILE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _userData!['posts'].length == 0
                ? const Center(child: Text("No posts found for current user."))
                : SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ImageGrid(userId: currentUser!.uid),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Utils.circularProgressIndicator(),
      ),
    );
  }
}
