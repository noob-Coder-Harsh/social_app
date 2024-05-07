
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationModel{

  Future<void> signUp(String email, String password, String confirmPassword) async {

    if(password != confirmPassword){
      throw Exception('Password do not match');
    }

    try{
      UserCredential userCredential = await
      FirebaseAuth.instance.
      createUserWithEmailAndPassword(
          email: email,
          password: password);

      await FirebaseFirestore.instance
          .collection("Users").doc(userCredential.user!.uid)
          .set({
        'username' : email.split('@')[0],
        'bio' : "write something about yourself",
        'email' : email,
        'password' : password,
        'profile_imgPath' : "assets/profile.png",
      });
    }on FirebaseAuthException catch(e){
      if(e.code == 'invalid-email'){
        throw Exception('Invalid Email, Please check');
      }else{
        throw Exception(e.message ?? "an error occured");
      }
    }
    catch (e){
      throw Exception(e.toString());
    }
  }

  Future<User?> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;
        final email = user?.email;
        if (email != null) {
          await FirebaseFirestore.instance.collection("Users").doc(user!.uid).set({
            'username': email.split('@')[0],
            'bio': "write something about yourself",
            'email': email,
            'password' : email,
            'profile_imgPath': "assets/profile.png",
          });
        }

        return user;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception("Google Sign-In Error: $error");
    }
  }

}