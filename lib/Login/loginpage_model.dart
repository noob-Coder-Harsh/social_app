
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPageModel{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password)async{
    try{
      final UserCredential userCredential = await
      _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    }
    catch(e){
      throw Exception("$e");
    }
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        return user;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception("Google Sign-In Error: $error");
    }
  }
}