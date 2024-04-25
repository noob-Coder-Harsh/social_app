import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget{
  final String text;
  final String sectionName;
  final void Function()? onPressed;

   const MyTextBox({super.key,
    required this.text,
    required this.sectionName,
     this.onPressed});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8)
      ),
      padding: const EdgeInsets.only(left: 20,bottom: 20),
      margin: const EdgeInsets.only(top: 20,left: 20,right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionName,style: TextStyle(color: Colors.grey.shade500),),
              IconButton(onPressed: onPressed, icon: Icon(Icons.settings,color: Colors.grey.shade500,))
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}