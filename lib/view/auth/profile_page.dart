import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodel/auth_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      authViewModel.getProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = Provider.of<AuthViewModel>(context);

    final String userName = authViewModel.userProfile?["fullName"] ?? "Jaydon Mango";
    final String userEmail = authViewModel.userProfile?["email"] ?? "jaydonmango@gmail.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: AppColors.primaryBlue,

      ),
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              _buildProfileHeader(isDarkMode, userName, userEmail),
            ],
          ),
          _buildBottomSheet(context, isDarkMode),
        ],
      ),
    );
  }

  // 🟢 **En-tête du profil**
  Widget _buildProfileHeader(bool isDarkMode, String userName, String userEmail) {
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
            userName.toUpperCase(), // Use the dynamic user name
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          Text(
            userEmail, // Use the dynamic user email
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🟣 **Bottom Sheet stylisée**
  Widget _buildBottomSheet(BuildContext context, bool isDarkMode) {
  return DraggableScrollableSheet(
    initialChildSize: 0.77, // Hauteur initiale
    minChildSize: 0.77, // Hauteur minimale
    //maxChildSize: 0.9, // Hauteur maximale
    builder: (context, scrollController) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView( // ✅ Permet de scroller si nécessaire
          controller: scrollController, // ✅ Ajout du contrôleur pour le défilement
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Account", isDarkMode),
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

              const SizedBox(height: 10),
              const Divider(),
              _buildProfileOption(context, Icons.notifications, "Notifications Preferences", () {}, isDarkMode),
              _buildProfileOption(context, Icons.settings, "Settings", () {}, isDarkMode),
              _buildProfileOption(context, Icons.article_outlined, "Terms & Conditions", () {}, isDarkMode),
              _buildProfileOption(context, Icons.privacy_tip_outlined, "Privacy Policy", () {}, isDarkMode),
              _buildProfileOption(context, Icons.help_outline, "Help & Assistance", () {}, isDarkMode),

              const SizedBox(height: 15),
              const Divider(),
              _buildProfileOption(context, Icons.delete_forever, "Delete My Account", () {
                _confirmDeleteAccount(context);
              }, isDarkMode),

              _buildProfileOption(context, Icons.logout, "Log Out", () {
                _logout(context);
              }, isDarkMode),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}


  // 🔹 **Titre de section**
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey),
      ),
    );
  }

  // 🔹 **Options du menu du profil**
  Widget _buildProfileOption(BuildContext context, IconData icon, String title, VoidCallback onTap, bool isDarkMode, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        child: ListTile(
          leading: Icon(icon, color: (isDarkMode ? Colors.white : Colors.grey)),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: (isDarkMode ? Colors.white : Colors.black)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  // 🔴 **Déconnexion**
  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logging out...")));
    // Ajoute ici la logique de déconnexion
  }

  // ❌ **Confirmation de suppression du compte**
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () {}, child: const Text("Delete", style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
