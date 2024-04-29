import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final TextInputType type;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
        required this.type});
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          hintStyle: TextStyle(color: Colors.grey.shade700,fontWeight: FontWeight.normal),
          hintText: hintText,
        ),
      keyboardType: type,
    );
  }
}
