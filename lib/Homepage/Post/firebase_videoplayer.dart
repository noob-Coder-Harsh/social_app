import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const FirebaseVideoPlayerWidget({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _FirebaseVideoPlayerWidgetState createState() =>
      _FirebaseVideoPlayerWidgetState();
}

class _FirebaseVideoPlayerWidgetState
    extends State<FirebaseVideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
