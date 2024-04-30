import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/pages/loginorregister.dart';

import '../navigation_bar.dart';

class Auth extends StatelessWidget{
  const Auth({super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
      if(snapshot.hasData){
        return const CustomNavigationBar();
      }else{
        return const LoginOrRegisterPage();
      }
    });
  }
}