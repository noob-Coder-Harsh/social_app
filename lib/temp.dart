import 'package:flutter/material.dart';
import 'Firebase/firebase_services.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    // Fetch all users
    List<Map<String, dynamic>> users = await _firebaseService.getUsers();
    print(users);

    // Fetch a single user
    Map<String, dynamic>? user = await _firebaseService.getUser('abc@gmail.com');
    print(user);

    // Fetch all posts
    List<Map<String, dynamic>> posts = await _firebaseService.getPosts();
    print(posts);

    // Fetch posts by user
    List<Map<String, dynamic>> userPosts = await _firebaseService.getUserPosts('abc@gmail.com');
    print(userPosts);

    // Fetch a single post
    Map<String, dynamic>? post = await _firebaseService.getPost('some_post_id');
    print(post);

    // Fetch comments for a post
    List<Map<String, dynamic>> comments = await _firebaseService.getPostComments('some_post_id');
    print(comments);

    // Fetch a single comment
    Map<String, dynamic>? comment = await _firebaseService.getComment('some_post_id', 'some_comment_id');
    print(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Fetch Data Example'),
      ),
      body: Center(
        child: Text('Check console for data fetch results'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
