import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Refactored/auth_service.dart';
import 'package:social_app/Refactored/utils.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  final AuthService _authService = AuthService();
  Map<String,dynamic>? _userData;

  Future<void> _fetchUserData() async {
    Map<String, dynamic>? userData = await _authService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _userData != null ? Column(
        children: [
          SizedBox(height: 20,),
          Text('user details'),
          if(_userData!['username'] != null)
          Text('user name - ${_userData?['username']}'),
          if(_userData!['email'] != null)
          Text('user email - ${_userData?['email']}'),
          if(_userData!['phone'] != null)
          Text('user phone - ${_userData!['phone']}'),
          Text('user bio - ${_userData?['bio']}'),
          _userData!['profile_picture'] == null?
          Text('no profile url') : Text(_userData!['profile_picture']),
          Text('followers list - ${_userData!['followers'].length}'),
          Text('following list  - ${_userData!['following'].length}'),
          Text('posts count  - ${_userData!['posts'].length}'),
          Text('post ids list')
        ],
      ) : Utils.circularProgressIndicator(),
    );
  }
}
