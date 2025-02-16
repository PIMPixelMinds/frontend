import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  _PersonalInformationPageState createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  String? selectedGender; 
  final TextEditingController fullNameController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBlue : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Personal Information",
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
                    _buildTextField("Full Name", "Enter your full name", fullNameController, false, isDarkMode),
                    const SizedBox(height: 15),
                    const Text(
          "Birthday",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
                    _buildDatePickerField(isDarkMode),  // 🔹 Utilisation du champ DatePicker
                    const SizedBox(height: 15),
                    _buildGenderSelector(isDarkMode),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(isDarkMode), // Bouton en bas
        ],
      ),
    );
  }

  // 🔹 **Méthode pour ouvrir le Date Picker**
Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue, // 🔹 Couleur de la sélection
            onPrimary: Colors.white, // 🔹 Texte sur le bouton OK
            surface: Colors.white, // 🔹 Fond du DatePicker
            onSurface: Colors.black, // 🔹 Texte des jours
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue, // 🔹 Couleur des boutons OK/Annuler
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null && pickedDate != selectedDate) {
    setState(() {
      selectedDate = pickedDate;
    });
  }
}


  // 🔹 **Champ DatePicker pour le Birthday**
  Widget _buildDatePickerField(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: "Birthday",
            hintText: selectedDate != null
                ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
                : "Select your birthday",
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),  // Icône de calendrier
          ),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // 🟢 **En-tête du profil avec l'image et le texte**
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
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
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
        child: const Text("Edit", style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  // 🟣 **Sélecteur de genre avec deux boutons**
  Widget _buildGenderSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderButton("Male", Icons.male, isDarkMode),
            const SizedBox(width: 10),
            _buildGenderButton("Female", Icons.female, isDarkMode),
          ],
        ),
      ],
    );
  }

  // 🆕 **Widget pour styliser un bouton de genre**
  Widget _buildGenderButton(String gender, IconData icon, bool isDarkMode) {
    bool isSelected = selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : (isDarkMode ? Colors.grey[800] : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 22),
              const SizedBox(width: 5),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // 🟡 **Champs de texte stylisés**
  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isPassword, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
  controller: controller,
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
    if (isPassword && value.length < 6) {
      return "Password must be at least 6 characters long.";
    }
    if (!isPassword && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email address.";
    }
    return null;
  },
),
      ],
    );
  }

}
