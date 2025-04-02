import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrimaryCaregiverPage extends StatefulWidget {
  const PrimaryCaregiverPage({super.key});

  @override
  _PrimaryCaregiverPageState createState() => _PrimaryCaregiverPageState();
}

class _PrimaryCaregiverPageState extends State<PrimaryCaregiverPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBlue : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Primary Caregiver",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Name", "Enter caregiver's name", nameController, isDarkMode),
                    const SizedBox(height: 15),
                    _buildTextField("Phone", "Enter caregiver's phone", phoneController, isDarkMode, isPhone: true),
                    const SizedBox(height: 15),
                    _buildTextField("Email", "Enter caregiver's email", emailController, isDarkMode, isEmail: true),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(isDarkMode), // Bouton en bas de l'écran
        ],
      ),
    );
  }

  // 🟢 **En-tête du profil avec une icône utilisateur**
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person, // Icône de profil
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Edit Caregiver Details",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🟡 **Champs de texte avec validation**
  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDarkMode, {bool isPhone = false, bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "This field is required";
            }
            if (isPhone && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
              return "Enter a valid phone number";
            }
            if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return "Enter a valid email address";
            }
            return null;
          },
        ),
      ],
    );
  }

  // 🔵 **Bouton de sauvegarde en bas**
  Widget _buildBottomButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Edit",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
