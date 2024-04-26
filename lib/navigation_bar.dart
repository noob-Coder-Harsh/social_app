import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
      bottomNavigationBar: GNav(
        // backgroundColor: Colors.black,
        // color:Colors.white,
        // activeColor: Colors.white,
        // tabBackgroundColor: Colors.grey,
        // gap: 8,
        tabs: [
          GButton(icon: Icons.home,text: 'Home',),
          GButton(icon: Icons.home,text: 'Home',),
          GButton(icon: Icons.home,text: 'Home',),
          GButton(icon: Icons.home,text: 'Home',),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      appBar: AppBar(
        title: Text('navbar sample'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Center(child: Text('Home Page')),
          Center(child: Text('Search Page')),
          Center(child: Text('Notifications Page')),
          Center(child: Text('Profile Page')),
        ],
      ),
    );
  }
}