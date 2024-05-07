import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/Homepage/Post/edit_post.dart';
import 'package:social_app/Homepage/helper_methods.dart';



class PostHead extends StatefulWidget{
  final String user;
  final String post;
  final String postId;
  final String time;
  final String profileImage;
  final String userId;

  const PostHead({super.key,
    required this.user,
    required this.post,
    required this.postId,
    required this.time,
    required this.profileImage, required this.userId,});

  @override
  State<PostHead> createState() => _PostHeadState();
}

class _PostHeadState extends State<PostHead> {
  bool isFollowing = false; // Add a state variable to track follow status

  @override
  void initState() {
    super.initState();
    final followedUserId = widget.userId;
    checkFollowStatus(followedUserId);
  }

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations here
    super.dispose();
  }

  void displayMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context){
    return  Column(
      children: [
        Row(children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.profileImage), // Display profile image
            backgroundColor: Colors.grey, // You can change this color or remove it
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey.shade900,fontWeight: FontWeight.bold),
              ),
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),

          const Spacer(),
          TextButton(onPressed: toggleFollow,style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(Colors.grey.shade900)),
              child: Text(isFollowing ? 'unfollow' : 'follow'),
          ),
          IconButton(
              onPressed: () {
                showPopupMenu(context);
              },
              icon: const Icon(Icons.more_vert)),
        ]),
      ],
    );
  }
  void showPopupMenu(BuildContext context) {
    final RenderBox overlay =
    Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position.translate(
            button.size.width, 0), // Adjust position to the right of the button
        position.translate(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          onTap: () {
            showModalBottomSheet(
              elevation: 10,
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 700,
                  child: EditPostPage(postId: widget.postId),
                );
              },
            );
          },
          value: 'edit',
          child: Text('Edit'),
        ),
        PopupMenuItem(
          onTap: deletePost,
          value: 'delete',
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          onTap: hidePost,
          value: 'hide',
          child: const Text('Hide'),
        ),
        PopupMenuItem(
          value: 'snooze',
          child: const Text('Snooze'),
          // Add onTap handler for snooze action
          onTap: () {
            showSnoozeOptions(context);
          },
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'edit') {
        // Handle edit action
      } else if (value == 'delete') {
        // Handle delete action
      }
    });
  }

  void showSnoozeOptions(BuildContext context) {
    // Show a dialog or bottom sheet to select snooze duration
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Snooze Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('10 minutes'),
                onTap: () {
                  snoozePost(Duration(minutes: 10));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('1 hour'),
                onTap: () {
                  snoozePost(Duration(hours: 1));
                },
              ),
              ListTile(
                title: Text('1 day'),
                onTap: () {
                  snoozePost(Duration(days: 1));
                },
              ),
              ListTile(
                title: Text('30 days'),
                onTap: () {
                  snoozePost(Duration(days: 30));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void snoozePost(Duration duration) async {
    final currentTime = DateTime.now();
    final snoozeEndTime = currentTime.add(duration);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
      final postId = widget.postId;

      // Add post ID to snoozed posts with snooze end time
      await userRef.update({
        'snoozed_posts.$postId': snoozeEndTime.toUtc(), // Store end time as UTC
      });

      // Show Snackbar notification to user
      final userDisplayName = widget.user;
      // String formattedDate = formatDate(snoozeEndTime as Timestamp);
      final snackbarMessage = 'Post by $userDisplayName has been snoozed until $snoozeEndTime';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackbarMessage)));

      // Schedule a task to remove expired snoozed posts after snooze time ends
      // Future.delayed(duration, () {
      //   _removeExpiredSnoozedPosts(postId, userRef);
      // });
    }
  }

  // void _removeExpiredSnoozedPosts(String postId, DocumentReference userRef) async {
  //   // Get current time
  //   final currentTime = DateTime.now();
  //
  //   // Retrieve snooze end time from user's collection
  //   final userData = await userRef.get();
  //   final snoozedPosts = Map<String, dynamic>.from((userData.data() ?? {})['snoozed_posts'] ?? {});// Check if the post is snoozed
  //   if (snoozedPosts.containsKey(postId)) {
  //     final snoozeEndTime = snoozedPosts[postId].toDate(); // Convert Firestore timestamp to DateTime
  //
  //     // If snooze time has passed, remove post ID from snoozed posts
  //     if (currentTime.isAfter(snoozeEndTime)) {
  //       await userRef.update({'snoozed_posts.$postId': FieldValue.delete()});
  //     }
  //   }
  // }


  void deletePost() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Delete Post"),
            content:
            const Text("Are you sure you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final commentDocs = await FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .get();

                  for (var doc in commentDocs.docs) {
                    await FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .doc(doc.id)
                        .delete();
                  }

                  // Delete the post
                  FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .delete()
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post deleted"),
                        duration: Duration(seconds: 2), // Adjust the duration as needed
                      ),
                    );
                  }).catchError((error) {
                    SnackBar(content: Text("Failed to delete post: $error"),
                    duration: const Duration(seconds: 2),);
                  });

                  // Dismiss the dialog
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ]
        )
    );
  }

  void toggleFollow() async {
    setState(() {
      isFollowing = !isFollowing;
    });

    final followedUserId = widget.userId;
    if (isFollowing) {
      // Follow user
      await followUser(followedUserId);
    } else {
      // Unfollow user
      await unfollowUser(followedUserId);
    }
  }

  Future<void> checkFollowStatus(String followedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && mounted) { // Add mounted check
      final currentUserRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
      final followDoc = await currentUserRef.collection('Following').doc(followedUserId).get();

      if (mounted) { // Check mounted again before calling setState()
        setState(() {
          isFollowing = followDoc.exists;
        });
      }
    }
  }


  Future<void> followUser(String followedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);

      await currentUserRef.collection('Following').doc(followedUserId).set({
        'followedUserId': followedUserId,
      });
      displayMessage('follower added');
    }
  }

  Future<void> unfollowUser(String followedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);

      await currentUserRef.collection('Following').doc(followedUserId).delete();
    }
    displayMessage('follower removed');
  }

  void hidePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef =
      FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
      await userRef.update({
        'hidden_posts': FieldValue.arrayUnion([widget.postId])
      });
      displayMessage("Post marked as Hidden");
    }
  }
}
