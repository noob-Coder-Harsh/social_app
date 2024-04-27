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
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade300,
      //   borderRadius: BorderRadius.circular(4)
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey
                ),
                child: const Icon(Icons.person,size: 30,color: Colors.white70,),
              ),
              const SizedBox(width: 5,),
              Text(user,style: TextStyle(color: Colors.grey.shade900,fontWeight: FontWeight.bold),),
              const Text('  '),
              Text(time,style: TextStyle(color: Colors.grey.shade500))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(text,style: TextStyle(color: Colors.grey.shade900),),
          ),

        ],
      ),
    );
  }
}