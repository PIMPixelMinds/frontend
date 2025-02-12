import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthRepository {

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)["message"] ?? "Login failed");
    }
  }

  /********************************/

Future<Map<String, dynamic>?> registerUser({
    required String fullName,
    required String email,
    required String password,

  }) async {
    final url = Uri.parse(ApiConstants.signupEndpoint);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName.trim(),
          "email": email.trim(),
          "password": password.trim(),
  
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)["message"] ?? "Registration failed");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
/********************************/

  Future<Map<String, dynamic>> sendForgotPasswordRequest(String email) async {
    final url = Uri.parse(ApiConstants.forgotPasswordEndpoint);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)["message"] ?? "Something went wrong");
    }
  }

/********************************/

Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
  final url = Uri.parse(ApiConstants.verifyOtpEndpoint);
  print("🔵 Appel API : $url avec email=$email et otp=$otp");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "resetCode": otp}),
    );

    print("🔵 Réponse HTTP Status : ${response.statusCode}");
    print("🔵 Réponse HTTP Body : ${response.body}");

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ OTP validé avec succès !");
      return responseBody; // ✅ Retourner directement la réponse en cas de succès
    } else {
      throw Exception(responseBody["message"] ?? "Invalid OTP");
    }
  } catch (e) {
    print("❌ Erreur API : $e");
    throw Exception("Erreur de connexion à l'API : $e");
  }
}

/********************************/

  Future<void> resendOtp(String email) async {
    final url = Uri.parse("${ApiConstants.resendOtpEndpoint}/$email");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to resend OTP");
    }
  }
}
