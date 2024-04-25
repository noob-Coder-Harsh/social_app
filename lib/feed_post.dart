import 'package:flutter/material.dart';

class FeedPost extends StatelessWidget{
  final String user;
  final String post;

  const FeedPost({super.key,required this.user,required this.post});
  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Column(
          children: [
            Text(user),
            Text(post)
          ],
        ),
      ],
    );
  }
}