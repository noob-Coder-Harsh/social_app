import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const FirebaseVideoPlayerWidget({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _FirebaseVideoPlayerWidgetState createState() => _FirebaseVideoPlayerWidgetState();
}

class _FirebaseVideoPlayerWidgetState extends State<FirebaseVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
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
          if (!_controller.value.isInitialized)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          colors: VideoProgressColors(playedColor: Colors.grey.shade900),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _toggleMute,
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
