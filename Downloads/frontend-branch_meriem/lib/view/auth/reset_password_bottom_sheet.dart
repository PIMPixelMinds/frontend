import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ResetPasswordBottomSheet extends StatefulWidget {
  final String email; // Declare the email field
  const ResetPasswordBottomSheet({super.key, required this.email}); // Store the email parameter

  @override
  _ResetPasswordBottomSheetState createState() => _ResetPasswordBottomSheetState();
}

class _ResetPasswordBottomSheetState extends State<ResetPasswordBottomSheet> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isError = false;

  void _resetPassword() {
    if (newPasswordController.text == confirmPasswordController.text) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Reset Successfully!")),
      );
    } else {
      setState(() {
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color inputFieldColor = isDarkMode ? Colors.grey[900]! : Colors.grey[200]!;

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
          const Text("Reset Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Champ "New Password"
          TextField(
            controller: newPasswordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: "New Password",
              filled: true,
              fillColor: inputFieldColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Champ "Confirm New Password"
          TextField(
            controller: confirmPasswordController,
            obscureText: !isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: "Confirm New Password",
              filled: true,
              fillColor: inputFieldColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
              ),
              errorText: isError ? "Passwords do not match" : null,
            ),
          ),
          const SizedBox(height: 20),

          // Reset Password Button
          ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Reset Password", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}