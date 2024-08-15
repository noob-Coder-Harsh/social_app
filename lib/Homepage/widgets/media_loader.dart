import 'package:flutter/material.dart';

import '../../Utility/utils.dart';
import 'firebase_videoplayer.dart';

class MediaLoader extends StatefulWidget {
  final String url;
  final bool isImage;

  const MediaLoader({Key? key, required this.url, required this.isImage}) : super(key: key);

  @override
  State<MediaLoader> createState() => _MediaLoaderState();
}

class _MediaLoaderState extends State<MediaLoader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Utils.isConnected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.data!) {
          return const Center(child: Text('No internet connection'));
        } else {
          return widget.isImage
              ? Image.network(
            widget.url,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
          )
              : FirebaseVideoPlayerWidget(videoUrl: widget.url);
        }
      },
    );
  }
}