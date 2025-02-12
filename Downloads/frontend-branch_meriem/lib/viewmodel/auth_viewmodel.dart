import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

import '../view/auth/otp_verification_page.dart';
import '../view/auth/reset_password_bottom_sheet.dart';

class AuthViewModel extends ChangeNotifier { // 🔥 IMPORTANT
  final AuthRepository _authRepository = AuthRepository();
  bool isLoading = false;

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _authRepository.loginUser(email, password);

      if (data == null || !data.containsKey("token")) {
        throw Exception("Invalid token received");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful!")),
      );

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/********************************/

  Future<void> registerUser(
    BuildContext context,
    String fullName,
    String email,
    String password,

  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authRepository.registerUser(
        fullName: fullName,
        email: email,
        password: password,
  
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/********************************/

  Future<void> sendForgotPasswordRequest(BuildContext context, String email) async {
    try {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter an email")),
        );
        return;
      }

      isLoading = true;
      notifyListeners();

      final response = await _authRepository.sendForgotPasswordRequest(email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );

      // Ouvrir le bottom sheet de vérification OTP
      _showOTPBottomSheet(context, email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/********************************/

Future<bool> verifyOtp(BuildContext context, String email, String otp) async {
  try {
    isLoading = true;
    notifyListeners();

    final response = await _authRepository.verifyOtp(email, otp);

    if (response.containsKey("message") && response["message"] == "Code verified successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ OTP vérifié avec succès !")),
      );

      isLoading = false;
      notifyListeners();
      return true; // ✅ Retourner "true" si l'OTP est valide
    }

    isLoading = false;
    notifyListeners();
    return false; // ❌ Retourner "false" si l'OTP n'est pas reconnu
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Erreur : $e")),
    );

    isLoading = false;
    notifyListeners();
    return false;
  }
}







void _showResetPasswordBottomSheet(BuildContext context, String email) {
  print("✅ Ouverture de ResetPasswordBottomSheet...");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ResetPasswordBottomSheet(email: email),
  );
}





/********************************/


  Future<void> resendOtp(BuildContext context, String email) async {
    try {
      await _authRepository.resendOtp(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset code sent to your email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

/********************************/

    void _showOTPBottomSheet(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OTPVerificationBottomSheet(email: email), // Ajout de l'email
    );
  }


}
