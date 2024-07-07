import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/pages/loginorregister.dart';
import 'package:social_app/Profile/profile_page2.dart';
import 'package:social_app/Refactored/samplescreen.dart';

import '../Homepage/New Post/new_post.dart';
import '../navigation_bar.dart';

class Auth extends StatelessWidget{
  const Auth({super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
      if(snapshot.hasData){
        return const Homepage2();
      }else{
        return const LoginOrRegisterPage();
      }
    });
  }
}