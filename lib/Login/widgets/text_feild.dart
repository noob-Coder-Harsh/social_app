import 'package:flutter/material.dart';

class MyTextFeild extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;

  const MyTextFeild(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey.shade500,fontWeight: FontWeight.normal),
          hintText: hintText,
            fillColor: Colors.white54,
            filled: true,
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30)
            ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30)
          )
        ),
    );
  }
}
