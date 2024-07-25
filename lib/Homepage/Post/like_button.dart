import 'package:flutter/material.dart';
import '../../Firebase/firebase_services.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final bool isLiked;
  final int initialLikeCount;

  const LikeButton({Key? key, required this.postId, required this.isLiked, required this.initialLikeCount}) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool isLiked;
  late int likeCount;
  late FirebaseService firebaseService;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService(); // Initialize FirebaseService
    isLiked = widget.isLiked;
    likeCount = widget.initialLikeCount;
  }

  void toggleLikes() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    await firebaseService.updatePostLikes(widget.postId, isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: toggleLikes,
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        ),
        Text('$likeCount likes', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
