import 'package:flutter/material.dart';
import 'package:social_app/Homepage/post_model.dart';
import 'package:social_app/Homepage/post_widget.dart';
import '../Firebase/firebase_services.dart';

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
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<UserPost>>(
        future: firebaseService.fetchUserPosts(),
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
                children: posts.map((post) => PostCard(post: post)).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
