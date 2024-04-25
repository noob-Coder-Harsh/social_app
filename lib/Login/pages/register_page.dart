import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import '../widgets/button.dart';

class RegisteredPage extends StatefulWidget {
  final Function()? onTap;

  const RegisteredPage({super.key, required this.onTap});

  @override
  State<RegisteredPage> createState() => _RegisteredPageState();
}

class _RegisteredPageState extends State<RegisteredPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  bool _isLoading = false;

  void signUp() async {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
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
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Adjust duration as needed
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          // Handle tap here
          _showTapSplash(context, details.localPosition);
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, // Start from bottom
                  end: Alignment.topCenter, // End at top
                  colors: [
                    Color.lerp(Colors.grey.shade900, Colors.grey.shade300, _controller.value)!,
                    Color.lerp(Colors.grey.shade300, Colors.grey.shade900, _controller.value)!,
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        const Icon(Icons.lock, size: 100),
                        const SizedBox(height: 20),
                        Text('Welcome! we missed you', style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 20),
                        MyTextFeild(
                          controller: _usernameController,
                          hintText: 'enter your email',
                          obscureText: false,
                        ),
                        const SizedBox(height: 10),
                        MyTextFeild(
                          controller: _passwordController,
                          hintText: 'enter your password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        MyTextFeild(
                          controller: _passwordConfirmController,
                          hintText: 'Re-enter your password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),

                        _isLoading
                            ?CircularProgressIndicator():
                            MyButton(text: 'SignUp', function: signUp),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already a Member?', style: TextStyle(color: Colors.grey.shade700)),
                            TextButton(
                              onPressed: widget.onTap,
                              child: Text('Login Now', style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTapSplash(BuildContext context, Offset tapPosition) {
    final overlay = Overlay.of(context)?.context;
    if (overlay != null) {
      final splash = Positioned(
        left: tapPosition.dx - 25,
        top: tapPosition.dy - 25,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      );
      OverlayEntry entry = OverlayEntry(builder: (context) => splash);
      Overlay.of(context).insert(entry);
      Future.delayed(Duration(milliseconds: 200), () {
        entry.remove();
      });
    }
  }
}
