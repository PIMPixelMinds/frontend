import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

import '../view/auth/otp_verification_page.dart';
import '../view/auth/reset_password_bottom_sheet.dart';

class AuthViewModel extends ChangeNotifier {
  // 🔥 IMPORTANT
  final AuthRepository _authRepository = AuthRepository();
  bool isLoading = false;
  Map<String, dynamic>? userProfile; // Store the user profile data
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '734641894768-ia4pps1lkg9in9ehu3sp5r41m1lktv1h.apps.googleusercontent.com',
    // Laissez clientId vide pour utiliser la configuration Android via Google Cloud
    scopes: ['email', 'profile','openid'],
  );

  Future<void> googleSignIn(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      print('Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        throw Exception('Google sign-in cancelled');
      }

      print('Google user signed in: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google authentication failed: Missing ID token');
      }

      print('Google ID Token obtained: $idToken');
      // Envoyer le token ID Google directement au backend
      final data = await _authRepository.googleLogin(idToken);

      if (data == null || !data.containsKey('token')) {
        print('Backend response: $data');
        throw Exception('Invalid token received from Google login');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('refreshToken', data['refreshToken'] ?? '');
      await prefs.setInt('tokenCreationTime', DateTime.now().millisecondsSinceEpoch);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login successful!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
/********************************/
  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _authRepository.loginUser(email, password);

      if (data == null || !data.containsKey("token")) {
        throw Exception("Invalid token received");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setInt("tokenCreationTime",
          DateTime.now().millisecondsSinceEpoch); // Stocke le timestamp
      await prefs.setString("refreshToken",
          data["refreshToken"] ?? ""); // Ajoutez un refresh token si fourni
      print(
          "Contenu de SharedPreferences : token=${prefs.getString('token')}, refreshToken=${prefs.getString('refreshToken')}, tokenCreationTime=${prefs.getInt('tokenCreationTime')}");
// Logs pour déboguer
      print("Token stocké : ${data["token"]}");
      print(
          "Refresh Token stocké : ${data["refreshToken"] ?? 'Aucun refresh token'}");
      print("Timestamp de création : ${DateTime.now().millisecondsSinceEpoch}");

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
  // Vérifie si le token est expiré (5 minutes = 300000 millisecondes)
  Future<bool> isTokenExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final tokenCreationTime = prefs.getInt("tokenCreationTime");
    final token = prefs.getString("token");

    if (tokenCreationTime == null || token == null) {
      print("Token ou timestamp manquant : $token, $tokenCreationTime");
      return true; // Token invalide ou inexistant
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final isExpired = (currentTime - tokenCreationTime) >
        300000; // 5 minutes en millisecondes
    print(
        "Token expiration check - Créé à $tokenCreationTime, Maintenant $currentTime, Expiré : $isExpired");
    return isExpired;
  }

/********************************/
  // Rafraîchit le token avec le refresh token
  Future<void> refreshToken(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("refreshToken");

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("No refresh token available. Please log in again.");
      }

      final response = await _authRepository.refreshToken(refreshToken);

      if (response.containsKey("token") &&
          response.containsKey("refreshToken")) {
        await prefs.setString("token", response["token"]);
        await prefs.setString("refreshToken", response["refreshToken"]);
        await prefs.setInt(
            "tokenCreationTime", DateTime.now().millisecondsSinceEpoch);
        print(
            "Nouveau token : ${response["token"]}, Nouveau refresh token : ${response["refreshToken"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token refreshed successfully!")),
        );
      } else {
        throw Exception("Failed to refresh token: Invalid response");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      print("Erreur refreshToken : $e");
      // Rediriger vers la page de login si le rafraîchissement échoue
      Navigator.pushReplacementNamed(context, "/login");
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

  Future<void> sendForgotPasswordRequest(
      BuildContext context, String email) async {
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

      Navigator.pop(context);
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

      if (response.containsKey("message") &&
          response["message"] == "Code verified successfully") {
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
      builder: (context) =>
          OTPVerificationBottomSheet(email: email), // Ajout de l'email
    );
  }

/***********************************/

  Future<void> resetPassword(
      BuildContext context, String email, String newPassword) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authRepository.resetPassword(email, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful!")),
      );

      Navigator.pop(context); // Close the reset password bottom sheet or dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //************************************************/
  Future<void> getProfile(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners(); // Notify listeners to show loading state

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      // Fetch the profile data
      userProfile = await _authRepository.getProfile(token);

      // Notify listeners to update the UI after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

/************************************************************/
  Future<void> updateProfile({
    required BuildContext context,
    required String newName,
    required String newBirthday,
    required String newGender,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      // Call the updateProfile method from the repository
      final response = await _authRepository.updateProfile(
        token: token,
        newName: newName,
        newBirthday: newBirthday,
        newGender: newGender,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/************************************************************/
  Future<void> changePassword({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      // Call the changePassword method from the repository
      await _authRepository.changePassword(
        token: token,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/*******************************************************************************************/
  Future<void> updateEmail({
    required BuildContext context,
    required String newEmail,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("No token found. Please log in again.");
      }

      // Call the updateEmail method from the repository
      await _authRepository.updateEmail(
        token: token,
        newEmail: newEmail,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
