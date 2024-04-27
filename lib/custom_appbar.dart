import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? signOut;

  const CustomAppBar({super.key, required this.signOut});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      elevation: 0,
      title: Image.asset(
        'assets/title.png',
        width: 120,
        height: 40,
        color: Colors.white,
      ),
      actions: [
        IconButton(
          onPressed: signOut,
          icon: const Icon(Icons.logout),
          color: Colors.white70,
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
