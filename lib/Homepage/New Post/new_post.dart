import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Login/widgets/text_feild.dart';

class NewPosts extends StatefulWidget{
  const NewPosts({super.key});

  @override
  State<NewPosts> createState() => _NewPostsState();
}

class _NewPostsState extends State<NewPosts> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1)),
          color: Colors.grey[900]
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextFeild(controller: textController
                    , hintText: 'write something to post',
                    obscureText: false),
              ),
            ),
            IconButton(onPressed:(){
              FocusScope.of(context).unfocus();
              postMessage();
            },
                icon: Icon(Icons.arrow_circle_up,
                  color: Colors.grey.shade300,
                ))
          ],),
        ],
      ),
    );
  }
  void postMessage(){
    if(textController.text.isNotEmpty){
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail':currentUser.email,
        'Message' : textController.text,
        'TimeStamp' : Timestamp.now(),
        'Likes' : [],
      });
    }
    setState(() {
      textController.clear();
    });
  }
}

class NewPostsBottom extends StatefulWidget{
  const NewPostsBottom({super.key});

  @override
  State<NewPostsBottom> createState() => _NewPostsBottomState();
}

class _NewPostsBottomState extends State<NewPostsBottom> {
  @override
  Widget build(BuildContext context){
    return Center(
      child: Text('New post bottom'),
    );
  }
}