import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_app/homepage.dart';
import 'package:social_app/Login/pages/loginorregister.dart';

class Auth extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){
      if(snapshot.hasData){
        return HomePage();
      }else{
        return LoginOrRegisterPage();
      }
    });
  }
}