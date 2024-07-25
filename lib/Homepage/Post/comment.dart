import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/Firebase/firebase_services.dart';

class CommentWidget extends StatefulWidget {
  final String postId;

  const CommentWidget({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentTextController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  late FirebaseService firebaseService;
  Map<String, dynamic>? _userData;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    _fetchUserData();
    _fetchCommentCount();
  }

  Future<void> _fetchUserData() async {
    _userData = await firebaseService.getUserData();
    setState(() {});
  }

  Future<void> _fetchCommentCount() async {
    final count = await firebaseService.getCommentCount(widget.postId);
    setState(() {
      _commentCount = count;
    });
  }

  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('MMM d, yyyy h:mm a');
    return formatter.format(date);
  }

  void addComment(String commentText) {
    if (commentText.isNotEmpty && _userData != null) {
      firebaseService.addComment(widget.postId, commentText, _userData!['username'] ?? 'No Username').then((_) {
        _fetchCommentCount(); // Refresh the comment count after adding a new comment
      });
    }
  }

  void showCommentDialog(BuildContext context) {
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
                  Expanded(
                    child: TextField(
                      controller: _commentTextController,
                      decoration: const InputDecoration(
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
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getComments(widget.postId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((doc) {
                      final commentData = doc.data() as Map<String, dynamic>;
                      return Comment(
                        text: commentData["CommentText"],
                        user: commentData["CommentedBy"],
                        time: formatDate(commentData["CommentTime"]),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => showCommentDialog(context),
          child: Row(
            children: [
              const Icon(
                Icons.comment,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              Text('$_commentCount'),
            ],
          ),
        ),
      ],
    );
  }
}

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;

  const Comment({
    Key? key,
    required this.text,
    required this.user,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: const Icon(Icons.person, size: 30, color: Colors.white70),
              ),
              const SizedBox(width: 5),
              Text(user, style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.bold)),
              const Text('  '),
              Text(time, style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(text, style: TextStyle(color: Colors.grey.shade900)),
          ),
        ],
      ),
    );
  }
}
