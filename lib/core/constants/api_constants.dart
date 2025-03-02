import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://192.168.1.103:3000"; // Android Emulator
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:3000"; // iOS Simulator
    } else {
      return "http://192.168.1.103:3000"; // Physical Device (update with your local IP)
    }
  }

  static String get loginEndpoint => "$baseUrl/auth/login";
  static String get signupEndpoint => "$baseUrl/auth/signup";
  static String get forgotPasswordEndpoint => "$baseUrl/auth/forgot-password";
  static String get verifyOtpEndpoint => "$baseUrl/auth/verify-reset-code";
  static String get resendOtpEndpoint => "$baseUrl/auth/get-reset-code";
  static String get resetPasswordEndpoint => "$baseUrl/auth/reset-password";
  static String get getProfileEndpoint => "$baseUrl/auth/profile";
  static String get updateProfileEndpoint => "$baseUrl/auth/update-profile";
  static String get completeProfileEndpoint => "$baseUrl/auth/completeProfile";


// Ajout des nouvelles routes pour le module Medication
  static String get createMedicationEndpoint => "$baseUrl/medications";
  static String get getAllMedicationsEndpoint => "$baseUrl/medications";
  static String get getMedicationsByFilterEndpoint => "$baseUrl/medications/filter";
  static String  getMedicationEndpoint(String id) => "$baseUrl/medications/$id";
  static String  updateMedicationEndpoint(String id) => "$baseUrl/medications/$id";
  static String  deleteMedicationEndpoint(String id) => "$baseUrl/medications/$id";




  
}