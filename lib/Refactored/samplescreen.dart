import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/Homepage/refactored/service.dart';
import 'package:social_app/Homepage/refactored/model.dart';

import '../Firebase/firebase_services.dart';

class Homepage2 extends StatefulWidget {
  const Homepage2({super.key});

  @override
  State<Homepage2> createState() => _Homepage2State();
}

class _Homepage2State extends State<Homepage2> {
  late PostsService postService;
  late FirebaseService firebaseService; // Declare FirebaseService

  @override
  void initState() {
    super.initState();
    postService = PostsService(); // Initialize PostsService
    firebaseService = FirebaseService(); // Initialize FirebaseService
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
        future: postService.fetchUserPosts(), // Fetch all posts
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found.'));
          } else {
            final posts = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: posts.map((post) => buildPostCard(post)).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildPostCard(UserPost post) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(post.userId), // Fetch user data for each post
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        } else if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('User data not found.'));
        } else {
          final userData = userSnapshot.data!;
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
                      ClipRRect(
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
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData['username'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${post.timestamp.toDate().toLocal()}'.split(' ')[0],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                          style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(Colors.white), backgroundColor: WidgetStateProperty.all(Colors.grey.shade900)),
                          onPressed: () {},
                          child: const Text('Follow')),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(post.message.isNotEmpty ? 8.0 : 0.0),
                    child: Text(post.message),
                  ),
                ),
                if (post.imageUrl != null) Image.network(post.imageUrl!),
                if (post.videoUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Video URL: ${post.videoUrl}"), // Display the video URL if it exists
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      Text('${post.likes.length} likes', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_outline)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline))
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
