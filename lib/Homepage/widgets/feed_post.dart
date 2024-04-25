import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/widgets/like_button.dart';

class FeedPost extends StatefulWidget{
  final String user;
  final String post;
  final String postId;
  final List<String> likes;

  const FeedPost({super.key,
    required this.user,
    required this.post,
    required this.postId,
    required this.likes});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLikes(){
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
    FirebaseFirestore.instance.collection('User Posts') . doc (widget.postId);

    if(isLiked){
      postRef.update({'Likes': FieldValue.arrayUnion([currentUser.email])});
    }else{
      postRef. update({
        'Likes': FieldValue. arrayRemove([currentUser.email])});
    }
  }
  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.only(top: 25,left: 25,right: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white70
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.person,
                color: Colors.white70,),
            ),
          ),
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user,style: TextStyle(color: Colors.grey.shade500),),
              const SizedBox(height: 10,),
              Text(widget.post,style: TextStyle(color: Colors.grey.shade700,),softWrap: true,),
              const SizedBox(height: 10,),
              Row(
                children: [
                  LikeButton(onTap: toggleLikes, isLiked: isLiked),
                  Text(widget.likes.length.toString())
                ],
              ),


            ],
          ),
        ],
      ),
    );
  }
}