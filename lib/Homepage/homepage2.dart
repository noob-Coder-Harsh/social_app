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
    print('followers email: $followingList');
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
                  return _loadingIndicator();
                } else if (!followingSnapshot.hasData ||
                    followingSnapshot.data!.isEmpty) {
                  // If user is not following anyone
                  return _followSomeoneMessage();
                } else {
                  return _buildPostsStream(
                    FirebaseFirestore.instance
                        .collection("User Posts")
                        .where('UserEmail',
                        whereIn: followingSnapshot.data!)
                        .orderBy("TimeStamp", descending: true)
                        .snapshots(),
                  );
                }
              },
            ),
            _buildPostsStream(
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .where('IsPublic', isEqualTo: true)
                  .orderBy("TimeStamp", descending: true)
                  .snapshots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const SliverToBoxAdapter(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _followSomeoneMessage() {
    return const SliverToBoxAdapter(
      child: Center(
        child: Text(
          "Follow someone to see their posts on top",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPostsStream(Stream<QuerySnapshot> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else {
          return FutureBuilder(
            future: Future.wait([
              _fetchHiddenPosts(currentUser),
              _fetchSnoozedPosts(currentUser),
            ]),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return _loadingIndicator();
              } else if (userDataSnapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("Error: ${userDataSnapshot.error}"),
                  ),
                );
              } else {
                final List<dynamic> userData = userDataSnapshot.data ?? [];
                final hiddenPostsSnapshot = userData[0];
                final snoozedPostsSnapshot = userData[1];
                if (hiddenPostsSnapshot == null ||
                    hiddenPostsSnapshot is Set<String> && hiddenPostsSnapshot.isEmpty) {
                  // If hidden posts are not available or empty, show normal posts
                  print('normal posts shown');
                  return _buildNormalPosts(snapshot);
                } else {
                  print('filtered hide posts shown');
                  // If hidden posts are available, filter out hidden posts
                  return _buildFilteredPosts(snapshot, hiddenPostsSnapshot, snoozedPostsSnapshot);
                }
              }
            },
          );
        }
      },
    );
  }

  Widget _buildNormalPosts(AsyncSnapshot snapshot) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = snapshot.data!.docs[index];
          String timeText = post['EditedTime'] != null ? 'edited' : '';
          String formattedTime = post['EditedTime'] != null
              ? formatDate(post['EditedTime'])
              : formatDate(post['TimeStamp']);
          return FutureBuilder<Map<String, dynamic>>(
            future: getUserData(post["UserEmail"]),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.hasData) {
                final userData = userDataSnapshot.data!;
                final username = userData["username"];
                final profileImage = userData["profile_img"];
                return FeedPost(
                  user: username,
                  post: post["Message"],
                  postId: post.id,
                  likes: List<String>.from(post['Likes'] ?? []),
                  time: '$formattedTime   $timeText',
                  image: post['Image'],
                  video: post['Video'],
                  profileImage: profileImage ??
                      "https://firebasestorage.googleapis.com/v0/b/social-flutter-harshk.appspot.com/o/user.png?alt=media&token=173cf9e4-ce01-4572-8bef-776c6b714c6d",
                  userId: post['UserEmail'],
                );
              } else if (userDataSnapshot.hasError) {
                return Text("Error: ${userDataSnapshot.error}");
              } else {
                return const Text(" ");
              }
            },
          );
        },
        childCount: snapshot.data.docs.length,
      ),
    );
  }

  Widget _buildFilteredPosts(
      AsyncSnapshot snapshot, Set<String> hiddenPosts, Set<String> snoozedPosts) {
    final allPosts = snapshot.data.docs;
    final visiblePosts = allPosts.where((post) {
      return !hiddenPosts.contains(post.id) && !snoozedPosts.contains(post.id);
    }).toList();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = visiblePosts[index];
          String timeText = post['EditedTime'] != null ? 'edited' : '';
          String formattedTime = post['EditedTime'] != null
              ? formatDate(post['EditedTime'])
              : formatDate(post['TimeStamp']);
          return FutureBuilder<Map<String, dynamic>>(
            future: getUserData(post["UserEmail"]),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.hasData) {
                final userData = userDataSnapshot.data!;
                final username = userData["username"];
                final profileImage = userData["profile_img"];
                return FeedPost(
                  user: username,
                  post: post["Message"],
                  postId: post.id,
                  likes: List<String>.from(post['Likes'] ?? []),
                  time: '$formattedTime   $timeText',
                  image: post['Image'],
                  video: post['Video'],
                  profileImage: profileImage ??
                      "https://firebasestorage.googleapis.com/v0/b/social-flutter-harshk.appspot.com/o/user.png?alt=media&token=173cf9e4-ce01-4572-8bef-776c6b714c6d",
                  userId: post['UserEmail'],
                );
              } else if (userDataSnapshot.hasError) {
                return Text("Error: ${userDataSnapshot.error}");
              } else {
                return const Text(" ");
              }
            },
          );
        },
        childCount: visiblePosts.length,
      ),
    );
  }


  Future<Set<String>> _fetchHiddenPosts(User currentUser) async {
    final userDataSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .get();
    final hiddenPosts = userDataSnapshot.data()?['hidden_posts'] ?? [];
    final hiddenPostsSet = Set<String>.from(hiddenPosts);
    print('Hidden posts: $hiddenPostsSet');
    return hiddenPostsSet;
  }

  Future<Set<String>> _fetchSnoozedPosts(User currentUser) async {
    final userDataSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .get();
    final snoozedPosts = userDataSnapshot.data()?['snoozed_posts'] ?? [];
    final snoozedPostsSet = Set<String>.from(snoozedPosts.keys);
    print('Snoozed posts: $snoozedPostsSet');
    return snoozedPostsSet;
  }


  Future<void> _refreshHomePage() async {
    // Set _isLoading to true to indicate that data is being loaded
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }
}