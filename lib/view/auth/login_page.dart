import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodel/auth_viewmodel.dart';
import 'register_page.dart';
//BECHA
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
  bool rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  /// **Load saved credentials from SharedPreferences**
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    bool savedRememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedRememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });

      // **Auto-login if rememberMe is checked**
      Future.delayed(Duration.zero, () {
        Provider.of<AuthViewModel>(context, listen: false)
            .login(context, savedEmail, savedPassword);
      });
    }
  }

  /// **Save credentials when "Remember Me" is checked**
  Future<void> _saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  /// Vérifie si tous les champs sont valides pour activer le bouton "Login"
  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.radio_button_checked,
                              size: 60, color: AppColors.primaryBlue),
                          const SizedBox(height: 10),
                          const Text("Login",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildTextField("Email", "Enter your email",
                              emailController, false, isDarkMode),
                          const SizedBox(height: 15),
                          _buildTextField("Password", "Enter your password",
                              passwordController, true, isDarkMode),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    activeColor: AppColors.primaryBlue,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                  ),
                                  const Text("Remember Me"),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _showEmailBottomSheet(context),
                                child: const Text("Forgot Password?",
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Consumer<AuthViewModel>(
                            builder: (context, authViewModel, child) {
                              return ElevatedButton(
                                onPressed: isFormValid
                                    ? () async {
                                        await _saveCredentials(
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                        authViewModel.login(
                                          context,
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                      }
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states
                                          .contains(WidgetState.disabled)) {
                                        return AppColors.primaryBlue
                                            .withOpacity(0.7); // Désactivé
                                      }
                                      if (states
                                          .contains(WidgetState.pressed)) {
                                        return AppColors.primaryBlue
                                            .withOpacity(
                                                0.9); // En cours de clic
                                      }
                                      return AppColors
                                          .primaryBlue; // Par défaut
                                    },
                                  ),
                                  minimumSize: WidgetStateProperty.all<Size>(
                                      const Size(double.infinity, 50)),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  overlayColor: WidgetStateProperty.all<Color>(
                                    AppColors.primaryBlue.withOpacity(
                                        0.2), // Effet de surbrillance
                                  ),
                                  shadowColor: WidgetStateProperty.all<Color>(
                                      Colors.transparent), // Supprime l'ombre
                                ),
                                child: authViewModel.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text("Login",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white)),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildDividerWithText("Or continue with"),
                          const SizedBox(height: 15),
                          _buildSocialButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildSignUpOption(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, bool isPassword, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  )
                : null,
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "This field is required";
            }
            if (isPassword && value.length < 5) {
              return "Password must be at least 6 characters long.";
            }
            if (!isPassword &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return "Enter a valid email address.";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton("assets/google.png"),
        const SizedBox(width: 20),
        _buildSocialButton("assets/facebook.png"),
      ],
    );
  }

  Widget _buildSocialButton(String asset) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
      child: Center(
        child: Image.asset(asset, width: 25, height: 25),
      ),
    );
  }

  Widget _buildSignUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RegisterPage())),
          child: const Text("Signup",
              style: TextStyle(color: AppColors.primaryBlue)),
        ),
      ],
    );
  }
}

void _showEmailBottomSheet(BuildContext context) {
  final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
  TextEditingController emailController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter Your Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: "Enter your email",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authViewModel.sendForgotPasswordRequest(
                    context, emailController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text("Continue", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
