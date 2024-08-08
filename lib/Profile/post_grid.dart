import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_app/Firebase/firebase_services.dart';
import 'package:social_app/Homepage/refactored/post_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Homepage/Post/firebase_videoplayer.dart';

class ImageGrid extends StatefulWidget {
 final String userId;
  const ImageGrid({super.key,required this.userId});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  late FirebaseService firebaseService;
  late List<UserPost> posts = [];

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    posts = await firebaseService.fetchUserPosts();
    setState(() {});
  }

  Future<File?> _generateVideoThumbnail(String videoUrl) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      imageFormat: ImageFormat.PNG,
      maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    return thumbnailPath != null ? File(thumbnailPath) : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserPost>>(
      future: firebaseService.fetchUserPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        } else {
          final posts = snapshot.data!.where((post) => post.userId == widget.userId).toList();

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
      itemCount: posts.length, // Total number of posts
      itemBuilder: (BuildContext context, int index) {
        final post = posts[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenPost(post: post),
              ),
            );
          },
          child: post.imageUrl != null
              ? Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
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
          )
              : post.videoUrl != null
              ? FutureBuilder<File?>(
            future: _generateVideoThumbnail(post.videoUrl!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Icon(Icons.error));
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: Colors.white,
                    ),
                  ],
                );
              }
            },
          )
              : const Center(child: Text('No media available')),
        );
      },
    );
  }
}



class FullScreenPost extends StatelessWidget {
  final UserPost post;

  const FullScreenPost({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Center(
        child: post.imageUrl != null
            ? Image.network(
          post.imageUrl!,
          fit: BoxFit.cover,
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
        )
            : post.videoUrl != null
            ? FirebaseVideoPlayerWidget(videoUrl: post.videoUrl!)
            : const Center(child: Text('No media available')),
      ),
    );
  }
}
