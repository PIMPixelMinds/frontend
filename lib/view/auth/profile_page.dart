import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: AppColors.primaryBlue,),
      backgroundColor: isDarkMode ? AppColors.primaryBlue : AppColors.primaryBlue, // Fond principal du Scaffold
      body: Column(
        children: [
          _buildProfileHeader(isDarkMode), // En-tête du profil
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Alignement du contenu à gauche
                      children: [
                        _buildSectionTitle("Account Settings", isDarkMode),
                        _buildProfileOption(context, Icons.person, "Personal Information", () {
                          Navigator.pushNamed(context, '/personalInformation');
                        }, isDarkMode),
                        _buildProfileOption(context, Icons.lock, "Password & Security", () {
                          Navigator.pushNamed(context, '/passwordSecurity');
                        }, isDarkMode),
                        _buildProfileOption(context, Icons.medical_information, "Medical History", () {
                          Navigator.pushNamed(context, '/medicalHistory');
                        }, isDarkMode),
                        _buildProfileOption(context, Icons.co_present, "Primary Caregiver", () {
                          Navigator.pushNamed(context, '/primaryCaregiver');
                        }, isDarkMode),
                      
                        _buildSectionTitle("Other", isDarkMode),
                        _buildProfileOption(context, Icons.notifications, "Notifications Preferences", () {}, isDarkMode),
                        _buildProfileOption(context, Icons.settings, "Settings", () {}, isDarkMode),
                        _buildProfileOption(context, Icons.article_outlined, "Terms & Conditions", () {}, isDarkMode),
                        _buildProfileOption(context, Icons.privacy_tip_outlined, "Privacy Policy", () {}, isDarkMode),
                        _buildProfileOption(context, Icons.announcement_outlined, "Help & Assistance", () {}, isDarkMode),
                        const SizedBox(height: 20),
                        _buildProfileOption(context, Icons.logout_outlined, "Log Out", () { _logout(context);}, isDarkMode),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 **En-tête du profil**
  Widget _buildProfileHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryBlue : AppColors.primaryBlue,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Jaydon Mango",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            "jaydonmango@gmail.com",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🔹 **Titre de section**
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5, left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white60 : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 🔹 **Options du menu du profil**
  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.grey),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // 🔴 **Bouton de déconnexion**
  Widget _buildLogoutButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _logout(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🔴 **Déconnexion**
  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logging out...")));
    // Ajoute ici l'action pour déconnecter l'utilisateur
  }
}
