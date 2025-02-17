class ApiConstants {
  static const String baseUrl = "http://172.16.4.80:3000";
  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String signupEndpoint = "$baseUrl/auth/signup";
  static const String forgotPasswordEndpoint = "$baseUrl/auth/forgot-password";
  static const String verifyOtpEndpoint = "$baseUrl/auth/verify-reset-code";
  static const String resendOtpEndpoint = "$baseUrl/auth/get-reset-code";
  static const String resetPasswordEndpoint = "$baseUrl/auth/reset-password";
  static const String getProfileEndpoint = "$baseUrl/auth/profile"; 
  static const String updateProfileEndpoint = "$baseUrl/auth/update-profile"; // Add this line
  static const String completeProfileEndpoint = "$baseUrl/auth/completeProfile"; // Add this line

}
