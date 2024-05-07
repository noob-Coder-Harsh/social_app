
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/loginpage_model.dart';

class LoginPageViewModel with ChangeNotifier{
  final LoginPageModel _model = LoginPageModel();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<User?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final User? user = await _model.signIn(email,password);
    _isLoading = false;
    notifyListeners();
    return user;
  }

  Future<User?> signInWithGoogle()async{
    _isLoading = true;
    notifyListeners();
    final User? user = await _model.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
    return user;
  }

}

