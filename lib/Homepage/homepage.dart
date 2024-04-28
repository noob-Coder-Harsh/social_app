import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/helper_methods.dart';
import 'package:social_app/Homepage/Post/feed_post.dart';


class HomePage extends StatefulWidget{

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<Map<String, dynamic>> getUserData(String email) async {
    final userCollection = FirebaseFirestore.instance.collection("Users");
    final userDoc = await userCollection.doc(email).get();
    final userData = userDoc.data();
    return userData ?? {};
  }


  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshHomePage,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        String timeText = post['EditedTime'] != null ? 'edited' : '';
                        String formattedTime = post['EditedTime'] != null
                            ? formatDate(post['EditedTime'])
                            : formatDate(post['TimeStamp']);
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getUserData(post["UserEmail"]), // Fetch username asynchronously
                          builder: (context, userDataSnapshot) {
                            if (userDataSnapshot.hasData) {
                              // final username = usernameSnapshot.data!;
                              final userData = userDataSnapshot.data!;
                              final username = userData["username"]; // Assuming "username" is a key in your user data
                              final profileImage = userData["profile_img"]; // Assuming "profile_img" is a key for profile image URL
                              return FeedPost(
                                user: username,
                                post: post["Message"],
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                time: '$formattedTime   $timeText',
                                image: post['Image'],
                                video: post['Video'],
                                profileImage: profileImage,
                              );
                            } else if (userDataSnapshot.hasError) {
                              return Text("Error: ${userDataSnapshot.error}");
                            } else {
                              return Text(" ");
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: $snapshot.error"),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
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