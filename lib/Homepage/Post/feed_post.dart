import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/Post/post_head.dart';
import 'package:social_app/Homepage/helper_methods.dart';
import 'package:social_app/Homepage/Post/comment.dart';
import 'package:social_app/Homepage/Post/comment_button.dart';
import 'package:social_app/Homepage/Post/like_button.dart';

class FeedPost extends StatefulWidget {
  final String user;
  final String post;
  final String postId;
  final String time;
  final List<String> likes;

  const FeedPost(
      {super.key,
      required this.user,
      required this.post,
      required this.postId,
      required this.likes,
      required this.time});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLikes() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }


  void showCommentDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 600,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Comment",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  SizedBox(
                    height: 50,width: 275,
                    child: TextField(
                      controller: _commentTextController,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      addComment(_commentTextController.text);
                      _commentTextController.clear();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.add_circle),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .orderBy("CommentTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true, // for nested lists
                      // physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        final commentData = doc.data() as Map<String, dynamic>;
                        return Comment(
                          text: commentData["CommentText"],
                          user: commentData["CommentedBy"],
                          time: formatDate(commentData["CommentTime"]),
                        );
                      }).toList(),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      //main container of post
      margin: const EdgeInsets.only(top: 5,left: 5,right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18,top: 8),
            child: PostHead(user: widget.user, post: widget.post, postId: widget.postId, time: widget.time),
          ),
          SingleChildScrollView(
            child: SizedBox(
              //caption container
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0,right: 18,top: 8),
                    child: Text(
                      widget.post,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  Image.asset('assets/test2.jpg')
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18,top: 8),
            child: Row(
              children: [
                LikeButton(onTap: toggleLikes, isLiked: isLiked),
                const SizedBox(
                  width: 10,
                ),
                CommentButton(onTap: showCommentDialog),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18,top: 8),
            child: Text("Liked by ${widget.likes.length} and others"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18),
            child: Text('Commented by 0....'),
          ),
          SizedBox(height: 10,)

        ],
      ),
    );
  }


}
