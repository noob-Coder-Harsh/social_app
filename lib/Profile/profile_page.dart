import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/Profile/textbox.dart';

import '../Homepage/Post/feed_post.dart';
import '../Homepage/helper_methods.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollections = FirebaseFirestore.instance.collection("Users");
  File? _imageFile;
  bool _isLoading = false;

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(newValue);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue.isNotEmpty) {
      await userCollections.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final profilePicturePath = userData['profile_img'] as String?;
                    return ListView(
                      children: [
                        const SizedBox(height: 50,),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: _imageFile != null
                              ? CircleAvatar(
                            radius: 36,
                            backgroundImage: FileImage(File(profilePicturePath!)),
                          )
                              : IconButton(
                            icon: Icon(Icons.person, size: 72),
                            onPressed: () {
                              _pickImage();
                            },
                          ),
                        ),
                        Text(
                          currentUser.email.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 50,),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(
                            'My Profile',
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                        MyTextBox(
                          text: userData['username'],
                          sectionName: 'username',
                          onPressed: () {
                            editField('username');
                          },
                        ),
                        MyTextBox(
                          text: userData['bio'],
                          sectionName: 'bio',
                          onPressed: () {
                            editField('bio');
                          },
                        ),
                        const SizedBox(height: 10,),
                        MyTextBox(
                          text: userData['contact'].toString(),
                          sectionName: 'contact',
                          onPressed: () {
                            editField('contact');
                          },
                        ),
                        const SizedBox(height: 10,),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()),);
                  }
                  return const Center(child: CircularProgressIndicator(),);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                'My Posts',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
              child: RefreshIndicator(
                onRefresh: _refreshHomePage,
                child:
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where("UserEmail", isEqualTo: currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final userPosts = snapshot.data!.docs;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Adjust the number of columns as needed
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return GestureDetector(
                            onTap: () {
                              // Handle tap on post
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: Image.network(
                                post['Image'], // Assuming 'Image' is the field name for the image URL
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),


                // StreamBuilder(
                //   stream: FirebaseFirestore.instance
                //       .collection("User Posts")
                //       .orderBy("TimeStamp", descending: true)
                //       .snapshots(),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasData) {
                //       return ListView.builder(
                //         itemCount: snapshot.data!.docs.length,
                //         itemBuilder: (context, index) {
                //           final post = snapshot.data!.docs[index];
                //           String timeText = post['EditedTime'] != null ? 'edited' : '';
                //           String formattedTime = post['EditedTime'] != null
                //               ? formatDate(post['EditedTime'])
                //               : formatDate(post['TimeStamp']);
                //           return FutureBuilder<Map<String, dynamic>>(
                //             future: getUserData(post["UserEmail"]), // Fetch username asynchronously
                //             builder: (context, userDataSnapshot) {
                //               if (userDataSnapshot.hasData) {
                //                 // final username = usernameSnapshot.data!;
                //                 final userData = userDataSnapshot.data!;
                //                 final username = userData["username"]; // Assuming "username" is a key in your user data
                //                 final profileImage = userData["profile_img"]; // Assuming "profile_img" is a key for profile image URL
                //                 return FeedPost(
                //                   user: username,
                //                   post: post["Message"],
                //                   postId: post.id,
                //                   likes: List<String>.from(post['Likes'] ?? []),
                //                   time: '$formattedTime   $timeText',
                //                   image: post['Image'],
                //                   video: post['Video'],
                //                   profileImage: profileImage,
                //                 );
                //               } else if (userDataSnapshot.hasError) {
                //                 return Text("Error: ${userDataSnapshot.error}");
                //               } else {
                //                 return Text(" ");
                //               }
                //             },
                //           );
                //         },
                //       );
                //     } else if (snapshot.hasError) {
                //       return Center(
                //         child: Text("Error: $snapshot.error"),
                //       );
                //     }
                //     return const Center(
                //       child: CircularProgressIndicator(),
                //     );
                //   },
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedImage = await _cropImage(File(pickedFile.path));
      setState(() {
        _imageFile = croppedImage;
      });

      // Upload the cropped image to Firebase Storage
      final imageUrl = await _uploadImageToFirebaseStorage(croppedImage);

      // Update the profile picture URL in Firestore
      await userCollections.doc(currentUser.email).update({'profile_img': imageUrl});
    }
  }

  Future<File> _cropImage(File imageFile) async {
    // Implement image cropping logic here (You can use packages like 'image_cropper')
    // For demonstration purposes, let's assume image cropping is already done
    return imageFile;
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      String fileName = '${currentUser.email!}_profile_pic.jpg';
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> getUserData(String email) async {
    final userCollection = FirebaseFirestore.instance.collection("Users");
    final userDoc = await userCollection.doc(email).get();
    final userData = userDoc.data();
    return userData ?? {};
  }

  Future<void> _refreshHomePage() async {
    // Set _isLoading to true to indicate that data is being loaded
    setState(() {
      _isLoading = true;
    });

    // Add some delay for demonstration purposes
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }
}
