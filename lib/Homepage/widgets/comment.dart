import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment ({
    super. key,
    required this.text,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4)
      ),
      child: Column(
        children: [
          Text(text,style: TextStyle(color: Colors.grey.shade700),),
          Row(
            children: [
              Text(user,style: TextStyle(color: Colors.grey.shade400),),
              Text('.'),
              Text(time,style: TextStyle(color: Colors.grey.shade400))
            ],
          )
        ],
      ),
    );
  }
}