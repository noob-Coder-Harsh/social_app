import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/refactored/post_model.dart';

import '../Firebase/firebase_services.dart';
import '../Homepage/Post/comment.dart';
import '../Homepage/Post/firebase_videoplayer.dart';
import '../Homepage/Post/like_button.dart';
import '../Profile/other_profile_page.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  late FirebaseService firebaseService;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    return await firebaseService.getUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Image.asset(
          'assets/title.png',
          width: 150,
          color: Colors.grey.shade900,
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: FutureBuilder<List<UserPost>>(
        future: firebaseService.fetchUserPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator(semanticsLabel: 'Loading...',));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found.'));
          } else {
            final posts = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: posts.map((post) => PostCard(post: post)).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final UserPost post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    FirebaseService firebaseService = FirebaseService();
    return await firebaseService.getUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(post.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        } else if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        } else if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('User data not found.'));
        } else {
          final userData = userSnapshot.data!;
          bool isLiked = post.likes.contains(FirebaseAuth.instance.currentUser!.uid);

          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherProfilePage(userId:post.userId),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: userData['profile_picture'] != null
                                ? Image.network(
                              userData['profile_picture'],
                              width: 25,
                              height: 25,
                              fit: BoxFit.cover,
                            )
                                : const Icon(
                              Icons.person,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherProfilePage(userId: post.userId),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['username'] ?? 'Unknown User',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${post.timestamp.toDate().toLocal()}'.split(' ')[0],
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            backgroundColor: WidgetStateProperty.all(Colors.grey.shade900),
                          ),
                          onPressed: () {},
                          child: const Text('Follow'),
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                      ],
                    )
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(post.message.isNotEmpty ? 8.0 : 0.0),
                    child: Text(post.message),
                  ),
                ),
                if (post.imageUrl != null) MediaLoader(url: post.imageUrl!, isImage: true),
                if (post.videoUrl != null) MediaLoader(url: post.videoUrl!, isImage: false),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      LikeButton(postId: post.id, isLiked: isLiked, initialLikeCount: post.likes.length),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CommentWidget(postId: post.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class MediaLoader extends StatefulWidget {
  final String url;
  final bool isImage;

  const MediaLoader({Key? key, required this.url, required this.isImage}) : super(key: key);

  @override
  State<MediaLoader> createState() => _MediaLoaderState();
}

class _MediaLoaderState extends State<MediaLoader> {
  @override
  Widget build(BuildContext context) {
    return widget.isImage
        ? Image.network(
            widget.url,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
          )
        : FirebaseVideoPlayerWidget(videoUrl: widget.url); // Use your VideoPlayerWidget here
  }
}
