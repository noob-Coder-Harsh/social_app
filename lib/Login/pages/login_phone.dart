import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/Login/widgets/button.dart';
import 'package:social_app/navigation_bar.dart';

import '../widgets/text_feild.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';
  bool isOTP = false;

  void displayMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
        content: Text(message)));
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
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/title.png',width: 250,),
              const SizedBox(height: 50),
              const Text('use +91 for Indian origin Phone Numbers',
                style: TextStyle(color: Colors.white70),),
              const SizedBox(height: 10.0),
              MyTextField(
                controller: _phoneNumberController,
                hintText: 'enter your phone number',
                obscureText: false,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 10.0),
              MyButton(function: (){
                _verifyPhoneNumber();
                setState(() {
                  isOTP = true;
                });
              }, text: 'Send OTP'),
              const SizedBox(height: 10.0),
              Visibility(
                visible: isOTP,
                child: Column(
                  children: [
                    MyTextField(
                      controller: _otpController,
                      hintText: 'enter OTP',
                      obscureText: false,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 10.0),
                    MyButton(function: _verifyOTP, text: 'Verify OTP'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = _phoneNumberController.text.trim();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomNavigationBar()));
        },
        verificationFailed: (FirebaseAuthException e) {
          displayMessage('${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          displayMessage('Verification code retrieval timed out');
        },
      );
    } catch (e) {
      displayMessage('Error during phone authentication: $e');
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: otp);
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const CustomNavigationBar()));
    } catch (e) {
      displayMessage('Error verifying OTP: $e');
    }
  }
}
