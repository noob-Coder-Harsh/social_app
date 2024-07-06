import 'package:flutter/material.dart';

class Utils {
  static void displayMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Widget circularProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Colors.grey.shade700,),
    );
  }
}
