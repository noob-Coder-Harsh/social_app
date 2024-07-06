import 'package:flutter/material.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Text('user details'),
          Text('user name'),
          Text('user email'),
          Text('user phone'),
          Text('user bio'),
          Text('user profile url'),
          Text('followers list'),
          Text('following list'),
          Text('posts count'),
          Text('post ids list')
        ],
      ),
    );
  }
}
