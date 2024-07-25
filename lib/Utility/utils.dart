import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static void displayMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Widget circularProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Colors.grey.shade700,
        semanticsLabel: 'Please wait...',),
    );
  }

  static Widget linearProgressIndicator() {
    return Center(
      child: LinearProgressIndicator(color: Colors.grey.shade700,
        semanticsLabel: 'Please wait...',),
    );
  }

  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File?> pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String year = dateTime.year.toString();
    String month = dateTime.month.toString();
    String day = dateTime.day.toString();
    String formattedData = '$day/$month/$year';
    return formattedData;
  }
}
