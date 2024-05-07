import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_app/Login/pages/login_phone.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import '../../navigation_bar.dart';
import '../widgets/button.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final  _usernameController = TextEditingController();
  final  _passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        return user;
      } else {
        // Google sign in was canceled
        return null;
      }
    } catch (error) {
      displayMessage("Google Sign-In Error: $error");
      return null;
    }
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      displayMessage(e.code);
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  void displayMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, // Start from bottom
            end: Alignment.topCenter, // End at top
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade300
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Image.asset('assets/title.png',width: 250,),
                  const SizedBox(height: 50),
                  Text('Welcome! we missed you', style: TextStyle(color: Colors.grey.shade100)),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: _usernameController,
                    hintText: 'enter your email',
                    obscureText: false,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'enter your password',
                    obscureText: true,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(text: 'Email Login', function: signIn,
                      imageName: Image.asset('assets/gmail.png',width: 20,height: 20,)
                  ),
                  const SizedBox(height: 10,),
                  MyButton(function: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginWithPhone()));
                  }, text: 'Login with Phone',
                      imageName: Image.asset('assets/telephone.png',width: 20,height: 20,)
                  ),
                  const SizedBox(height: 10,),
                  MyButton(function: () async {
                    User? user = await _signInWithGoogle();
                    if (user != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const CustomNavigationBar()));
                    } else {
                      displayMessage('Sign in failed. Please try again.');
                    }
                  }, text: 'Login with google',
                    imageName: Image.asset('assets/google.png',width: 20,height: 20,)
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a Member?', style: TextStyle(color: Colors.grey.shade300)),
                      TextButton(
                        onPressed: widget.onTap,
                        child: Text('Register Now', style: TextStyle(color: Colors.blue.shade500)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
