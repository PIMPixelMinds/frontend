import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodel/auth_viewmodel.dart'; // Import your AuthViewModel

class PasswordSecurityPage extends StatefulWidget {
  const PasswordSecurityPage({super.key});

  @override
  _PasswordSecurityPageState createState() => _PasswordSecurityPageState();
}

class _PasswordSecurityPageState extends State<PasswordSecurityPage> {
  bool isPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Password & Security",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSecurityOption(context, Icons.lock, "Change Password", "PIN",
                () {
              _showChangePasswordDialog(context);
            }),
            _buildSecurityOption(
                context, Icons.face, "Face ID", "Not Registered", () {}),
            _buildSecurityOption(context, Icons.phone, "Verified Phone Number",
                "Not Registered", _showUpdatePhoneDialog),
            _buildSecurityOption(context, Icons.email, "Verified Email Address",
                "Registered", _showUpdateEmailDialog),
          ],
        ),
      ),
    );
  }

  // **Widget option sécurité**
  Widget _buildSecurityOption(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: isDarkMode ? 0 : 1,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: subtitle == "Registered" ? Colors.green : Colors.grey)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // **Bottom Sheet générique**
  void _showBottomSheet(BuildContext context, String title, String hint,
      TextInputType inputType, VoidCallback onSave,
      {required TextEditingController controller}) {
    bool isFormValid = false;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  Text(title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 10),
                  _buildTextField(hint, controller, () {
                    setState(() {
                      isFormValid = controller.text.isNotEmpty &&
                          (inputType == TextInputType.phone
                              ? RegExp(r'^\+?[0-9]{7,15}$')
                                  .hasMatch(controller.text)
                              : RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(controller.text));
                    });
                  }, inputType, isDarkMode),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () {
                            onSave();
                            Navigator.pop(context);
                          }
                        : null,
                    style: _buildButtonStyle(isDarkMode),
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdatePhoneDialog() {
    TextEditingController phoneController = TextEditingController();
    _showBottomSheet(context, "Update Phone Number", "Enter phone number",
        TextInputType.phone, () {}, controller: phoneController);
  }

  void _showUpdateEmailDialog() {
    TextEditingController emailController = TextEditingController();
    _showBottomSheet(context, "Update Email", "Enter email address",
        TextInputType.emailAddress, () async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.updateEmail(
        context: context,
        newEmail: emailController.text, // Use the value from the text field
      );
    }, controller: emailController);
  }

  // **TextField réutilisable**
  Widget _buildTextField(String label, TextEditingController controller,
      VoidCallback validateForm, TextInputType keyboardType, bool isDarkMode) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (text) => validateForm(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
    );
  }

  // **Style du bouton Save**
  ButtonStyle _buildButtonStyle(bool isDarkMode) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primaryBlue.withOpacity(0.7);
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryBlue.withOpacity(0.9);
          }
          return AppColors.primaryBlue;
        },
      ),
      minimumSize:
          WidgetStateProperty.all<Size>(const Size(double.infinity, 50)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Fonction pour afficher le changement de mot de passe avec l'icône "œil"
  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController =
        TextEditingController();

    bool isFormValid = false;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    void validateForm() {
      setState(() {
        isFormValid = passwordController.text.isNotEmpty &&
            newPasswordController.text.isNotEmpty &&
            confirmNewPasswordController.text.isNotEmpty &&
            newPasswordController.text == confirmNewPasswordController.text &&
            newPasswordController.text.length >= 6;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Change Password",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                      "Current Password", passwordController, isPasswordVisible,
                      () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  }, validateForm),
                  _buildPasswordField("New Password", newPasswordController,
                      isNewPasswordVisible, () {
                    setState(() {
                      isNewPasswordVisible = !isNewPasswordVisible;
                    });
                  }, validateForm),
                  _buildPasswordField(
                      "Confirm New Password",
                      confirmNewPasswordController,
                      isConfirmPasswordVisible, () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  }, validateForm),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () async {
                            final authViewModel = Provider.of<AuthViewModel>(
                                context,
                                listen: false);
                            await authViewModel.changePassword(
                              context: context,
                              oldPassword: passwordController.text,
                              newPassword: newPasswordController.text,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return AppColors.primaryBlue
                                .withOpacity(0.7); // Désactivé
                          }
                          if (states.contains(WidgetState.pressed)) {
                            return AppColors.primaryBlue
                                .withOpacity(0.9); // En cours de clic
                          }
                          return AppColors.primaryBlue; // Par défaut
                        },
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 50)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      overlayColor: WidgetStateProperty.all<Color>(
                        AppColors.primaryBlue
                            .withOpacity(0.2), // Effet de surbrillance
                      ),
                      shadowColor: WidgetStateProperty.all<Color>(
                          Colors.transparent), // Supprime l'ombre
                    ),
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget pour afficher un champ de mot de passe avec l'icône "œil"
  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool isVisible,
      VoidCallback toggleVisibility,
      VoidCallback validateForm) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        onChanged: (text) => validateForm(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}