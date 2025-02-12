class ApiConstants {
  static const String baseUrl = "http://192.168.1.21:3000";
  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String signupEndpoint = "$baseUrl/auth/signup";
    static const String forgotPasswordEndpoint = "$baseUrl/auth/forgot-password";
static const String verifyOtpEndpoint = "$baseUrl/auth/verify-reset-code";
  static const String resendOtpEndpoint = "$baseUrl/auth/get-reset-code";
}

