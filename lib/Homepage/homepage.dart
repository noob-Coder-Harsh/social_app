
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/helper_methods.dart';
import 'package:social_app/Homepage/Post/feed_post.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<List<String>> getFollowingList() async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .collection("Following")
        .get();

    final followingList =
    followingSnapshot.docs.map((doc) => doc.id).toList();
    print('following list data $followingList');
    return followingList;
  }

  Future<Map<String, dynamic>> getUserData(String email) async {
    final userCollection = FirebaseFirestore.instance.collection("Users");
    final userDoc = await userCollection.doc(email).get();
    final userData = userDoc.data();
    return userData ?? {};
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: RefreshIndicator(
        onRefresh: _refreshHomePage,
        child: CustomScrollView(
          slivers: [
            FutureBuilder<List<String>>(
              future: getFollowingList(),
              builder: (context, followingSnapshot) {
                if (followingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (!followingSnapshot.hasData ||
                    followingSnapshot.data!.isEmpty) {
                  print('followingsnapshot ka data');
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("Follow someone to see their posts on top",
                        style: TextStyle(color: Colors.white),),
                    ),
                  );
                } else {
                  // Fetch posts from followed users
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .where('UserEmail',
                        whereIn: followingSnapshot.data!)
                        .orderBy("TimeStamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print('snapshot ka data $snapshot.data');
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final post = snapshot.data!.docs[index];
                              String timeText =
                              post['EditedTime'] != null ? 'edited' : '';
                              String formattedTime =
                              post['EditedTime'] != null
                                  ? formatDate(post['EditedTime'])
                                  : formatDate(post['TimeStamp']);
                              return FutureBuilder<Map<String, dynamic>>(
                                future:
                                getUserData(post["UserEmail"]),
                                builder: (context, userDataSnapshot) {
                                  if (userDataSnapshot.hasData) {
                                    final userData =
                                    userDataSnapshot.data!;
                                    final username =
                                    userData["username"];
                                    final profileImage =
                                    userData["profile_img"];
                                    return FeedPost(
                                      user: username,
                                      post: post["Message"],
                                      postId: post.id,
                                      likes: List<String>.from(
                                          post['Likes'] ?? []),
                                      time: '$formattedTime   $timeText',
                                      image: post['Image'],
                                      video: post['Video'],
                                      profileImage: profileImage ??
                                          "https://firebasestorage.googleapis.com/v0/b/social-flutter-harshk.appspot.com/o/user.png?alt=media&token=173cf9e4-ce01-4572-8bef-776c6b714c6d",
                                      userId: post['UserEmail'],
                                    );
                                  } else if (userDataSnapshot.hasError) {
                                    return Text(
                                        "Error: ${userDataSnapshot.error}");
                                  } else {
                                    return Text(" ");
                                  }
                                },
                              );
                            },
                            childCount: snapshot.data!.docs.length,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text("Error: $snapshot.error"),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .where('IsPublic', isEqualTo: true)
                  .orderBy("TimeStamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = snapshot.data!.docs[index];
                        String timeText =
                        post['EditedTime'] != null ? 'edited' : '';
                        String formattedTime =
                        post['EditedTime'] != null
                            ? formatDate(post['EditedTime'])
                            : formatDate(post['TimeStamp']);
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getUserData(post["UserEmail"]),
                          builder: (context, userDataSnapshot) {
                            if (userDataSnapshot.hasData) {
                              final userData = userDataSnapshot.data!;
                              final username = userData["username"];
                              final profileImage =
                              userData["profile_img"];
                              return FeedPost(
                                user: username,
                                post: post["Message"],
                                postId: post.id,
                                likes: List<String>.from(
                                    post['Likes'] ?? []),
                                time: '$formattedTime   $timeText',
                                image: post['Image'],
                                video: post['Video'],
                                profileImage: profileImage ??
                                    "https://firebasestorage.googleapis.com/v0/b/social-flutter-harshk.appspot.com/o/user.png?alt=media&token=173cf9e4-ce01-4572-8bef-776c6b714c6d",
                                userId: post['UserEmail'],
                              );
                            } else if (userDataSnapshot.hasError) {
                              return Text(
                                  "Error: ${userDataSnapshot.error}");
                            } else {
                              return Text(" ");
                            }
                          },
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text("Error: $snapshot.error"),
                    ),
                  );
                }
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }
}



