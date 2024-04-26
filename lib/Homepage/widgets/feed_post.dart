import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/helper_methods.dart';
import 'package:social_app/Homepage/widgets/comment.dart';
import 'package:social_app/Homepage/widgets/comment_button.dart';
import 'package:social_app/Homepage/widgets/like_button.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text("Add Comment"),
          content: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(hintText: "Write a comment .. "),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _commentTextController.clear();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                _commentTextController.clear();
                Navigator.pop(context);
              },
              child: Text("Post"),
            ),
          ]),
    );
  }
  
  void deletePost(){
    showDialog(context: context, builder: (context)=>
        AlertDialog(
            title: const Text("Delete Post"),
            content: const Text("Are you sure you want to delete this post?"),
            actions: [
            TextButton(
            onPressed: () => Navigator.pop(context),
    child: const Text("Cancel"),
    ),
    TextButton(
    onPressed: () async {
// delete the comments from firestore first
// (if you only delete the post, the comments will still be stored in firestore)
    final commentDocs = await FirebaseFirestore. instance
        . collection("User Posts")
        . doc (widget. postId)
        . collection("Comments")
        . get ();

    for (var doc in commentDocs.docs) {
    await FirebaseFirestore. instance
        . collection("User Posts")
        . doc (widget. postId)
        . collection("Comments")
        . doc(doc.id)
        . delete();
    }
    FirebaseFirestore. instance
        . collection("User Posts")
        . doc (widget. postId)
        . delete()
        . then((value) => print("post deleted") )
        . catchError(
            (error) => print("failed to delete post: $error"));

// dismiss the dialog
      Navigator. pop(context);
    },
    child: const Text("Delete"),
    ), // TextButton

            ]
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white70),
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1,color: Colors.grey,)),
                ),
                child: Column(
                  children: [
                    Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade400, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.user,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                         Spacer(),
                          IconButton(onPressed: (){
                            showPopupMenu(context);
                          }, icon: Icon(Icons.more_vert)),
                        ]
                    ),
                    Row(
                      children: [
                        SizedBox(width: 60,),
                        Text(widget.time,style: TextStyle(color: Colors.grey.shade500),),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 300,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  border: Border(bottom: BorderSide(width: 1,color: Colors.grey))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  LikeButton(onTap: toggleLikes, isLiked: isLiked),
                  Text(widget.likes.length.toString()),
                  SizedBox(width: 10,),
                  CommentButton(onTap: showCommentDialog),
                  SizedBox(width: 5,),
                  Text('0')
                ],
              ),
            StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore. instance
                . collection("User Posts")
                . doc (widget. postId)
                .collection("Comments")
                . orderBy("CommentTime", descending: true)
                . snapshots (),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                width: 300,
                height: 200,
                child: ListView(
                  shrinkWrap: true, // for nested lists
                  // physics: const NeverScrollableScrollPhysics(),
                  children: snapshot. data !. docs. map ( (doc) {
                    final commentData = doc.data() as Map<String, dynamic>;

                    return Comment (
                      text: commentData["CommentText"],
                      user: commentData["CommentedBy"],
                      time: formatDate(commentData ["CommentTime"]),
                    );
                  }). toList(),
                ),
              );
            })

            ],
          ),

    );
  }
  void showPopupMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position.translate(button.size.width, 0), // Adjust position to the right of the button
        position.translate(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
        PopupMenuItem(
          onTap: deletePost,
          value: 'delete',
          child: Text('Delete'),
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
}
