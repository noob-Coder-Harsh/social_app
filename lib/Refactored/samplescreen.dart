  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:social_app/Homepage/refactored/service.dart';

  import '../Homepage/refactored/model.dart';
  import 'auth_service.dart';


  class Homepage2 extends StatefulWidget {
    const Homepage2({super.key});

    @override
    State<Homepage2> createState() => _Homepage2State();
  }

  class _Homepage2State extends State<Homepage2> {
    late PostsService postService;

    @override
    void initState() {
      super.initState();
      postService = PostsService(); // Initialize without the current user
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
      return Container(
        margin: const EdgeInsets.only(bottom: 5),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: post.imageUrl != null
                        ? Image.network(
                      post.imageUrl!,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    )
                        : const Icon(
                      Icons.person,
                      size: 75,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userId, style: const TextStyle(fontWeight: FontWeight.bold)), // Display user ID
                      Text(
                        '${post.timestamp.toDate().toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          backgroundColor: WidgetStateProperty.all(Colors.grey.shade900)
                      ),
                      onPressed: () {}, child: const Text('Follow')),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(post.message),
              ),
            ),
            if (post.imageUrl != null)
              Image.network(post.imageUrl!), // Display the image if it exists
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
  }
