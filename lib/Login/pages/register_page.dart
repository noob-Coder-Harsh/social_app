import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import 'package:social_app/navigation_bar.dart';
import '../../Refactored/auth_service.dart';
import '../widgets/button.dart';

class RegisteredPage extends StatefulWidget {
  final Function()? onTap;

  const RegisteredPage({super.key, required this.onTap});

  @override
  State<RegisteredPage> createState() => _RegisteredPageState();
}

class _RegisteredPageState extends State<RegisteredPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> signUpWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    if (_passwordController.text != _passwordConfirmController.text) {
      displayMessage('Passwords do not match');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      displayMessage('Registration successful');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationBarUI()));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        displayMessage('The email address is badly formatted');
      } else {
        displayMessage(e.message ?? 'An error occurred');
      }
    } catch (e) {
      displayMessage('An unexpected error occurred');
    } finally {
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
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
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
                  Text('Social App Welcome\'s You', style: TextStyle(color: Colors.grey.shade100)),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: _emailController,
                    hintText: 'enter your email',
                    obscureText: false,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'enter your password',
                    obscureText: true,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: _passwordConfirmController,
                    hintText: 'Re-enter your password',
                    obscureText: true,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ?const CircularProgressIndicator():
                  MyButton(text: 'SignUp', function: signUpWithEmail),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already a Member?', style: TextStyle(color: Colors.grey.shade300)),
                      TextButton(
                        onPressed: widget.onTap,
                        child: Text('Login Now', style: TextStyle(color: Colors.blue.shade500)),
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
