import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/homepage.dart';
import 'package:social_app/Login/pages/loginorregister.dart';

class Auth extends StatelessWidget{
  const Auth({super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){
      if(snapshot.hasData){
        return const HomePage();
      }else{
        return LoginOrRegisterPage();
      }
    });
  }
}