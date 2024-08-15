import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../Firebase/firebase_services.dart';
import '../../Utility/utils.dart';

class PostOptionsMenu extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String videoUrl;
  final String userId;

  PostOptionsMenu({
    Key? key,
    required this.postId,
    required this.imageUrl,
    required this.videoUrl,
    required this.userId,
  }) : super(key: key);

  final FirebaseService firebaseService = FirebaseService();

  void showPopupMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position.translate(button.size.width, 0),
        position.translate(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          onTap: () => _saveMedia(context),
          value: 'save',
          child: const Text('Save'),
        ),
        PopupMenuItem(
          onTap: () => _deletePost(context),
          value: 'delete',
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          onTap: () {
            Utils.displayMessage(context, "Feature not available now");
          },
          value: 'hide',
          child: const Text('Follow'),
        ),
      ],
      elevation: 8.0,
    );
  }

  Future<void> _saveMedia(BuildContext context) async {
    bool connected = await Utils.isConnected();
    if (!connected) {
      Utils.displayMessage(context, "No internet connection. Cannot save media.");
      return;
    }
    String mediaUrl = imageUrl.isNotEmpty ? imageUrl : videoUrl;
    if (mediaUrl.isEmpty) {
      Utils.displayMessage(context, "No media to save");
      return;
    }

    try {
      // Check for storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Utils.displayMessage(context, "Storage permission denied");
        return;
      }

      // Get the application's documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = "${appDocDir.path}/${mediaUrl.split('/').last}";

      // Download the file
      Dio dio = Dio();
      await dio.download(mediaUrl, savePath);

      // Notify the user
      Utils.displayMessage(context, "Media saved to $savePath");
    } catch (error) {
      Utils.displayMessage(context, "Failed to save media: $error");
    }
  }

  void _deletePost(BuildContext context) async {
    try {
      await firebaseService.deletePost(postId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post deleted"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$error"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showPopupMenu(context);
      },
    );
  }
}
