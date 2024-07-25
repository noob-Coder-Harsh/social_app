import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        // Check if the user is signing in for the first time
        if (authResult.additionalUserInfo?.isNewUser ?? false) {
          // Store user signup data
          await _storeUserSignUpData(user);
        }

        return user;
      } else {
        // Google sign in was canceled
        return null;
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = authResult.user;
      await _storeUserSignUpData(user);
    } catch (error) {
      print ("Email Sign-Up Error: $error");
      // Handle error as needed
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password);
    } on FirebaseAuthException catch (e) {
      print(e.code);
    }
  }

  Future<void> _storeUserSignUpData(User? user) async {
    try {
      // Determine initial data based on signup method (Google, email, phone, etc.)
      Map<String, dynamic> userData = {
        'email': user?.email ?? "",
        'profile_picture': null,
        'bio': "",
        'followers': [],
        'following': [],
        'posts': [],
        'phone': user?.phoneNumber ?? ""
      };

      // Add username if available
      if (user?.email != null) {
        String? username = user?.email?.split('@').first;
        userData['username'] = username;
      }

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set(userData);
    } catch (error) {
      throw ("Error storing user signup data: $error");
      // Handle error as needed
    }
  }

}
