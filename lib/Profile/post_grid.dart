// image_grid.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Homepage/refactored/model.dart';
import '../Homepage/refactored/service.dart';

class ImageGrid extends StatefulWidget {

  ImageGrid({super.key});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  late PostsService postService;
  late List<UserPost> posts = [];

  @override
  void initState() {
    super.initState();
    postService = PostsService();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    posts = await postService.fetchUserPosts();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<List<UserPost>>(
      future: postService.fetchUserPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        } else {
          final posts = snapshot.data!.where((post) => post.userId == currentUser.uid).toList();

          if (posts.isEmpty) {
            return const Center(child: Text('No posts found for current user.'));
          } else {
            return buildGridView(posts);
          }
        }
      },
    );
  }

  Widget buildGridView(List<UserPost> posts) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the grid
        crossAxisSpacing: 10.0, // Spacing between columns
        mainAxisSpacing: 10.0, // Spacing between rows
      ),
      itemCount: posts.length, // Total number of images
      itemBuilder: (BuildContext context, int index) {

        return Image.network(
          posts[index].imageUrl!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,// Adjusts the image size to cover the entire grid cell
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Center(child: Text('Failed to load image'));
          },
        );
      },
    );
  }
}

