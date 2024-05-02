import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../navigation_bar.dart'; // import your navigation screen

class GoogleLogin extends StatelessWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            signInWithGoogle(context); // Pass the context to the function
          },
          child: Text('Login with Google'),
        ),
      ),
    );
  }
}

signInWithGoogle(BuildContext context) async {
  try {
    // Sign out the current user
    await FirebaseAuth.instance.signOut();

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user?.displayName);

    // Navigate to your desired screen after successful sign-in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const CustomNavigationBar(), // Replace NavigationScreen() with your desired screen
      ),
    );
  } catch (error) {
    print("Error signing in with Google: $error");
    // Handle error
  }
}