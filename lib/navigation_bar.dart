import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:social_app/Homepage/New%20Post/new_post.dart';
import 'package:social_app/Homepage/homepage2.dart';
import 'package:social_app/Profile/profile_page.dart';

import 'custom_appbar.dart';

class CustomNavigationBar extends StatefulWidget{
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
          child: GNav(
            padding: EdgeInsets.all(16),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            backgroundColor: Colors.black,
            color:Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.brown.shade500,
            gap: 8,
            tabs: [
              GButton(icon: Icons.home,text: 'Home',),
              GButton(icon: Icons.add,text: 'New Post',),
              GButton(icon: Icons.person,text: 'Profile',),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(index);
              });
            },
          ),
        ),
      ),

      appBar: CustomAppBar(signOut: signOut),

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomePage(),
          NewPostsBottom(),
          ProfilePage()
        ],
      ),
    );
  }
  void signOut(){
    FirebaseAuth.instance.signOut();
  }
}