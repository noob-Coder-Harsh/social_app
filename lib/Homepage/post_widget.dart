import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/post_model.dart';
import 'package:social_app/Homepage/widgets/comment.dart';
import 'package:social_app/Homepage/widgets/like_button.dart';
import 'package:social_app/Homepage/widgets/media_loader.dart';
import 'package:social_app/Homepage/widgets/post_options_menu.dart';

import '../Firebase/firebase_services.dart';
import '../Profile/other_profile_page.dart';
import '../Utility/utils.dart';

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
          return Center(child: Container());
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
                                builder: (context) => OtherProfilePage(userId: post.userId),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: userData['profile_picture'] != null
                                ? Image.network(
                                    userData['profile_picture'],
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 30,
                                  ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
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
                          onPressed: () {
                            Utils.displayMessage(context, "Feature not available now");
                          },
                          child: const Text('Follow'),
                        ),
                        PostOptionsMenu(
                          postId: post.id,
                          imageUrl: post.imageUrl ?? "",
                          videoUrl: post.videoUrl ?? "",
                          userId: post.userId,
                        ),
                      ],
                    )),
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
