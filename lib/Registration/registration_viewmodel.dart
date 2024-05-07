import 'package:flutter/material.dart';
import 'registration_model.dart';

class RegistrationViewModel extends ChangeNotifier {
  final RegistrationModel _model = RegistrationModel();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signUp() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _model.signUp(
        emailController.text,
        passwordController.text,
        passwordConfirmController.text,
      );
    } catch (e) {
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _model.signUpWithGoogle();

      // Navigate to the next screen after successful sign-up
    } catch (e) {
      // Handle exceptions and show error messages
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }
}
